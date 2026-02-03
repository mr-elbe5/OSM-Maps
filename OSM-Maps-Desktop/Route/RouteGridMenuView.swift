/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

protocol RouteGridMenuDelegate: GridMenuDelegate{
    func importRoute()
}

class RouteGridMenuView: NSView{
    
    var increaseSizeButton: NSButton!
    var decreaseSizeButton: NSButton!
    var importTrackButton: NSButton!
    
    var delegate: RouteGridMenuDelegate? = nil
    
    var insets = OSInsets(top: 10, left: 5, bottom: 10, right: 5)
    
    init(){
        super.init(frame: .zero)
        
        increaseSizeButton = NSButton(image: NSImage(systemSymbolName: "plus", accessibilityDescription: nil)!, target: self, action: #selector(increaseImageSize))
        increaseSizeButton.toolTip = "increaseImageSize".localize()
        decreaseSizeButton = NSButton(image: NSImage(systemSymbolName: "minus", accessibilityDescription: nil)!, target: self, action: #selector(decreaseImageSize))
        decreaseSizeButton.toolTip = "decreaseImageSize".localize()
        importTrackButton = NSButton(image: NSImage(systemSymbolName: "rectangle.portrait.badge.plus", accessibilityDescription: nil)!, target: self, action: #selector(importRoute))
        importTrackButton.toolTip = "importTrack".localize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView(){
        addSubviewBelow(increaseSizeButton, insets: insets)
        addSubviewBelow(decreaseSizeButton, upperView: increaseSizeButton, insets: insets)
        addSubviewBelow(importTrackButton, upperView: decreaseSizeButton, insets: insets)
    }
    
    @objc func increaseImageSize() {
        delegate?.increasePreviewSize()
    }
    
    @objc func decreaseImageSize() {
        delegate?.decreasePreviewSize()
    }
    
    @objc func importRoute() {
        delegate?.importRoute()
    }
    
}
    
