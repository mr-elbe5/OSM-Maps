/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class OldMapItems{
    
    var items = MapItemList()
    
    init(){
    }
    
    func loadFromFile(url: URL) -> Array<OldLocationData>{
        if let string = FileManager.default.readTextFile(url: url),let locationList: Array<OldLocationData> = Array<OldLocationData>.fromJSON(encoded: string){
            return locationList
        }
        return []
    }
        
    func convert(from locationList: Array<OldLocationData>){
        for location in locationList{
            for oldItem in location.items{
                if let oldItem = oldItem as? OldImageItem{
                    let item = ImageItem(coordinate: location.coordinate)
                    item.id = oldItem.id
                    item.creationDate = oldItem.creationDate
                    item.fileName = oldItem.fileName
                    if let data = FileManager.default.readFile(url: oldItem.tempURL), let image = OSImage(data: data){
                        if !item.copyImageAndCreatePreview(from: oldItem.tempURL, original: image){
                            Log.debug( "Could not create files for \(item.id)")
                            continue
                        }
                    }
                    item.loadMetaData()
                    items.append(item)
                }
                else if let oldItem = oldItem as? OldAudioItem{
                    let item = AudioItem(coordinate: location.coordinate)
                    item.id = oldItem.id
                    item.creationDate = oldItem.creationDate
                    item.fileName = oldItem.fileName
                    item.time = oldItem.time
                    if !item.copyFile(from: oldItem.tempURL){
                        Log.debug( "Could not create file for \(item.id)")
                        continue
                    }
                    items.append(item)
                }
                else if let oldItem = oldItem as? OldVideoItem{
                    let item = VideoItem(coordinate: location.coordinate)
                    item.id = oldItem.id
                    item.creationDate = oldItem.creationDate
                    item.fileName = oldItem.fileName
                    item.previewName = "preview_\(oldItem.id).jpg"
                    item.time = oldItem.time
                    if item.copyFile(from: oldItem.tempURL), item.createPreviewFile(){
                        items.append(item)
                    }
                    else{
                        Log.debug( "Could not create file for \(item.id)")
                        continue
                    }
                }
                else if let oldItem = oldItem as? OldTrackItem{
                    let item = TrackItem()
                    item.id = oldItem.id
                    item.latitude = location.coordinate.latitude
                    item.longitude = location.coordinate.longitude
                    item.track.name = oldItem.name
                    item.track.trackpoints = oldItem.trackpoints
                    item.track.updateFromTrackpoints()
                    _ = item.getPreview()
                    item.creationDate = oldItem.endTime
                    items.append(item)
                }
                else if let oldItem = oldItem as? OldNoteItem{
                    let item = NoteItem(coordinate: location.coordinate)
                    item.id = oldItem.id
                    item.creationDate = oldItem.creationDate
                    item.note = oldItem.text
                    items.append(item)
                }
            }
        }
    }
}

enum LocatedItemType: String, Codable{
    case image
    case track
    case note
    case audio
    case video
}

class LocatedItem : Decodable{

    private enum CodingKeys: String, CodingKey {
        case id
        case creationDate
    }
    
    var id: UUID
    var creationDate : Date
    var type: LocatedItemType{
        get{
            fatalError("not implemented")
        }
    }
    
    var location: OldLocationData!
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        creationDate = try values.decodeIfPresent(Date.self, forKey: .creationDate) ?? Date()
    }
    
}

typealias LocatedItemsList = Array<LocatedItem>

class OldImageItem : LocatedItem{
    
    static var previewSize: CGFloat = 512
    
    enum CodingKeys: String, CodingKey {
        case fileName
        case title
        case metaData
    }
    
    override var type : LocatedItemType{
        .image
    }
    
    var comment: String
    var fileName : String
    var metaData: ImageMetaData? = nil
    
    var tempURL : URL{
        BasePaths.tempURL.appendingPathComponent("media").appendingPathComponent(fileName)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        fileName = try values.decode(String.self, forKey: .fileName)
        comment = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
        metaData = try values.decodeIfPresent(ImageMetaData.self, forKey: .metaData)
        try super.init(from: decoder)
    }
    
}

class OldAudioItem : LocatedItem{
    
    static var previewSize: CGFloat = 512
    
    enum CodingKeys: String, CodingKey {
        case time
        case fileName
    }
    
    override var type : LocatedItemType{
        .audio
    }
    
    var fileName : String
    var time: Double
    
    var tempURL : URL{
        BasePaths.tempURL.appendingPathComponent("media").appendingPathComponent(fileName)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        time = try values.decode(Double.self, forKey: .time)
        fileName = try values.decode(String.self, forKey: .fileName)
        try super.init(from: decoder)
    }
    
}

class OldVideoItem : LocatedItem{
    
    static var previewSize: CGFloat = 512
    
    enum CodingKeys: String, CodingKey {
        case time
        case fileName
    }
    
