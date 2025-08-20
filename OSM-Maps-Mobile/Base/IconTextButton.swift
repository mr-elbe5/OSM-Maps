/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class IconTextButton : UIButton{
    
    var hasBorder: Bool
    
    init(icon: String, text: String, tintColor: UIColor = .label, backgroundColor: UIColor? = .tertiarySystemBackground, withBorder: Bool = true){
        self.hasBorder = withBorder
        super.init(frame: .zero)
        setImage(UIImage(systemName: icon)?.withTintColor(tintColor, renderingMode: .alwaysOriginal), for: .normal)
        setTitle(text, for: .normal)
        setTitleColor(tintColor, for: .normal)
        self.tintColor = tintColor
        if let bgcol = backgroundColor{
            self.backgroundColor = bgcol
        }
        if hasBorder{
            setGrayRoundedBorders()
        }
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
