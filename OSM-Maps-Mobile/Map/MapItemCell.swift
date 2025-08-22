/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

class MapItemCell: TableViewCell{
    
    var dateTimeView = UIView()
    var timeLabel = UILabel(text: "", color: .darkColor)
    var mapIconView = UIImageView()
    
    var useShortDate = false
    
    override func setupCellBody(){
        cellBody.setRoundedBorders()
        dateTimeView.setBackground(.iconViewBackgroundColor).setGrayRoundedBorders()
        cellBody.addSubviewWithAnchors(dateTimeView, top: cellBody.topAnchor, leading: cellBody.leadingAnchor, insets: OSInsets.smallInsets)
        dateTimeView.addSubviewFilling(timeLabel, insets: OSInsets.smallInsets)
        cellBody.addSubviewWithAnchors(mapIconView, leading: dateTimeView.trailingAnchor, insets: OSInsets.smallInsets)
            .centerY(dateTimeView.centerYAnchor)
        iconView.setBackground(.iconViewBackgroundColor).setGrayRoundedBorders()
        cellBody.addSubviewWithAnchors(iconView, top: cellBody.topAnchor, trailing: cellBody.trailingAnchor, insets: OSInsets.smallInsets)
        cellBody.addSubviewBelow(itemView, upperView: iconView, insets: .smallInsets)
            .connectToBottom(of: cellBody, inset: OSInsets.smallInset)
    }
    
    override func updateCell(){
        updateItemView()
        updateTimeLabel()
        updateMapIcon()
        updateIconView()
    }
    
    func updateTimeLabel(){
    }
    
    func updateMapIcon(){
    }
    
}


