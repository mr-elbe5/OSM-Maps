/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import SwiftUI
import UniformTypeIdentifiers

#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS)
typealias OSImage = NSImage
#else
typealias OSImage = UIImage
#endif

extension Image{
#if os(macOS)
    init (osImage: OSImage){
        self.init(nsImage: osImage)
    }
#else
    init (osImage: OSImage){
        self.init(uiImage: osImage)
    }
#endif
}

extension OSImage{
#if os(macOS)
    convenience init?(iconName: String){
        self.init(systemSymbolName: iconName, accessibilityDescription: nil)
    }
    
    convenience init(cgImage: CGImage){
        self.init(cgImage: cgImage, size: .zero)
    }
#else
    convenience init?(iconName: String){
        self.init(systemName: iconName)
    }
#endif
}

#if os(iOS) || os(macOS)
extension OSImage{
    
    static func createResizedImage(of img: OSImage?, size: CGFloat) -> OSImage?{
        if let img = img{
            if (img.size.width<=size) && (img.size.height<=size) {
                return img
            }
            let widthRatio = size/img.size.width
            let heightRatio = size/img.size.height
            let ratio = min(widthRatio,heightRatio)
            let newWidth = floor(img.size.width * ratio)
            let newHeight = floor(img.size.height * ratio)
            let rect = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
#if os(macOS)
            guard let representation = img.bestRepresentation(for: rect, context: nil, hints: nil) else {
                return nil
            }
            let image = NSImage(size: CGSize(width: newWidth, height: newHeight), flipped: false, drawingHandler: { (_) -> Bool in
                representation.draw(in: rect)
            })
#elseif os(iOS)
            UIGraphicsBeginImageContextWithOptions(rect.size, false, 1.0)
            img.draw(in: rect)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
#endif
            return image
        }
        return nil
    }
}
#endif
  
extension OSImage{
    
    static func getJpegData(from image: OSImage?) -> Data?{
        guard let image else { return nil }
#if os(macOS)
        if let tiff = image.tiffRepresentation, let tiffData = NSBitmapImageRep(data: tiff) {
            return tiffData.representation(using: .jpeg, properties: [:])
        }
        return nil
#else
        return  image.jpegData(compressionQuality: 0.85)
#endif
    }
}

#if os(iOS)
extension OSImage: @retroactive Transferable {
    
    public static var transferRepresentation: some TransferRepresentation {
        
        DataRepresentation(exportedContentType: .png) { image in
            if let pngData = image.pngData() {
                return pngData
            } else {
                throw ConversionError.failedToConvertToPNG
            }
        }
        
        DataRepresentation(exportedContentType: .jpeg) { image in
            if let jpegData = image.jpegData(compressionQuality: 0.85) {
                return jpegData
            } else {
                throw ConversionError.failedToConvertToJPEG
            }
        }
    }
    
    enum ConversionError: Error {
        case failedToConvertToJPEG
        case failedToConvertToPNG
    }
}
#endif

#if !os(watchOS)
struct ImageDocument: FileDocument {
    
    static var readableContentTypes: [UTType] { [.jpeg, .png] }

    var data: Data
    
    init(data: Data){
        self.data = data
    }
    
    init(image: OSImage?){
        if let data = OSImage.getJpegData(from: image){
            self.data = data
        }
        else{
            data = Data()
            Log.error("Failed to convert image to data")
        }
    }

    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents{
            self.data = data
        }
        else{
            data = Data()
            Log.error("Failed to read file contents")
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
    
}
#endif
