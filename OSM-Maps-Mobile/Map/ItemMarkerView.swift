/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class ItemMarkerView : MarkerView{
    
    var item : MapItem
    
    override var hasMedia : Bool{
        item is ImageItem || item is AudioItem || item is VideoItem
    }
    
    override var hasNote : Bool{
        item is NoteItem
    }
    
    override var hasTrack : Bool{
        item is TrackItem
    }
    
    init(item: MapItem){
        self.item = item
        super.init(frame: .zero)
        updateImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateImage(){
        if hasMedia{
            setImage(MapDefaults.mapMediaIcon, for: .normal)
        }
        else if hasTrack{
            setImage(MapDefaults.mapTrackIcon, for: .normal)
        }
        else{
            setImage(MapDefaults.mapPlaceIcon, for: .normal)
        }
    }
    
}


