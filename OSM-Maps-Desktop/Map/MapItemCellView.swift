/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

protocol MapItemDelegate: NoteCellDelegate, ImageCellDelegate, AudioCellDelegate, VideoCellDelegate, TrackCellDelegate{
    func itemsChanged()
}

class MapItemCellView : NSView{
    
    init(){
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView() {
        super.setupView()
        backgroundColor = .black
    }
    
    func updateIconView(){
    }
    
}

