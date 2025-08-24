/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import CloudKit

class AppData : Codable{
    
    static var storeKey = "appData"
    
    static var shared = AppData()
    
    static func load(){
        if let data: AppData = StatusManager.shared.getCodable(key: storeKey){
            Log.debug("got \(data.notes.count) local notes")
            Log.debug("got \(data.images.count) local images")
            Log.debug("got \(data.audios.count) local audios")
            Log.debug("got \(data.videos.count) local videos")
            Log.debug("got \(data.tracks.count) local tracks")
            shared = data
        }
        else{
            shared = AppData()
        }
    }
    
    func save(){
        if StatusManager.shared.saveCodable(key: Self.storeKey, value: self){
            Log.debug("saved \(notes.count) local notes")
            Log.debug("saved \(images.count) local images")
            Log.debug("saved \(audios.count) local audios")
            Log.debug("saved \(videos.count) local videos")
            Log.debug("saved \(tracks.count) local tracks")
        }
        else{
            Log.error("could not save map items data to StatusManager")
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case mapItems
        case deletedIds
    }
    
    private var _mapItems: MapItemList
    private var _deletedIds: Set<UUID> = []
    
    var mapItems: MapItemList{
        get{
            return _mapItems
        }
    }
    
    var deletedIds: Set<UUID>{
        get{
            return _deletedIds
        }
    }
    
    var notes: NoteItemList{
        get{
            var noteItems = NoteItemList()
            for item in _mapItems{
                if item is NoteItem{
                    noteItems.append(item as! NoteItem)
                }
            }
            noteItems.sortByDate(ascending: ViewFilter.shared.defaultSortAscending)
            return noteItems
        }
    }
    
    var images: ImageItemList{
        get{
            var imageItems = ImageItemList()
            for item in _mapItems{
                if item is ImageItem{
                    imageItems.append(item as! ImageItem)
                }
            }
            imageItems.sortByDate(ascending: ViewFilter.shared.defaultSortAscending)
            return imageItems
        }
    }
    
    var tracks: TrackItemList{
        get{
            var trackItems = TrackItemList()
            for item in _mapItems{
                if item is TrackItem{
                    trackItems.append(item as! TrackItem)
                }
            }
            trackItems.sortByDate(ascending: ViewFilter.shared.defaultSortAscending)
            return trackItems
        }
    }
    
    var avMedia: AVMediaItemList{
        get{
            var mediaItems = AVMediaItemList()
            for item in _mapItems{
                if item is AudioItem{
                    mediaItems.append(item as! AudioItem)
                }
                else if item is VideoItem{
                    mediaItems.append(item as! VideoItem)
                }
            }
            mediaItems.sortByDate(ascending: ViewFilter.shared.defaultSortAscending)
            return mediaItems
        }
    }
    
    var audios: AudioItemList{
        get{
            var audioItems = AudioItemList()
            for item in _mapItems{
                if item is AudioItem{
                    audioItems.append(item as! AudioItem)
                }
            }
            audioItems.sortByDate(ascending: ViewFilter.shared.defaultSortAscending)
            return audioItems
        }
    }
    
    var videos: VideoItemList{
        get{
            var videoItems = VideoItemList()
            for item in _mapItems{
                if item is VideoItem{
                    videoItems.append(item as! VideoItem)
                }
            }
            videoItems.sortByDate(ascending: ViewFilter.shared.defaultSortAscending)
            return videoItems
        }
    }
    
    init(){
        _mapItems = MapItemList()
    }
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        let mapItemsMetaData = try values.decodeIfPresent(MapItemMetaDataList.self, forKey: .mapItems) ?? MapItemMetaDataList()
        _mapItems = mapItemsMetaData.items
        _deletedIds = try values.decodeIfPresent(Set<UUID>.self, forKey: .deletedIds) ?? Set<UUID>()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let mapItemsMetaData = MapItemMetaDataList(items: _mapItems)
        try container.encode(mapItemsMetaData, forKey: .mapItems)
        try container.encode(_deletedIds, forKey: .deletedIds)
    }
    
    func saveAsFile() -> URL?{
        let value = self.toJSON()
        let url = BasePaths.tempURL.appendingPathComponent(Self.storeKey + ".json")
        if FileManager.default.saveFile(text: value, url: url){
            return url
        }
        return nil
    }
    
    func loadFromFile(url: URL){
        if let string = FileManager.default.readTextFile(url: url),let data : AppData = AppData.fromJSON(encoded: string){
            _mapItems.removeAll()
            _mapItems.append(contentsOf: data._mapItems)
        }
    }
    
    func addItem(_ item: MapItem){
        _mapItems.append(item)
    }
    
    func getItem(at coordinate: CLLocationCoordinate2D) -> MapItem?{
        for item in _mapItems{
            if item.coordinate == coordinate || item.coordinate.distance(to: coordinate) < MapItem.mergeDistance{
                return item
            }
        }
        return nil
    }
    
    func replaceItems(_ items: [MapItem]){
        _mapItems.removeAll()
        _mapItems.append(contentsOf: items)
    }
    
    @discardableResult
    func cleanup() -> Int{
        var ids = Set<UUID>()
        var deletedCount = 0
        for item in _mapItems{
            if !item.isCloudSynchronizable{
                Log.info("item is not valid for cloud: \(item.id) - deleting")
                item.prepareToDelete()
                _mapItems.remove(obj: item)
                deletedCount += 1
                continue
            }
            if !ids.contains(item.id){
                ids.insert(item.id)
            }
            else{
                Log.info("double id found \(item.id) - deleting")
                item.prepareToDelete()
                _mapItems.remove(obj: item)
                deletedCount += 1
            }
        }
        return deletedCount
    }
    
    func deleteAllData(){
        _mapItems.removeAll()
        FileManager.default.deleteAllFiles(dirURL: BasePaths.imageDirURL)
        FileManager.default.deleteAllFiles(dirURL: BasePaths.previewDirURL)
        removeAllDeletedIds()
        save()
    }
    
    func deleteItem(_ item: MapItem){
        item.prepareToDelete()
        _mapItems.remove(obj: item)
        _deletedIds.insert(item.id)
    }
    
    func deleteItems(_ items: MapItemList){
        for item in items{
            item.prepareToDelete()
            _mapItems.remove(obj: item)
            _deletedIds.insert(item.id)
        }
    }
    
    func deleteItem(withId id: UUID){
        for item in _mapItems{
            if item.id == id{
                item.prepareToDelete()
                _mapItems.remove(obj: item)
                _deletedIds.insert(item.id)
                return
            }
        }
    }
    
    func getItemOfRecord(_ recordID: CKRecord.ID) -> MapItem?{
        if let uuid = UUID(uuidString: recordID.recordName){
            for item in _mapItems{
                if item.id == uuid{
                    return item
                }
            }
        }
        return nil
    }
    
    func updateItemOfRecord(_ record: CKRecord){
        if let item = getItemOfRecord(record.recordID){
            item.cloudVersion = record.version
        }
    }
    
    func removeAllDeletedIds(){
        _deletedIds.removeAll()
    }
    
    func sortItemsByDate(ascending: Bool){
        if ascending{
            _mapItems.sort(by: { $0.creationDate < $1.creationDate})
        }
        else{
            _mapItems.sort(by: { $0.creationDate > $1.creationDate})
        }
    }
    
}
