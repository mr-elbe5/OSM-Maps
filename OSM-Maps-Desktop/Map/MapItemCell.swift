/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation

class MapItemCell: NSView{
    
    var iconView = NSView()
    var itemView = NSView()
    
    var cellBody = NSView()
    
    var iconInsets = NSEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    
    var dateTimeView = NSView()
    var timeLabel = NSTextField(labelWithString: "")
    var mapIconView = NSImageView()
    
    var useShortDate = false
    
    override func setupView() {
        backgroundColor = .clear
        cellBody.backgroundColor = .controlBackgroundColor
        addSubviewFilling(cellBody, insets: OSInsets.smallInsets)
        setupCellBody()
    }
    
    func setupCellBody(){
        cellBody.addSubviewWithAnchors(dateTimeView, top: cellBody.topAnchor, leading: cellBody.leadingAnchor, insets: OSInsets.smallInsets)
        dateTimeView.addSubviewFilling(timeLabel, insets: OSInsets.smallInsets)
        cellBody.addSubviewWithAnchors(mapIconView, leading: dateTimeView.trailingAnchor, insets: .zero)
            .centerY(dateTimeView.centerYAnchor)
        cellBody.addSubviewWithAnchors(iconView, top: cellBody.topAnchor, trailing: cellBody.trailingAnchor, insets: OSInsets.smallInsets)
        cellBody.addSubviewBelow(itemView, upperView: iconView, insets: .smallInsets)
            .connectToBottom(of: cellBody, inset: OSInsets.smallInset)
        setupItemView()
        setupTimeLabel()
        setupMapIcon()
        setupIconView()
    }
    
    func setupTimeLabel(){
    }
    
    func setupMapIcon(){
    }
    
    func setupIconView(){
    }
    
    func setupItemView(){
    }
    
}


