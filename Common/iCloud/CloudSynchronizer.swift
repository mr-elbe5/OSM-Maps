/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit

protocol CloudSynchronizerDelegate{
    func setSynchronizationSteps(_ value: Int)
    func nextSynchronizationStep()
    func synchronizationDone()
    func clearDone()
}

class CloudSynchronizer: @unchecked Sendable{
    
    static var desiredBaseFields = ["uuid", "itemType", "version", "changeDate", "json"]
    
    var delegate: CloudSynchronizerDelegate? = nil
    
    func getSyncStatus() async throws -> CloudStatus?{
        var status: CloudStatus? = nil
        if try await CKContainer.isConnected(){
            status = CloudStatus()
            status!.localItems = AppData.shared.mapItems.count
            var remoteRecords = try await readRemoteRecords()
            status!.cloudItems = remoteRecords.count
            for localItem in AppData.shared.mapItems{
                if let remoteRecord = remoteRecords[localItem.id]{
                    //Log.debug("found remote record for local id: \(remoteRecord.uuid)")
                    let remoteVersion = remoteRecord.version
                    let localVersion = localItem.cloudVersion
                    let remoteChangeDate = remoteRecord.changeDate() ?? Date.distantPast
                    let localChangeDate = localItem.changeDate.rounded
                    if remoteVersion > localVersion{
                        status!.updatedCloudItems += 1
                    }
                    else if remoteVersion < localVersion || (remoteVersion == localVersion && remoteChangeDate < localChangeDate){
                        status!.updatedLocalItems += 1
                    }
                    remoteRecords.remove(key: localItem.id)
                }
                else{
                    status!.extraLocalItems += 1
                }
            }
            status!.extraCloudItems = remoteRecords.count
        }
        else{
            Log.error("getting cloud status: not connected to iCloud")
        }
        return status
    }
    
    func deleteAllFromICloud() async throws{
        if try await CKContainer.isConnected(){
            let remoteRecords = try await readRemoteRecords()
            var recordIds = [CKRecord.ID]()
            for record in remoteRecords.values{
                recordIds.append(record.recordID)
            }
            try await deleteRemoteRecords(recordIds: recordIds)
            DispatchQueue.main.async{
                self.delegate?.clearDone()
            }
        }
        else{
            Log.error("delete all from cloud: not connected to iCloud")
        }
    }
    
    func synchronizeFromICloud(deleteMissing: Bool = false) async throws{
        if try await CKContainer.isConnected(){
            var remoteRecords = try await readRemoteRecords()
            var updatedRemoteRecords = [CKRecord:MapItem]()
            var deletableLocalItems = [MapItem]()
            for localItem in AppData.shared.mapItems{
                //Log.debug("local id = \(localItem.id)")
                if let remoteRecord = remoteRecords[localItem.id]{
                    //Log.debug("found remote record for local id: \(remoteRecord.uuid)")
                    let remoteVersion = remoteRecord.version
                    let localVersion = localItem.cloudVersion
                    if remoteVersion > localVersion{
                        updatedRemoteRecords[remoteRecord] = localItem
                    }
                    remoteRecords.remove(key: localItem.id)
                }
                else if deleteMissing{
                    deletableLocalItems.append(localItem)
                }
            }
            //remaining remote records are new
            let steps = updatedRemoteRecords.count + remoteRecords.count + deletableLocalItems.count
            DispatchQueue.main.async{
                self.delegate?.setSynchronizationSteps(steps)
            }
            if steps == 0{
                Log.info("No synchronization steps - nothing to do")
                delegate?.synchronizationDone()
                return
            }
            Log.info("Processing items...")
            //new items
            if !remoteRecords.isEmpty{
                Log.info("creating \(remoteRecords.count) new local item(s) from remote")
                for record in remoteRecords.values{
                    try await createLocalItemFromRemote(remoteRecord: record)
                    DispatchQueue.main.async{
                        self.delegate?.nextSynchronizationStep()
                    }
                }
            }
            if !updatedRemoteRecords.isEmpty{
                Log.info("Updating \(updatedRemoteRecords.count) local item(s) from remote")
                for (remoteRecord, localItem) in updatedRemoteRecords{
                    try await updateLocalItemFromRemote(item: localItem, remoteRecord: remoteRecord)
                    DispatchQueue.main.async{
                        self.delegate?.nextSynchronizationStep()
                    }
                }
            }
            if !deletableLocalItems.isEmpty{
                Log.info("Deleting \(deletableLocalItems.count) local item(s)")
                for item in deletableLocalItems{
                    AppData.shared.deleteItem(withId: item.id)
                    DispatchQueue.main.async{
                        self.delegate?.nextSynchronizationStep()
                    }
                }
            }
            Log.info( "iCloud synchronization done")
            DispatchQueue.main.async{
                self.delegate?.synchronizationDone()
            }
            AppData.shared.save()
        }
        else{
            Log.error("synchronize from cloud: not connected to iCloud")
        }
    }
    
