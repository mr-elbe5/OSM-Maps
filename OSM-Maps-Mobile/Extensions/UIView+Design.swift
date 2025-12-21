/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

extension UIView{
    
    var isDarkMode: Bool {
        self.traitCollection.userInterfaceStyle == .dark
    }
    
    @discardableResult
    func setBackground(_ color:UIColor) -> UIView{
        backgroundColor = color
        return self
    }
    
    @discardableResult
    func setRoundedBorders(radius: CGFloat = 5) -> UIView{
        layer.borderWidth = 0.5
        layer.cornerRadius = radius
        layer.masksToBounds = true
        return self
    }
    
    @discardableResult
    func unsetRoundedBorders() -> UIView{
        layer.borderWidth = 0
        layer.cornerRadius = 0
        layer.masksToBounds = false
        return self
    }
    
    @discardableResult
    func setGrayRoundedBorders(radius: CGFloat = 5) -> UIView{
        layer.borderColor = UIColor.systemGray.cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = radius
        layer.masksToBounds = true
        return self
    }
    
}

