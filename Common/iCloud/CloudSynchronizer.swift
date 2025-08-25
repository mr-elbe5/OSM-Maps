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

enum CloudSyncType{
    case full
    case fromCloud
    case toCloud
}

class CloudSynchronizer: @unchecked Sendable{
    
    static var desiredBaseFields = ["uuid", "itemType", "version", "changeDate", "json"]
    
    var remoteRecords = [UUID:CKRecord]()
    var newRemoteRecords = [CKRecord]()
    var updatedRemoteRecords = [CKRecord:MapItem]()
    var updatedLocalItems = [CKRecord:MapItem]()
    var newLocalItems = [MapItem]()
    var deletedRemoteItems = [MapItem]()
    
    var deletedLocalIds = [CKRecord.ID]()
    
    var steps:Int = 0
    
    var syncType: CloudSyncType
    
    init(syncType: CloudSyncType = .full){
        self.syncType = syncType
    }
    
    var delegate: CloudSynchronizerDelegate? = nil
    
    func clear(){
        Task{
            do{
                if try await CKContainer.isConnected(){
                    try await readRemoteRecords()
                    var recordIds = [CKRecord.ID]()
                    for record in remoteRecords.values{
                        recordIds.append(record.recordID)
                    }
                    try await deleteRemoteRecords(recordIds: recordIds)
                    DispatchQueue.main.async{
                        self.delegate?.clearDone()
                    }
                }
            }
        }
    }
    
    func synchronize(){
        AppData.shared.cleanup()
        AppData.shared.save()
        Task{
            do{
                if try await CKContainer.isConnected(){
                    try await readRemoteRecords()
                    try await evaluateItems()
                    if deletedLocalIds.count > 0{
                        steps += 1
                    }
                    DispatchQueue.main.async{
                        self.delegate?.setSynchronizationSteps(self.steps)
                    }
                    if steps == 0{
                        Log.info("No synchronization steps - nothing to do")
                        return
                    }
                    Log.info("Processing items...")
                    try await processChanges()
                    if syncType == .full || syncType == .toCloud{
                        Log.info("Deleting remote records...")
                        try await deleteRemoteRecords(recordIds: deletedLocalIds)
                        AppData.shared.removeAllDeletedIds()
                    }
                    Log.info( "iCloud synchronization done")
                    DispatchQueue.main.async{
                        self.delegate?.synchronizationDone()
                    }
                    AppData.shared.save()
                }
                else{
                    Log.error("Not connected to iCloud")
                }
            }
            catch (let err){
                Log.error(err.localizedDescription)
            }
        }
    }
    
    // read remote data
    
    private func readRemoteRecords() async throws{
        let query = CKQuery(recordType: MapItem.recordType, predicate: NSPredicate(value: true))
        let records = try await CKContainer.privateDatabase.records(matching: query, desiredKeys: Self.desiredBaseFields, resultsLimit: 100)
        var cursor = records.queryCursor
        Log.debug("got \(records.matchResults.count) remote records")
        readMatchResults(records.matchResults)
        while cursor != nil{
            let records = try await  CKContainer.privateDatabase.records(continuingMatchFrom: cursor!, desiredKeys: Self.desiredBaseFields, resultsLimit: 100)
            cursor = records.queryCursor
            Log.debug("got another \(records.matchResults.count) remote records")
            readMatchResults(records.matchResults)
        }
    }
    
    private func readMatchResults(_ matchResults: [(CKRecord.ID, Result<CKRecord, any Error>)]){
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
    
    // evaluate
    
    private func evaluateItems() async throws{
        Log.debug("got \(AppData.shared.mapItems.count) local items")
        for localItem in AppData.shared.mapItems{
            //Log.debug("local id = \(localItem.id)")
            if !localItem.isCloudSynchronizable{
                Log.error("local id = \(localItem.id) is not synchronizable")
                continue
            }
            if let remoteRecord = remoteRecords[localItem.id]{
                //Log.debug("found remote record for local id: \(remoteRecord.uuid)")
                let remoteVersion = remoteRecord.version
                let localVersion = localItem.cloudVersion
                let remoteChangeDate = remoteRecord.changeDate() ?? Date.distantPast
                let localChangeDate = localItem.changeDate.rounded()
                if remoteVersion == localVersion{
                    if remoteChangeDate < localChangeDate{
                        if syncType == .full || syncType == .toCloud{
                            updatedLocalItems[remoteRecord] = localItem
                            steps += 1
                        }
                    }
                }
                else if remoteVersion > localVersion{
                    if syncType == .full || syncType == .fromCloud{
                        updatedRemoteRecords[remoteRecord] = localItem
                        steps += 1
                    }
                }
                else{
                    if syncType == .full || syncType == .toCloud{
                        updatedLocalItems[remoteRecord] = localItem
                        steps += 1
                    }
                }
                remoteRecords.remove(key: localItem.id)
            }
            else if localItem.cloudVersion != 0{
                if syncType == .full || syncType == .fromCloud{
                    deletedRemoteItems.append(localItem)
                    steps += 1
                }
            }
            else{
                if syncType == .full || syncType == .toCloud{
                    newLocalItems.append(localItem)
                    steps += 1
                }
            }
        }
        for remoteRecord in remoteRecords.values{
            if AppData.shared.deletedIds.contains(remoteRecord.uuid){
                if syncType == .full || syncType == .toCloud{
                    deletedLocalIds.append(remoteRecord.recordID)
                }
            }
            else{
                if syncType == .full || syncType == .fromCloud{
                    newRemoteRecords.append(remoteRecord)
                    steps += 1
                }
            }
        }
    }
    
    // process
    
    private func processChanges() async throws {
        var recordsToSave = [CKRecord]()
        if !updatedLocalItems.isEmpty{
            Log.info("Updating \(updatedLocalItems.count) remote items(s) from local")
            for localItem in updatedLocalItems.values{
                localItem.cloudVersion += 1
                recordsToSave.append(localItem.dataRecord)
            }
        }
        if !newLocalItems.isEmpty{
            Log.info("Creating \(newLocalItems.count) new remote item(s)")
            for localItem in newLocalItems{
                localItem.cloudVersion += 1
                recordsToSave.append(localItem.dataRecord)
            }
        }
        if !recordsToSave.isEmpty{
            try await saveRecords(recordsToSave: recordsToSave)
        }
        if !newRemoteRecords.isEmpty{
            Log.info("creating \(newRemoteRecords.count) local item(s) from remote")
            for (remoteMetaRecord) in newRemoteRecords{
                try await createLocalItemFromRemote(remoteRecord: remoteMetaRecord)
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
        if !deletedRemoteItems.isEmpty{
            Log.info("Deleting \(deletedRemoteItems.count) local item(s)")
            for item in deletedRemoteItems{
                AppData.shared.deleteItem(withId: item.id)
                DispatchQueue.main.async{
                    self.delegate?.nextSynchronizationStep()
                }
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
            DispatchQueue.main.async{
                self.delegate?.nextSynchronizationStep()
            }
        }
    }
    
    private func saveRecords(recordsToSave: Array<CKRecord>) async throws{
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

