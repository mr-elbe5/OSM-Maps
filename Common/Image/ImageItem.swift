/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import CloudKit
import Photos

class ImageItem: MapItem{
    
    static var itemType: String = "image"
    
    static var previewSize: CGFloat = 512
    static var imageSize: CGFloat = 2048
    
    private enum CodingKeys: String, CodingKey {
        case originalFileName
        case fileName
        case metaData
    }
    
    override var itemType: String{
        get{
            ImageItem.itemType
        }
    }
    
    var originalFileName: String = ""
    var fileName: String = ""
    var metaData: ImageMetaData? = nil
    
    func generateFileName()
    {
        let ext = originalFileName.split(separator: ".").last
        if let ext = ext, !ext.isEmpty{
            fileName = "img_\(id.uuidString).\(ext)"
        }
        else{
            fileName = "img_\(id.uuidString).jpg"
        }
    }
    
    var url: URL{
        BasePaths.imageDirURL.appendingPathComponent(fileName)
    }
    
    var previewUrl: URL{
        BasePaths.previewDirURL.appendingPathComponent(fileName)
    }
    
    override var isCloudSynchronizable: Bool{
        return fileExists
    }
    
    var fileExists: Bool{
        if !FileManager.default.fileExists(atPath: url.path){
            Log.error("image file does not exist: \(url)")
            return false
        }
        return true
    }
    
    var imageData: Data?{
        if let data = FileManager.default.readFile(url: url){
            return data
        }
        Log.error("image file does not exist: \(url)")
        return nil
    }
    
    var image: OSImage?{
        if let data = imageData{
            return OSImage(data: data)
        }
        return nil
    }
    
    var previewData: Data?{
        if let data = FileManager.default.readFile(url: previewUrl){
            return data
        }
        Log.error("preview file does not exist: \(url)")
        return nil
    }
    
    var preview: OSImage?{
        if let data = previewData{
            return OSImage(data: data)
        }
        return nil
    }
    
    override init(){
        super.init()
    }
    
    override init(coordinate: CLLocationCoordinate2D){
        super.init(coordinate: coordinate)
    }
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        originalFileName = try values.decodeIfPresent(String.self, forKey: .originalFileName) ?? ""
        fileName = try values.decodeIfPresent(String.self, forKey: .fileName) ?? ""
        metaData = try values.decodeIfPresent(ImageMetaData.self, forKey: .metaData)
        try super.init(from: decoder)
        if fileName.isEmpty{
            generateFileName()
        }
        if metaData == nil{
            loadMetaData()
        }
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(originalFileName, forKey: .originalFileName)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(metaData, forKey: .metaData)
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
    func loadMetaData() -> Bool{
        if let data = FileManager.default.readFile(url: url){
            loadMetaData(from: data)
            return true
        }
        return false
    }
    
    func loadMetaData(from data: Data){
        metaData = ImageMetaData()
        metaData!.readData(data: data)
    }
    
    @discardableResult
    func saveImageAndCreatePreview(data: Data) -> Bool{
        if saveImage(data: data), let original = OSImage(data: data), createPreviewFile(original: original){
            Log.debug("save image and preview")
            return true
        }
        Log.error("did not save image and preview")
        return false
    }
    
    @discardableResult
    func copyImageAndCreatePreview(originalURL: URL, original: OSImage) -> Bool{
        if copyImage(remoteURL: originalURL), createPreviewFile(original: original){
            Log.debug("save image and preview")
            return true
        }
        Log.error("did not save image and preview")
        return false
    }
    
    @discardableResult
    func saveImage(data: Data) -> Bool{
        return FileManager.default.saveFile(data: data, url: url)
    }
    
    @discardableResult
    func copyImage(remoteURL: URL) -> Bool{
        return FileManager.default.copyFile(fromURL: remoteURL, toURL: url, replace: true)
    }
    
    @discardableResult
    func createPreviewFile(original: OSImage) -> Bool{
        if let preview = OSImage.createResizedImage(of: original, size: ImageItem.previewSize){
            if let previewData = OSImage.getJpegData(from: preview), FileManager.default.saveFile(data: previewData, url: previewUrl){
                return true
            }
        }
        return false
    }
    
    @discardableResult
    func deleteFiles() -> Bool{
        var success = true
        if FileManager.default.fileExists(url: url){
            if !FileManager.default.deleteFile(url: url){
                Log.error("ImageItem could not delete file: \(fileName)")
                success = false
            }
        }
        if FileManager.default.fileExists(url: previewUrl){
            if !FileManager.default.deleteFile(url: previewUrl){
                Log.error("ImageItem could not delete preview: \(fileName)")
                success = false
            }
        }
        return success
    }
    
    override func prepareToDelete(){
        deleteFiles()
    }
    
    func updateData(_ oldData: Data) -> Data?{
        let options = [kCGImageSourceShouldCache as String: kCFBooleanFalse]
        if let imageSource = CGImageSourceCreateWithData(oldData as CFData, options as CFDictionary) {
            let uti: CFString = CGImageSourceGetType(imageSource)!
            let newData: NSMutableData = NSMutableData(data: oldData)
            let destination: CGImageDestination = CGImageDestinationCreateWithData((newData as CFMutableData), uti, 1, nil)!
            if let oldMetaData: NSDictionary = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, options as CFDictionary){
                let newMetaData: NSMutableDictionary = oldMetaData.mutableCopy() as! NSMutableDictionary
                metaData?.modifyDictionary(dict: newMetaData)
                CGImageDestinationAddImageFromSource(destination, imageSource, 0, (newMetaData as CFDictionary))
                CGImageDestinationFinalize(destination)
                return newData as Data
            }
        }
        return nil
    }
    
    func updateEditedImage(coordinate: CLLocationCoordinate2D?, creationDate: Date?){
        if let data = FileManager.default.readFile(url: url){
            loadMetaData(from: data)
            if let coordinate = coordinate{
                self.coordinate = coordinate
                metaData!.latitude = coordinate.latitude
                metaData!.longitude = coordinate.longitude
            }
            if let creationDate = creationDate, creationDate != metaData!.dateTime{
                self.creationDate = creationDate
                metaData!.dateTime = creationDate
            }
            if let data = updateData(data){
                if FileManager.default.fileExists(url: url){
                    FileManager.default.deleteFile(url: url)
                }
                setModified()
                FileManager.default.saveFile(data: data, url: url)
            }
        }
    }
    
}

typealias ImageItemList = SelectableList<ImageItem>

extension ImageItemList{
    
    mutating func sortByDate(ascending: Bool){
        if ascending{
            self.sort(by: { $0.creationDate < $1.creationDate})
        }
        else{
            self.sort(by: { $0.creationDate > $1.creationDate})
        }
    }
    
}
