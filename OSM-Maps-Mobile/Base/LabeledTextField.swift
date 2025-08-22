/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class LabeledTextField : UIView{
    
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
    
    func setupView(labelText: String, text: String = "", isHorizontal : Bool = true){
        label.text = labelText
        label.textAlignment = .left
        label.numberOfLines = 0
        addSubview(label)
        
        textField.setDefaults()
        textField.text = text
        textField.backgroundColor = .tertiarySystemBackground
        label.font = .preferredFont(forTextStyle: .headline)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        addSubview(textField)
        textField.setKeyboardToolbar(doneTitle: "done".localize(table: "Base"))
        
        if isHorizontal{
            label.setAnchors(top: topAnchor, leading: leadingAnchor, trailing: centerXAnchor, bottom: bottomAnchor)
            textField.setAnchors(top: topAnchor, leading: centerXAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
        }
        else{
            label.setAnchors(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor)
            textField.setAnchors(top: label.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
        }
    }
    
    func updateText(_ text: String){
        textField.text = text
    }
    
    @discardableResult
    func withTextColor(_ color: UIColor) -> LabeledTextField{
        label.textColor = color
        return self
    }
    
}

