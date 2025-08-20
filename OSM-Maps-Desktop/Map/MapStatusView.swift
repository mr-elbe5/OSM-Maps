/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation


class MapStatusView: NSView{
    
    var zoomLabel = NSTextField(labelWithString: "")
    
    override func setupView() {
        backgroundColor = .black
        var label = NSTextField(labelWithString: "zoomLevel".localizeWithColon())
        addSubviewWithAnchors(label, top: topAnchor, leading: leadingAnchor, insets: OSInsets.narrowInsets)
        addSubviewWithAnchors(zoomLabel, top: topAnchor, leading: label.trailingAnchor)
        label = NSTextField(wrappingLabelWithString: "mapHint".localize(table: "Hints"))
        addSubviewWithAnchors(label, top: zoomLabel.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: OSInsets.narrowInsets)
    }
    
    func setZoom(_ zoom: Int){
        zoomLabel.stringValue = String(zoom)
    }
    
}
