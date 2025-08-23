/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit

class AVMediaItem : MapItem{
    
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
    
    var mediaData: Data?{
        if let data = FileManager.default.readFile(url: url){
            return data
        }
        Log.error("media file does not exist: \(url)")
        return nil
    }
    
    override init(){
        time = 0.0
        super.init()
    }
    
    override init(coordinate: CLLocationCoordinate2D){
        time = 0.0
        super.init(coordinate: coordinate)
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
    
    override var dataRecord: CKRecord{
        get{
            let record = super.dataRecord
            let asset = CKAsset(fileURL: url)
            record["file"] = asset
            return record
        }
    }
    
    @discardableResult
    func saveData(data: Data) -> Bool{
        return FileManager.default.saveFile(data: data, url: url)
    }
    
    @discardableResult
    func copyFile(from: URL) -> Bool{
        return FileManager.default.copyFile(fromURL: from, toURL: url, replace: true)
    }
    
    @discardableResult
    func deleteFiles() -> Bool{
        var success = true
        if FileManager.default.fileExists(url: url){
            if !FileManager.default.deleteFile(url: url){
                Log.error("media item could not delete file: \(fileName)")
                success = false
            }
        }
        return success
    }
    
    override func prepareToDelete(){
        deleteFiles()
    }
    
    func updateEditedMedia(coordinate: CLLocationCoordinate2D?, creationDate: Date?){
        if let data = FileManager.default.readFile(url: url){
            if let coordinate = coordinate{
                self.coordinate = coordinate
            }
            if let creationDate = creationDate{
                self.creationDate = creationDate
            }
        }
    }
    
}

typealias AVMediaItemList = SelectableList<AVMediaItem>

extension AVMediaItemList{
    
    mutating func sortByDate(ascending: Bool){
        if ascending{
            self.sort(by: { $0.creationDate < $1.creationDate})
        }
        else{
            self.sort(by: { $0.creationDate > $1.creationDate})
        }
    }
    
}
