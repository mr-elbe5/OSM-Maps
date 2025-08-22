/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit

class VideoItem : MapItem{
    
    static var itemType: String = "video"
    
    enum VideoCodingKeys: String, CodingKey {
        case time
    }
    
    var fileName: String = ""
    var time: Double = 0.0
    
    var url: URL{
        get{
            BasePaths.videoDirURL.appendingPathComponent(fileName)
        }
    }
    
    override var itemType : String{
        get{
            return VideoItem.itemType
        }
    }
    
    override var isCloudSynchronizable: Bool{
        return fileExists
    }
    
    var fileExists: Bool{
        if !FileManager.default.fileExists(atPath: url.path){
            Log.error("video file does not exist: \(url)")
            return false
        }
        return true
    }
    
    var videoData: Data?{
        if let data = FileManager.default.readFile(url: url){
            return data
        }
        Log.error("video file does not exist: \(url)")
        return nil
    }
    
    override init(){
        time = 0.0
        super.init()
        fileName = "video_\(id).mp4"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: VideoCodingKeys.self)
        time = try values.decodeIfPresent(Double.self, forKey: .time) ?? 0.0
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: VideoCodingKeys.self)
        try container.encode(time, forKey: .time)
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




