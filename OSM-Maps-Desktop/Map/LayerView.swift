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
    
    func updateScale(_ scale: CGFloat){
        self.scale = scale
        refresh()
    }
    
    func updateContent(_ scale: CGFloat){
        self.scale = scale
    }
    
    func reset(){
    }
    
}




