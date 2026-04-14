/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import CloudKit

class MapItem: LocationData, Identifiable, Hashable {
    
    static var recordType: CKRecord.RecordType = "item"
    
    static var mergeDistance: CGFloat = 10
    
    static func == (lhs: MapItem, rhs: MapItem) -> Bool {
        lhs.id == rhs.id
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case creationDate
        case changeDate
        case cloudVersion
    }
    
    var id: UUID
    var creationDate: Date
    var changeDate: Date
    var cloudVersion: Int = 0
    
    var recordID: CKRecord.ID{
        CKRecord.ID(recordName: id.uuidString, zoneID: CKContainer.zoneID)
    }
    
    var dataRecord: CKRecord{
        let record = CKRecord(recordType: MapItem.recordType, recordID: recordID)
        record["uuid"] = id.uuidString
        record["itemType"] = itemType
        record["version"] = Int64(cloudVersion)
        record["changeDate"] = changeDate.rounded
        record["json"] = self.toJSON()
        return record
    }
    
    var isValidItem: Bool{
        return true
    }
    
    var itemType: String{
        get{
            ""
        }
    }
    
    override init(){
        id = UUID()
        let date = Date()
        creationDate = date
        changeDate = date
        super.init()
    }
    
    override init(coordinate: CLLocationCoordinate2D){
        id = UUID()
        let date = Date()
        creationDate = date
        changeDate = date
        super.init(coordinate: coordinate)
    }
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        let date = try values.decodeIfPresent(Date.self, forKey: .creationDate) ?? Date()
        creationDate = date
        changeDate = try values.decodeIfPresent(Date.self, forKey: .changeDate) ?? date
        cloudVersion = try values.decodeIfPresent(Int.self, forKey: .cloudVersion) ?? 0
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encode(changeDate, forKey: .changeDate)
        try container.encode(cloudVersion, forKey: .cloudVersion)
    }
    
    func setModified(){
        changeDate = Date().rounded
    }
    
    func update(from item: MapItem){
        coordinate = item.coordinate
        altitude = item.altitude
        street = item.street
        city = item.city
        changeDate = item.changeDate
        cloudVersion = item.cloudVersion
    }
    
    func prepareToDelete(){        
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}

typealias MapItemList = LocationList<MapItem>

extension MapItemList{
    
    mutating func sortByDate(ascending: Bool){
        if ascending{
            self.sort(by: { $0.creationDate < $1.creationDate})
        }
        else{
            self.sort(by: { $0.creationDate > $1.creationDate})
        }
    }
    
}
