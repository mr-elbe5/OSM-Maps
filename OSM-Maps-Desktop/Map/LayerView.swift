/*
 OSM Maps (Mac)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation

class LayerView: NSView {
    
    var scale : CGFloat = 0.0
    
    override var isFlipped: Bool{
        return true
    }
    
    func refresh(){
        needsDisplay = true
    }
    
    func updatePosition(scale: CGFloat){
        self.scale = scale
        refresh()
    }
    
    func updateContent(scale: CGFloat){
        self.scale = scale
    }
    
    func reset(){
    }
    
}




