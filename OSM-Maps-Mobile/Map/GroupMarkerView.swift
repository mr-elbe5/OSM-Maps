/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class GroupMarkerView : MarkerView{
    
    var group : MapItemGroup
    
    override var hasMedia : Bool{
        group.hasMedia
    }
    
    override var hasNote : Bool{
        group.hasNote
    }
    
    override var hasTrack : Bool{
        group.hasTrack
    }
    
    override var hasRoute : Bool{
        group.hasRoute
    }
    
    init(itemGroup: MapItemGroup){
        self.group = itemGroup
        super.init(frame: .zero)
        updateImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateImage(){
        if hasMedia{
            if hasTrack{
                setImage(MapDefaults.mapMixedGroupIcon, for: .normal)
            }
            else{
                setImage(MapDefaults.mapMediaGroupIcon, for: .normal)
            }
        }
        else if hasTrack || hasRoute{
            setImage(MapDefaults.mapTrackGroupIcon, for: .normal)
        }
        else{
            setImage(MapDefaults.mapPlaceGroupIcon, for: .normal)
        }
    }
    
}


