/*
 OSM Maps (Mac)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

class MarkerView : NSButton{
    
    static var size : CGFloat{32}
    static var baseFrame = CGRect(x: -size/2,y: -size, width: size, height: size)
    
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
        //Log.debug("marker positon: \(pos)")
        frame = MarkerView.baseFrame.offsetBy(dx: pos.x, dy: pos.y + 2)
        needsDisplay = true
    }
    
    func updateImage(){
    }
    
}


