/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

import UIKit

class LabeledTextareaInput : UIView, UITextViewDelegate{
    
    private var label = UILabel()
    private var textView = TextareaInput(usingTextLayoutManager: false)
    
    var text: String{
        get{
            return textView.text ?? ""
        }
        set{
            textView.text = newValue
        }
    }
    
    func setupView(labelText: String, text: String = ""){
        label.text = labelText
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        addSubview(label)
        
        textView.setDefaults(placeholder: "...")
        textView.text = text
        textView.delegate = self
        addSubview(textView)
        
        label.setAnchors(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor)
        textView.setAnchors(top: label.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
    }
    
    func textViewDidChange(_ textView: UITextView){
        self.textView.textDidChange()
    }
    
    func updateText(_ text: String){
        self.textView.text = text
    }
    
    @discardableResult
    func withTextColor(_ color: UIColor) -> LabeledTextareaInput{
        label.textColor = color
        return self
    }
    
}

