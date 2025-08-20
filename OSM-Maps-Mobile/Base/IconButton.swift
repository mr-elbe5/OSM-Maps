/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class IconButton : UIButton{
    
    var hasBorder: Bool
    
    init(icon: String, tintColor: UIColor = .label, backgroundColor: UIColor? = nil, withBorder: Bool = false){
        self.hasBorder = withBorder
        super.init(frame: .zero)
        setImage(UIImage(systemName: icon)?.withTintColor(tintColor, renderingMode: .alwaysOriginal), for: .normal)
        setImage(UIImage(systemName: icon)?.withTintColor(.systemGray, renderingMode: .alwaysOriginal), for: .disabled)
        self.scaleBy(1.25)
        if let bgcol = backgroundColor{
            self.backgroundColor = bgcol
            layer.cornerRadius = 5
            layer.masksToBounds = true
        }
        if hasBorder{
            setGrayRoundedBorders()
        }
    }
    
    init(image: String, tintColor: UIColor = .label, backgroundColor: UIColor? = nil, withBorder: Bool = true){
        self.hasBorder = withBorder
        super.init(frame: .zero)
        setImage(UIImage(named: image), for: .normal)
        if let bgcol = backgroundColor{
            self.backgroundColor = bgcol
            layer.cornerRadius = 5
            layer.masksToBounds = true
        }
        if hasBorder{
            setGrayRoundedBorders()
        }
    }
    
    func setIcon(icon: String, tintColor: UIColor = .label){
        setImage(UIImage(systemName: icon)?.withTintColor(tintColor, renderingMode: .alwaysOriginal), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize{
        if hasBorder{
            let size = getExtendedIntrinsicContentSize(originalSize: super.intrinsicContentSize)
            return CGSize(width: size.width + 2*OSInsets.defaultInset, height: size.height)
        }
        return super.intrinsicContentSize
    }
    
}

