/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit
import AVKit

class VideoItem : MapItem{
    
    static var itemType: String = "video"
    
    enum VideoCodingKeys: String, CodingKey {
        case time
    }
    
    var fileName: String = ""
    var previewName: String = ""
    var time: Double
    
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
    
    var previewUrl: URL{
        get{
            BasePaths.videoPreviewDirURL.appendingPathComponent(previewName)
        }
    }
    
    var previewData: Data?{
        if let data = FileManager.default.readFile(url: previewUrl){
            return data
        }
        Log.error("preview file does not exist: \(previewUrl)")
        return nil
    }
    
    var preview: OSImage?{
        if let data = previewData{
            return OSImage(data: data)
        }
        return nil
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
    
    override init(){
        time = 0.0
        super.init()
        fileName = "video_\(id).mp4"
        previewName = "preview_\(id).jpg"
    }
    
    override init(coordinate: CLLocationCoordinate2D){
        time = 0.0
        super.init(coordinate: coordinate)
        fileName = "video_\(id).mp4"
        previewName = "preview_\(id).jpg"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: VideoCodingKeys.self)
        time = try values.decode(Double.self, forKey: .time)
        try super.init(from: decoder)
        fileName = "video_\(id).mp4"
        previewName = "preview_\(id).jpg"
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: VideoCodingKeys.self)
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
    func saveVideoAndCreatePreview(data: Data) -> Bool{
        if saveVideo(data: data), createPreviewFile(){
            Log.debug("save video and preview")
            return true
        }
        Log.error("did not save video and preview")
        return false
    }
    
    @discardableResult
    func saveVideo(data: Data) -> Bool{
        return FileManager.default.saveFile(data: data, url: url)
    }
    
    @discardableResult
    func copyFile(from: URL) -> Bool{
        Log.info("save video file: \(fileName)")
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
        if FileManager.default.fileExists(url: previewUrl){
            if !FileManager.default.deleteFile(url: previewUrl){
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
        if let coordinate = coordinate{
            self.coordinate = coordinate
        }
        if let creationDate = creationDate{
            self.creationDate = creationDate
        }
    }
    
    func createPreview(size: CGFloat) -> OSImage? {
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
        do {
            let cgimg = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let img = OSImage(cgImage: cgimg)
            if let preview = OSImage.createResizedImage(of: img, size: size){
                return preview
            }
        } catch {
          print(error.localizedDescription)
        }
        return nil
    }
    
    @discardableResult
    func createPreviewFile() -> Bool{
        if let preview = createPreview(size: ImageItem.previewSize){
            if let previewData = OSImage.getJpegData(from: preview), FileManager.default.saveFile(data: previewData, url: previewUrl){
                Log.info("saved video preview file: \(previewUrl.lastPathComponent)")
                return true
            }
        }
        return false
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




