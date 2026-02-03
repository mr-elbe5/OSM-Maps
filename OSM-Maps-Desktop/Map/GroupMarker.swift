/*
 OSM Maps (Mac)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

class GroupMarker : MarkerView{
    
    var group : MapItemGroup
    
    override var hasMedia : Bool{
        group.hasMedia
    }
    
    override var hasTrack : Bool{
        group.hasTrack
    }
    
    override var hasRoute : Bool{
        group.hasRoute
    }
    
    init(itemGroup: MapItemGroup, target: AnyObject?, action: Selector?){
        self.group = itemGroup
        super.init(frame: .zero)
        self.target = target
        self.action = action
        isBordered = false
        updateImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updatePosition(to pos: CGPoint){
        //Log.debug("marker positon: \(pos)")
        frame = MarkerView.baseFrame.offsetBy(dx: pos.x, dy: pos.y + 8)
        needsDisplay = true
    }
    
    override func updateImage(){
        if hasMedia{
            if hasTrack{
                image = MapDefaults.mapMixedGroupIcon
            }
            else{
                image = MapDefaults.mapMediaGroupIcon
            }
        }
        else if hasTrack || hasRoute{
            image = MapDefaults.mapTrackGroupIcon
        }
        else{
            image = MapDefaults.mapPlaceGroupIcon
        }
    }
    
}


