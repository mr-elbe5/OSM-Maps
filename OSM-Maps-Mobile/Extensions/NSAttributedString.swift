/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

extension NSAttributedString{
    
    func height(width: CGFloat) -> CGFloat{
        let sz = boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: [NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.usesFontLeading] , context: nil)
        return sz.height
    }
    
    func size(width: CGFloat) -> CGSize{
        return CGSize(width: width, height: height(width: width))
    }
    
}
