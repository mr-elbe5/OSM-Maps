/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit

class AudioItem : MapItem{
    
    static var itemType: String = "audio"
    
    enum AudioCodingKeys: String, CodingKey {
        case time
    }
    
    var fileName: String = ""
    var time: Double
    
    var url: URL{
        get{
            BasePaths.audioDirURL.appendingPathComponent(fileName)
        }
    }
    
    override var itemType : String{
        get{
            return AudioItem.itemType
        }
    }
    
    override var isCloudSynchronizable: Bool{
        return fileExists
    }
    
    var fileExists: Bool{
        if !FileManager.default.fileExists(atPath: url.path){
            Log.error("audio file does not exist: \(url)")
            return false
        }
        return true
    }
    
    var audioData: Data?{
        if let data = FileManager.default.readFile(url: url){
            return data
        }
        Log.error("audio file does not exist: \(url)")
        return nil
    }
    
    override init(){
        time = 0.0
        super.init()
        fileName = "audio_\(id).m4a"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: AudioCodingKeys.self)
        time = try values.decode(Double.self, forKey: .time)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: AudioCodingKeys.self)
        try container.encode(time, forKey: .time)
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
