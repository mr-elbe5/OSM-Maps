/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

import UIKit

class LabeledText : UIView{
    
    private var label = UILabel()
    private var textField = UILabel()
    
    var text: String{
        get{
            return textField.text ?? ""
        }
        set{
            textField.text = newValue
        }
    }
    
    func setupView(labelText: String, text: String = "", inline : Bool = true){
        label.text = labelText
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        addSubview(label)
        textField.text = text
        addSubview(textField)
        if inline{
            label.setAnchors(top: topAnchor, leading: leadingAnchor, trailing: centerXAnchor, bottom: bottomAnchor, insets: OSInsets.defaultInsets)
            textField.setAnchors(top: topAnchor, leading: centerXAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: OSInsets.defaultInsets)
        }
        else{
            label.setAnchors(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: OSInsets.defaultInsets)
            textField.setAnchors(top: label.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: OSInsets.defaultInsets)
        }
    }
    
    @discardableResult
    func withTextColor(_ color: UIColor) -> LabeledText{
        label.textColor = color
        textField.textColor = color
        return self
    }
    
}

