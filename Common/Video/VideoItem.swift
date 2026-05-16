/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit
import AVKit
import OSLog

class VideoItem : MapItem{
    
    static var itemType: String = "video"
    
    enum VideoCodingKeys: String, CodingKey {
        case originalFileName
        case fileName
        case time
    }
    
    var originalFileName: String = ""
    var fileName: String = ""
    var time: Double
    
    func generateFileName()
    {
        let ext = originalFileName.split(separator: ".").last
        if let ext = ext, !ext.isEmpty{
            fileName = "video_\(id.uuidString).\(ext)"
        }
        else{
            fileName = "video_\(id.uuidString).mp4"
        }
    }
    
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
    
    var previewName: String{
        get{
            return "video_\(id.uuidString).jpg"
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
        if createPreviewFile(), let data = FileManager.default.readFile(url: previewUrl){
            return data
        }
        Logger.error("preview file does not exist: \(previewUrl)")
        return nil
    }
    
    var preview: OSImage?{
        if let data = previewData{
            return OSImage(data: data)
        }
        return nil
    }
    
    override var isValidItem: Bool{
        return fileExists
    }
    
    var fileExists: Bool{
        if !FileManager.default.fileExists(atPath: url.path){
            Logger.error("video file does not exist: \(url)")
            return false
        }
        return true
    }
    
    override init(){
        time = 0.0
        super.init()
        generateFileName()
    }
    
    override init(coordinate: CLLocationCoordinate2D){
        time = 0.0
        super.init(coordinate: coordinate)
        generateFileName()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: VideoCodingKeys.self)
        originalFileName = try values.decodeIfPresent(String.self, forKey: .originalFileName) ?? ""
        fileName = try values.decodeIfPresent(String.self, forKey: .fileName) ?? ""
        time = try values.decode(Double.self, forKey: .time)
        try super.init(from: decoder)
        if fileName.isEmpty{
            generateFileName()
        }
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: VideoCodingKeys.self)
        try container.encode(originalFileName, forKey: .originalFileName)
        try container.encode(fileName, forKey: .fileName)
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
            Logger.debug("save video and preview")
            return true
        }
        Logger.error("did not save video and preview")
        return false
    }
    
    @discardableResult
    func saveVideo(data: Data) -> Bool{
        return FileManager.default.saveFile(data: data, url: url)
    }
    
    @discardableResult
    func copyFile(from: URL) -> Bool{
        Logger.info("save video file: \(fileName)")
        return FileManager.default.copyFile(fromURL: from, toURL: url, replace: true)
    }
    
    @discardableResult
    func deleteFiles() -> Bool{
        var success = true
        if FileManager.default.fileExists(url: url){
            if !FileManager.default.deleteFile(url: url){
                Logger.error("video item could not delete file: \(fileName)")
                success = false
            }
        }
        if FileManager.default.fileExists(url: previewUrl){
            if !FileManager.default.deleteFile(url: previewUrl){
                Logger.error("video item could not delete file: \(fileName)")
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
                Logger.info("saved video preview file: \(previewUrl.lastPathComponent)")
                return true
            }
        }
        return false
    }
    
}

typealias VideoItemList = LocationList<VideoItem>

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




