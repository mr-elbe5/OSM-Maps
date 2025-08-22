/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

extension UILabel{
    
    convenience init(text: String, color: UIColor? = nil){
        self.init()
        self.text = text
        numberOfLines = 0
        if let color = color{
            self.textColor = color
        }
    }
    
    convenience init(header: String, color: UIColor? = nil){
        self.init()
        self.text = header
        font = .preferredFont(forTextStyle: .headline)
        numberOfLines = 0
        if let color = color{
            self.textColor = color
        }
    }
    
    convenience init(subheader: String, color: UIColor? = nil){
        self.init()
        self.text = subheader
        font = .preferredFont(forTextStyle: .body)
        numberOfLines = 0
        if let color = color{
            self.textColor = color
        }
    }
    
    convenience init(hint: String, color: UIColor? = nil){
        self.init()
        self.text = hint
        font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        numberOfLines = 0
        if let color = color{
            self.textColor = color
        }
    }
    
}

