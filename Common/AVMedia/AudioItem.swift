/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit

class AudioItem : AVMediaItem{
    
    static var itemType: String = "audio"
    
    override var itemType : String{
        get{
            return AudioItem.itemType
        }
    }
    
    override init(){
        super.init()
        fileName = "audio_\(id).m4a"
    }
    
    override init(coordinate: CLLocationCoordinate2D){
        super.init(coordinate: coordinate)
        fileName = "audio_\(id).m4a"
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        fileName = "audio_\(id).m4a"
    }
    
}

typealias AudioItemList = SelectableList<AudioItem>

extension AudioItemList{
    
    mutating func sortByDate(ascending: Bool){
        if ascending{
            self.sort(by: { $0.creationDate < $1.creationDate})
        }
        else{
            self.sort(by: { $0.creationDate > $1.creationDate})
        }
    }
    
}
