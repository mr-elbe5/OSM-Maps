/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class IconView : UIImageView{
    
    init(icon: String, tintColor: UIColor = .label, backgroundColor: UIColor? = nil){
        super.init(frame: .zero)
        self.image = UIImage(systemName: icon)
        self.tintColor = tintColor
        self.scaleBy(1.25)
        if let bgcol = backgroundColor{
            self.backgroundColor = bgcol
            layer.cornerRadius = 5
            layer.masksToBounds = true
        }
    }
    
    init(image: String, tintColor: UIColor = .label, backgroundColor: UIColor? = nil){
        super.init(frame: .zero)
        self.image = UIImage(named: image)
        self.tintColor = tintColor
        if let bgcol = backgroundColor{
            self.backgroundColor = bgcol
            layer.cornerRadius = 5
            layer.masksToBounds = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