    func synchronizeToICloud(deleteMissing: Bool = false) async throws{
        AppData.shared.deleteInvalidItems()
        AppData.shared.save()
        if try await CKContainer.isConnected(){
            var remoteRecords = try await readRemoteRecords()
            var sendableLocalItems = [MapItem]()
            for localItem in AppData.shared.mapItems{
                //Log.debug("local id = \(localItem.id)")
                if !localItem.isValidItem{
                    Log.error("local id = \(localItem.id) is not synchronizable")
                    continue
                }
                if let remoteRecord = remoteRecords[localItem.id]{
                    //Log.debug("found remote record for local id: \(remoteRecord.uuid)")
                    let remoteVersion = remoteRecord.version
                    let localVersion = localItem.cloudVersion
                    let remoteChangeDate = remoteRecord.changeDate() ?? Date.distantPast
                    let localChangeDate = localItem.changeDate.rounded
                    if remoteVersion < localVersion || (remoteVersion == localVersion && remoteChangeDate < localChangeDate){
                        sendableLocalItems.append(localItem)
                    }
                    remoteRecords.remove(key: localItem.id)
                }
                else{
                    sendableLocalItems.append(localItem)
                }
            }
            //remaining remotes are deletable
            if !deleteMissing{
                remoteRecords.removeAll()
            }
            let steps = sendableLocalItems.count + remoteRecords.count
            DispatchQueue.main.async{
                self.delegate?.setSynchronizationSteps(steps)
            }
            if steps == 0{
                Log.info("No synchronization steps - nothing to do")
                delegate?.synchronizationDone()
                return
            }
            Log.info("Processing items...")
            var recordsToSave = [CKRecord]()
            for localItem in sendableLocalItems{
                localItem.cloudVersion += 1
                recordsToSave.append(localItem.dataRecord)
            }
            if !recordsToSave.isEmpty{
                try await saveRecordsToICloud(recordsToSave: recordsToSave)
            }
            if deleteMissing{
                Log.info("Deleting remote records...")
                var ids = [CKRecord.ID]()
                for record in remoteRecords.values{
                    ids.append(record.recordID)
                }
                try await deleteRemoteRecords(recordIds: ids)
                DispatchQueue.main.async{
                    for _ in 0..<ids.count{
                        self.delegate?.nextSynchronizationStep()
                    }
                }
            }
            Log.info( "iCloud synchronization done")
            DispatchQueue.main.async{
                self.delegate?.synchronizationDone()
            }
            AppData.shared.save()
        }
        else{
            Log.error("synchronize to cloud: not connected to iCloud")
        }
    }
    
    // read remote data
    
    private func readRemoteRecords() async throws -> [UUID:CKRecord]{
        var remoteRecords: [UUID:CKRecord] = [:]
        let query = CKQuery(recordType: MapItem.recordType, predicate: NSPredicate(value: true))
        let records = try await CKContainer.privateDatabase.records(matching: query, desiredKeys: Self.desiredBaseFields, resultsLimit: 100)
        var cursor = records.queryCursor
        Log.debug("got \(records.matchResults.count) remote records")
        readMatchResults(records.matchResults, remoteRecords: &remoteRecords)
        while cursor != nil{
            let records = try await  CKContainer.privateDatabase.records(continuingMatchFrom: cursor!, desiredKeys: Self.desiredBaseFields, resultsLimit: 100)
            cursor = records.queryCursor
            Log.debug("got another \(records.matchResults.count) remote records")
            readMatchResults(records.matchResults, remoteRecords: &remoteRecords)
        }
        Log.debug("got \(AppData.shared.mapItems.count) local and \(remoteRecords.count) remote items")
        return remoteRecords
    }
    
    private func readMatchResults(_ matchResults: [(CKRecord.ID, Result<CKRecord, any Error>)], remoteRecords: inout [UUID:CKRecord]){
        for matchResult in matchResults{
            let result = matchResult.1
            switch result{
            case .failure(let err):
                Log.error(error: err)
            case .success(let record):
                remoteRecords[record.uuid] = record
            }
        }
    }
    
    private func readFileRecord(for record: CKRecord) async throws -> CKRecord?{
        let query = CKQuery(recordType: record.recordType, predicate: NSPredicate(format: "uuid == %@", record.uuid.uuidString))
        let records = try await CKContainer.privateDatabase.records(matching: query, desiredKeys: ["file"])
        if let matchResult = records.matchResults.first{
            let result = matchResult.1
            switch result{
            case .failure(let err):
                Log.error(error: err)
            case .success(let record):
                if record.uuid == record.uuid{
                    return record
                }
                else{
                    Log.error("UUID mismatch for record \(record.uuid.uuidString)")
                }
            }
        }
        return nil
    }
    
    // save
    
