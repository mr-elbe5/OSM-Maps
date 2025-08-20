/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

extension UIImage{
    
    func resize(maxWidth: CGFloat, maxHeight: CGFloat) -> UIImage{
        if (size.width<=maxWidth || maxWidth==0) && (size.height<=maxHeight || maxHeight==0) {
            return self
        }
        let widthRatio = maxWidth==0 ? 1 : maxWidth/self.size.width
        let heightRatio = maxHeight==0 ? 1 : maxHeight/self.size.height
        let ratio = min(widthRatio,heightRatio)
        let newSize = CGSize(width: size.width*ratio, height: size.height*ratio)
        return resize(size: newSize)
    }
    
    func resize(size: CGSize) -> UIImage{
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image{ (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func toSquare() -> UIImage{
        let cgimg = self.cgImage!
        let side = min(cgimg.width, cgimg.height)
        var cropRect : CGRect!
        if cgimg.width > cgimg.height{
            cropRect = CGRect(x: (cgimg.width - side)/2, y: 0, width: side, height: side)
        }
        else{
            cropRect = CGRect(x: 0, y: (cgimg.height - side)/2, width: side, height: side)
        }
        let cropped = cgimg.cropping(to: cropRect)
        return UIImage(cgImage: cropped!)
    }
    
}

