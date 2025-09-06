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
        backgroundColor = .black
        cellBody.setRoundedBorders()
        cellBody.backgroundColor = .darkColor
        addSubviewFilling(cellBody, insets: OSInsets.smallInsets)
        setupCellBody()
    }
    
    func setupCellBody(){
        dateTimeView.setBackground(.clear)
        cellBody.addSubviewWithAnchors(dateTimeView, top: cellBody.topAnchor, leading: cellBody.leadingAnchor, insets: OSInsets.smallInsets)
        timeLabel.textColor = .lightColor
        dateTimeView.addSubviewFilling(timeLabel, insets: OSInsets.smallInsets)
        mapIconView.setBackground(.clear)
        cellBody.addSubviewWithAnchors(mapIconView, leading: dateTimeView.trailingAnchor, insets: .zero)
            .centerY(dateTimeView.centerYAnchor)
        iconView.setBackground(.clear)
        cellBody.addSubviewWithAnchors(iconView, top: cellBody.topAnchor, trailing: cellBody.trailingAnchor, insets: OSInsets.smallInsets)
        cellBody.addSubviewBelow(itemView, upperView: iconView, insets: .smallInsets)
            .connectToBottom(of: cellBody, inset: OSInsets.smallInset)
        itemView.setBackground(.black).setRoundedBorders()
        setupTimeLabel()
        setupMapIcon()
        updateIconView()
        updateItemView()
    }
    
    func setupTimeLabel(){
    }
    
    func setupMapIcon(){
    }
    
    func updateIconView(){
    }
    
    func updateItemView(){
    }
    
}


