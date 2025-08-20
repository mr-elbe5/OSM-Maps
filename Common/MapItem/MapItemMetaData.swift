/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

class MapItemMetaData : Codable{
    
    private enum CodingKeys: CodingKey{
        case type
        case data
    }
    
    var type : String
    var data : MapItem?
    
    init(item: MapItem){
        self.type = item.itemType
        self.data = item
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decode(String.self, forKey: .type)
        switch type{
        case ImageItem.itemType:
            data = try values.decode(ImageItem.self, forKey: .data)
        case TrackItem.itemType:
            data = try values.decode(TrackItem.self, forKey: .data)
        case NoteItem.itemType:
            data = try values.decode(NoteItem.self, forKey: .data)
        default:
            data = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(data, forKey: .data)
    }
    
}

typealias MapItemMetaDataList = [MapItemMetaData]

extension MapItemMetaDataList{
    
    init (items: [MapItem]){
        self.init()
        for item in items{
            self.append(MapItemMetaData(item: item))
        }
    }
    
    var items : [MapItem]{
        var result : [MapItem] = []
        for metaData in self{
            switch metaData.type{
            case ImageItem.itemType:
                if let item = metaData.data as? ImageItem{
                    result.append(item)
                }
            case TrackItem.itemType:
                if let item = metaData.data as? TrackItem{
                    result.append(item)
                }
            case NoteItem.itemType:
                if let item = metaData.data as? NoteItem{
                    result.append(item)
                }
            default:
                break
            }
            
        }
        return result
    }
    
}
