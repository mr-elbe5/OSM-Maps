/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class RouteMarkerView : UIImageView{
    
    static var baseFrame = CGRect(x: -12,y: -12, width: 24, height: 24)
    
    func updatePosition(to pos: CGPoint){
        frame = RouteMarkerView.baseFrame.offsetBy(dx: pos.x, dy: pos.y)
        setNeedsDisplay()
    }
    
}


