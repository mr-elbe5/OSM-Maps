/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

protocol RouteGridMenuDelegate: GridMenuDelegate{
    func importRoute()
}

class RouteGridMenuView: GridMenuView{
    
    var importRouteButton: NSButton!
    
    override init(){
        super.init()
        importRouteButton = NSButton(image: NSImage(systemSymbolName: "square.and.arrow.down", accessibilityDescription: nil)!, target: self, action: #selector(importRoute))
        importRouteButton.toolTip = "importTrack".localize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView(){
        addSubviewBelow(selectButton, insets: insets)
        addSubviewBelow(increaseSizeButton, upperView: selectButton, insets: insets)
        addSubviewBelow(decreaseSizeButton, upperView: increaseSizeButton, insets: insets)
        addSubviewBelow(importRouteButton, upperView: decreaseSizeButton, insets: insets)
        addSubviewBelow(deleteButton, upperView: importRouteButton, insets: insets)
    }
    
    @objc func importRoute() {
        (delegate as? RouteGridMenuDelegate)?.importRoute()
    }
    
}
    
