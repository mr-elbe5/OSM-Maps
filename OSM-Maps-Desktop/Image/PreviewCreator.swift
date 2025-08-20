/*
 OSM Maps (Mac)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

class PreviewCreator{
    
    static func createPreview(of img: NSImage?, size: CGFloat = 512) -> NSImage?{
        if let img = img{
            if (img.size.width<=MapDefaults.previewSize) && (img.size.height<=MapDefaults.previewSize) {
                return img
            }
            let widthRatio = MapDefaults.previewSize/img.size.width
            let heightRatio = MapDefaults.previewSize/img.size.height
            let ratio = min(widthRatio,heightRatio)
            let newWidth = floor(img.size.width * ratio)
            let newHeight = floor(img.size.height * ratio)
            let frame = NSRect(x: 0, y: 0, width: newWidth, height: newHeight)
            guard let representation = img.bestRepresentation(for: frame, context: nil, hints: nil) else {
                return nil
            }
            let image = NSImage(size: CGSize(width: newWidth, height: newHeight), flipped: false, drawingHandler: { (_) -> Bool in
                representation.draw(in: frame)
            })
            return image
        }
        return nil
    }
    
}
