/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import OSLog

class MarkerView : UIButton{
    
    static var baseFrame = CGRect(x: -12,y: -12, width: 24, height: 24)
    
    var hasMedia : Bool{
        false
    }
    
    var hasNote : Bool{
        false
    }
    
    var hasTrack : Bool{
        false
    }
    
    var hasRoute : Bool{
        false
    }
    
    func updatePosition(to pos: CGPoint){
        //Logger.debug("marker positon: \(pos)")
        frame = MarkerView.baseFrame.offsetBy(dx: pos.x, dy: pos.y)
        setNeedsDisplay()
    }
    
    func updateImage(){
    }
    
}


