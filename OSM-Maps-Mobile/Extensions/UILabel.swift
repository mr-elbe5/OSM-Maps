/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

extension UILabel{
    
    func setDefaults(text : String){
        self.text = text
    }
    
    convenience init(text: String){
        self.init()
        self.text = text
        numberOfLines = 0
        textColor = .label
    }
    
    convenience init(header: String){
        self.init()
        self.text = header
        font = .preferredFont(forTextStyle: .headline)
        numberOfLines = 0
        textColor = .label
    }
    
    convenience init(subheader: String){
        self.init()
        self.text = subheader
        font = .preferredFont(forTextStyle: .body)
        numberOfLines = 0
        textColor = .label
    }
    
    convenience init(hint: String){
        self.init()
        self.text = hint
        font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        numberOfLines = 0
        textColor = .label
    }
    
    @discardableResult
    func withTextColor(_ color: UIColor) -> UILabel{
        self.textColor = color
        return self
    }
    
}

