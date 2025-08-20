/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */


import AppKit

class LabeledText : NSView{
    
    private var label = NSTextField(labelWithString: "").asLabel()
    private var textField = NSTextField(labelWithString: "").asLabel()
    
    var text: String{
        get{
            return textField.stringValue
        }
        set{
            textField.stringValue = newValue
        }
    }
    
    func setupView(labelText: String, text: String = "", isHorizontal : Bool = true){
        label.stringValue = labelText
        addSubview(label)
        textField.stringValue = text
        addSubview(textField)
        if isHorizontal{
            label.setAnchors(top: topAnchor, leading: leadingAnchor, trailing: centerXAnchor, bottom: bottomAnchor)
            textField.setAnchors(top: topAnchor, leading: centerXAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
        }
        else{
            label.setAnchors(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor)
            textField.setAnchors(top: label.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
        }
    }
    
}


