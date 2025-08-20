/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

import UIKit

class LabeledTextInput : UIView, UITextFieldDelegate{
    
    private var label = UILabel()
    private var textField = UITextField()
    
    var text: String{
        get{
            return textField.text ?? ""
        }
        set{
            textField.text = newValue
        }
    }
    
    func setupView(labelText: String, text: String = "", inline: Bool = false){
        label.text = labelText
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        addSubview(label)
        
        textField.setDefaults()
        textField.text = text
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        addSubview(textField)
        
        if inline{
            label.setAnchors(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor)
            textField.setAnchors(top: topAnchor, bottom: bottomAnchor)
                .leading(label.trailingAnchor, inset: OSInsets.defaultInset)
        }
        else{
            label.setAnchors(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor)
            textField.setAnchors(top: label.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
        }
    }
    
    func setSecureEntry(){
        textField.isSecureTextEntry = true
    }
    
    func updateText(_ text: String){
        textField.text = text
    }
    
    @discardableResult
    func withTextColor(_ color: UIColor) -> LabeledTextInput{
        label.textColor = color
        return self
    }
    
}