    override var type : LocatedItemType{
        .video
    }
    
    var fileName : String
    var time: Double
    
    var tempURL : URL{
        BasePaths.tempURL.appendingPathComponent("media").appendingPathComponent(fileName)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        time = try values.decode(Double.self, forKey: .time)
        fileName = try values.decode(String.self, forKey: .fileName)
        try super.init(from: decoder)
    }
    
}

class OldTrackItem : LocatedItem{
    
    private enum CodingKeys: String, CodingKey {
        case startTime
        case endTime
        case name
        case trackpoints
        case distance
        case upDistance
        case downDistance
        case note
    }
    
    var startTime : Date
    var pauseTime : Date? = nil
    var pauseLength : TimeInterval = 0
    var endTime : Date
    var name : String
    var trackpoints : TrackpointList
    var distance : CGFloat
    var upDistance : CGFloat
    var downDistance : CGFloat
    var note : String
    
    override var type : LocatedItemType{
        get{
            return .track
        }
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        startTime = try values.decodeIfPresent(Date.self, forKey: .startTime) ?? Date.localDate
        endTime = try values.decodeIfPresent(Date.self, forKey: .endTime) ?? Date.localDate
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        trackpoints = try values.decodeIfPresent(TrackpointList.self, forKey: .trackpoints) ?? TrackpointList()
        distance = try values.decodeIfPresent(CGFloat.self, forKey: .distance) ?? 0
        upDistance = try values.decodeIfPresent(CGFloat.self, forKey: .upDistance) ?? 0
        downDistance = try values.decodeIfPresent(CGFloat.self, forKey: .downDistance) ?? 0
        note = try values.decodeIfPresent(String.self, forKey: .note) ?? ""
        try super.init(from: decoder)
    }
    
}

class OldNoteItem : LocatedItem{
    
    private enum CodingKeys: CodingKey{
        case text
    }
    
    override var type : LocatedItemType{
        .note
    }
    
    var text: String
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        text = try values.decode(String.self, forKey: .text)
        try super.init(from: decoder)
    }
    
}


class LocatedItemMetaData : Decodable{
    
    private enum CodingKeys: CodingKey{
        case type
        case data
    }
    
    var type : LocatedItemType
    var data : LocatedItem?
    
    init(item: LocatedItem){
        self.type = item.type
        self.data = item
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decode(LocatedItemType.self, forKey: .type)
        switch type{
        case .image:
            data = try values.decode(OldImageItem.self, forKey: .data)
        case .audio:
            data = try values.decode(OldAudioItem.self, forKey: .data)
        case .video:
            data = try values.decode(OldVideoItem.self, forKey: .data)
        case .track:
            data = try values.decode(OldTrackItem.self, forKey: .data)
        case .note:
            data = try values.decode(OldNoteItem.self, forKey: .data)
        }
    }
    
}

extension Array<LocatedItemMetaData>{
    
    mutating func loadItemList(items: LocatedItemsList){
        removeAll()
        for i in 0..<items.count{
            append(LocatedItemMetaData(item: items[i]))
        }
    }
    
    func toItemList() -> LocatedItemsList{
        var items = LocatedItemsList()
        for metaItem in self{
            if let data = metaItem.data{
                items.append(data)
            }
        }
        return items
    }
    
}

class OldMapItem : Decodable{
    
    private enum CodingKeys: String, CodingKey {
        case id
        case latitude
        case longitude
        case altitude
        case creationDate
        case name
        case address
        case items
    }
    var id : UUID
    var coordinate: CLLocationCoordinate2D
    var altitude: Double
    var creationDate: Date
    var name : String = ""
    var address : String = ""
    var items : LocatedItemsList
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        let latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
        let longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        altitude = try values.decodeIfPresent(CLLocationDistance.self, forKey: .altitude) ?? 0
        creationDate = try values.decodeIfPresent(Date.self, forKey: .creationDate) ?? Date.localDate
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        address = try values.decodeIfPresent(String.self, forKey: .address) ?? ""
        self.items = try values.decodeIfPresent(Array<LocatedItemMetaData>.self, forKey: .items)?.toItemList() ?? LocatedItemsList()
    }
    
}

class OldLocationData : Decodable{
    
    private enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case altitude
        case creationDate
        case items
    }
    
    var coordinate: CLLocationCoordinate2D
    var altitude: Double
    var creationDate: Date
    var items : LocatedItemsList
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
        let longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        altitude = try values.decodeIfPresent(CLLocationDistance.self, forKey: .altitude) ?? 0
        creationDate = try values.decodeIfPresent(Date.self, forKey: .creationDate) ?? Date.localDate
        self.items = try values.decodeIfPresent(Array<LocatedItemMetaData>.self, forKey: .items)?.toItemList() ?? LocatedItemsList()
        for item in items{
            item.location = self
        }
    }
    
}
