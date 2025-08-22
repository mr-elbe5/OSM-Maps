/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

extension UITextView{
    
    @objc func setDefaults(){
        autocapitalizationType = .none
        autocorrectionType = .no
        font = UIFont.preferredFont(forTextStyle: .body)
        adjustsFontForContentSizeCategory = true
        layer.borderColor = UIColor.systemGray.cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = 5
        layer.masksToBounds = true
    }
    
    func setKeyboardToolbar(doneTitle: String){
        let toolbar : UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: doneTitle, style: .done, target: self, action: #selector(toolbarAction))
        toolbar.items = [flexSpace, done]
        toolbar.sizeToFit()
        self.inputAccessoryView = toolbar
    }
    
    @objc func toolbarAction(){
        self.resignFirstResponder()
    }
    
    @discardableResult
    func withTextColor(_ color: UIColor) -> UITextView{
        self.textColor = color
        return self
    }
    
    @discardableResult
    func withBackgroundColor(_ color: UIColor) -> UITextView{
        self.backgroundColor = color
        return self
    }
    
}

