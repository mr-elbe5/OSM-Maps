/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

import UIKit

class IconText : UIView{
    
    var label: UILabel!
    
    func setupView(icon: String, text: String){
        if let image = UIImage(systemName: icon){
            let imageView = UIImageView(image: image)
            addSubviewToRight(imageView, insets: .zero)
            label = UILabel(text: text)
            addSubviewToRight(label, leftView: imageView, insets: OSInsets(top: 0, left: OSInsets.defaultInset, bottom: 0, right: 0))
                .connectToRight(of: self)
        }
    }
    
    @discardableResult
    func withTextColor(_ color: UIColor) -> IconText{
        label.textColor = color
        return self
    }
    
}

