/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import CloudKit

class NoteItem: MapItem {
    
    static var itemType: String = "note"
    
    private enum CodingKeys: String, CodingKey {
        case name
        case note
    }
    
    var name: String
    var note: String
    
    override var itemType: String{
        get{
            NoteItem.itemType
        }
    }
    
    override init(){
        name = ""
        note = ""
        super.init()
    }
    
    override init(coordinate: CLLocationCoordinate2D){
        name = ""
        note = ""
        super.init(coordinate: coordinate)
    }
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        note = try values.decodeIfPresent(String.self, forKey: .note) ?? ""
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try super.encode(to: encoder)
        try container.encode(name, forKey: .name)
        try container.encode(note, forKey: .note)
    }
    
    func updateLocation(){
        updateLocation(){
            if self.name.isEmpty{
                self.name = self.address
            }
        }
    }
    
    func update(from item: NoteItem){
        super.update(from: item)
        self.name = item.name
        self.note = item.note
    }
    
}

typealias NoteItemList = LocationList<NoteItem>

extension NoteItemList{
    
    mutating func sortByDate(ascending: Bool){
        if ascending{
            self.sort(by: { $0.creationDate < $1.creationDate})
        }
        else{
            self.sort(by: { $0.creationDate > $1.creationDate})
        }
    }
    
}
