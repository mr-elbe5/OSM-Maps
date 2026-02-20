/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

protocol TrackGridMenuDelegate: GridMenuDelegate{
    func importTrack()
}

class TrackGridMenuView: GridMenuView{
    
    var importTrackButton: NSButton!
    
    override init(){
        super.init()
        importTrackButton = NSButton(image: NSImage(systemSymbolName: "square.and.arrow.down", accessibilityDescription: nil)!, target: self, action: #selector(importTrack))
        importTrackButton.toolTip = "importTrack".localize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView(){
        addSubviewBelow(selectButton, insets: insets)
        addSubviewBelow(increaseSizeButton, upperView: selectButton, insets: insets)
        addSubviewBelow(decreaseSizeButton, upperView: increaseSizeButton, insets: insets)
        addSubviewBelow(importTrackButton, upperView: decreaseSizeButton, insets: insets)
        addSubviewBelow(deleteButton, upperView: importTrackButton, insets: insets)
    }
    
     @objc func importTrack() {
        (delegate as? TrackGridMenuDelegate)?.importTrack()
    }
    
}
    
