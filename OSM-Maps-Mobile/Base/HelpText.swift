/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

import UIKit

class HelpText : UIView{
    
    let label = UILabel()
    
    init(text: String){
        super.init(frame: .zero)
        label.text = text
        label.numberOfLines = 0
        label.textColor = .label
        addSubviewFilling(label, insets: UIEdgeInsets(top: OSInsets.defaultInset, left: 0, bottom: OSInsets.defaultInset, right: 0))
    }
    
    init(key: String){
        super.init(frame: .zero)
        label.text = key.localize(table: "Help")
        label.numberOfLines = 0
        label.textColor = .label
        addSubviewFilling(label, insets: UIEdgeInsets(top: OSInsets.defaultInset, left: 0, bottom: OSInsets.defaultInset, right: 0))
    }
    
    init(headerKey: String){
        super.init(frame: .zero)
        label.text = headerKey.localize(table: "Help")
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        label.textColor = .label
        addSubviewFilling(label, insets: UIEdgeInsets(top: OSInsets.defaultInset, left: 0, bottom: OSInsets.defaultInset, right: 0))
    }
    
    init(icon: String, key: String, iconColor : UIColor = .label){
        super.init(frame: .zero)
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = iconColor
        let iconText = UILabel(text: key.localize(table: "Help"))
        iconText.numberOfLines = 0
        iconText.textColor = .label
        addSubviewWithAnchors(iconView, top:topAnchor, leading:leadingAnchor, insets: .zero)
        addSubviewToRight(iconText, leftView: iconView, insets: OSInsets.flatInsets)
            .connectToRight(of: self)
    }
    
    init(icon: String, headerKey: String, iconColor : UIColor = .label){
        super.init(frame: .zero)
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = iconColor
        let label = UILabel(text: headerKey.localize(table: "Help"))
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        addSubviewWithAnchors(iconView, top:topAnchor, leading:leadingAnchor, insets: .zero)
        addSubviewToRight(label, leftView: iconView, insets: OSInsets.flatInsets)
            .connectToRight(of: self)
    }
    
    init(image: String, key: String){
        super.init(frame: .zero)
        let iconView = UIImageView(image: UIImage(named: image))
        let iconText = UILabel(text: key.localize(table: "Help"))
        iconText.numberOfLines = 0
        iconText.textColor = .label
        addSubviewToRight(iconView, insets: .zero)
        addSubviewToRight(iconText, leftView: iconView, insets: OSInsets.flatInsets)
            .connectToRight(of: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