    private func createLocalItemFromRemote(remoteRecord: CKRecord) async throws{
        if let itemType = remoteRecord.itemType{
            switch itemType {
            case NoteItem.itemType:
                if let json = remoteRecord.json, let noteItem: NoteItem = NoteItem.fromJSON(encoded: json){
                    Log.info("creating local note item")
                    AppData.shared.addItem(noteItem)
                }
            case ImageItem.itemType:
                if let fileRecord = try await readFileRecord(for: remoteRecord), let json = remoteRecord.json, let imageItem: ImageItem = ImageItem.fromJSON(encoded: json), let asset = fileRecord.file(), let fileURL = asset.fileURL, let imageData = asset.data, let image = OSImage(data: imageData){
                    imageItem.cloudVersion = remoteRecord.version
                    //Log.info("copying image at \(imageItem.url.path()) from \(fileURL.path())")
                    if imageItem.copyImageAndCreatePreview(from: fileURL, original: image){
                        Log.info("creating local image item")
                        AppData.shared.addItem(imageItem)
                    }
                }
            case AudioItem.itemType:
                if let fileRecord = try await readFileRecord(for: remoteRecord), let json = remoteRecord.json, let audioItem: AudioItem = AudioItem.fromJSON(encoded: json), let asset = fileRecord.file(), let fileURL = asset.fileURL{
                    audioItem.cloudVersion = remoteRecord.version
                    //Log.info("copying audio at \(audioItem.url.path()) from \(fileURL.path())")
                    if audioItem.copyFile(from: fileURL){
                        Log.info("creating local audio item")
                        AppData.shared.addItem(audioItem)
                    }
                }
            case VideoItem.itemType:
                if let fileRecord = try await readFileRecord(for: remoteRecord), let json = remoteRecord.json, let videoItem: VideoItem = VideoItem.fromJSON(encoded: json), let asset = fileRecord.file(), let fileURL = asset.fileURL{
                    videoItem.cloudVersion = remoteRecord.version
                    //Log.info("copying video at \(videoItem.url.path()) from \(fileURL.path())")
                    if videoItem.copyFile(from: fileURL), videoItem.createPreviewFile(){
                        Log.info("creating local video item")
                        AppData.shared.addItem(videoItem)
                    }
                }
            case TrackItem.itemType:
                if let json = remoteRecord.json, let trackItem: TrackItem = TrackItem.fromJSON(encoded: json){
                    Log.info("creating local track item")
                    AppData.shared.addItem(trackItem)
                }
            case RouteItem.itemType:
                if let json = remoteRecord.json, let routeItem: RouteItem = RouteItem.fromJSON(encoded: json){
                    Log.info("creating local route item")
                    AppData.shared.addItem(routeItem)
                }
            default:
                return
            }
        }
    }
    
    private func updateLocalItemFromRemote<T: MapItem>(item: T, remoteRecord: CKRecord) async throws{
        if let itemType = remoteRecord.itemType{
            switch itemType {
            case NoteItem.itemType:
                if let json = remoteRecord.json, let noteItem: NoteItem = NoteItem.fromJSON(encoded: json){
                    item.update(from: noteItem)
                }
            case ImageItem.itemType:
                // file will not be updated
                if let json = remoteRecord.json, let imageItem: ImageItem = ImageItem.fromJSON(encoded: json){
                    imageItem.cloudVersion = remoteRecord.version
                    item.update(from: imageItem)
                }
            case TrackItem.itemType:
                if let json = remoteRecord.json, let trackItem: TrackItem = TrackItem.fromJSON(encoded: json){
                    item.update(from: trackItem)
                }
            case RouteItem.itemType:
                if let json = remoteRecord.json, let routeItem: RouteItem = RouteItem.fromJSON(encoded: json){
                    item.update(from: routeItem)
                }
            default:
                return
            }
        }
    }
    
    private func deleteRemoteRecords(recordIds: [CKRecord.ID]) async throws{
        let fullResult = try await CKContainer.privateDatabase.modifyRecords(saving:[], deleting:recordIds, savePolicy: .allKeys, atomically: false)
        for deleteResult in fullResult.deleteResults{
            switch deleteResult.value{
            case .failure(let err):
                Log.error(error: err)
            case .success():
                Log.debug("deleted \(deleteResult.key.recordName) from iCloud")
                break
            }
        }
        if !fullResult.deleteResults.isEmpty{
            Log.info("deleted \(fullResult.deleteResults.count) items from iCloud")
        }
    }
    
    private func saveRecordsToICloud(recordsToSave: Array<CKRecord>) async throws{
        let fullResult = try await CKContainer.privateDatabase.modifyRecords(saving:recordsToSave, deleting:[], savePolicy: .changedKeys, atomically: false)
        for saveResult in fullResult.saveResults{
            switch saveResult.value{
            case .failure(let err):
                Log.error(error: err)
            case .success(let record):
                AppData.shared.updateItemOfRecord(record)
                Log.debug("saved \(record.recordID.recordName) to iCloud")
                DispatchQueue.main.async{
                    self.delegate?.nextSynchronizationStep()
                }
                break
            }
        }
        if !fullResult.saveResults.isEmpty{
            Log.info("saved \(fullResult.saveResults.count) items to iCloud")
        }
    }
    
}

