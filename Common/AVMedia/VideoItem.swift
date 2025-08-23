/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit

class VideoItem : AVMediaItem{
    
    static var itemType: String = "video"
    
    override var itemType : String{
        get{
            return VideoItem.itemType
        }
    }
    
    override init(){
        super.init()
        fileName = "video_\(id).mp4"
    }
    
    override init(coordinate: CLLocationCoordinate2D){
        super.init(coordinate: coordinate)
        fileName = "video_\(id).mp4"
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        fileName = "video_\(id).mp4"
    }
    
}

typealias VideoItemList = SelectableList<VideoItem>

extension VideoItemList{
    
    mutating func sortByDate(ascending: Bool){
        if ascending{
            self.sort(by: { $0.creationDate < $1.creationDate})
        }
        else{
            self.sort(by: { $0.creationDate > $1.creationDate})
        }
    }
    
}




