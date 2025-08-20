/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class LabeledCheckbox : Checkbox{
    
    func setup(title: String, index: Int = 0, isOn: Bool = false){
        self.index = index
        self.title = title
        self.isOn = isOn
        label.font = .preferredFont(forTextStyle: .headline)
        checkboxIcon.delegate = self
        addSubviewWithAnchors(label, top: topAnchor, leading: leadingAnchor, insets: OSInsets.narrowInsets)
        let vw = UIView()
        vw.setRoundedBorders()
        addSubviewToLeft(vw, insets: OSInsets.narrowInsets)
        vw.addSubviewFilling(checkboxIcon, insets: OSInsets.smallInsets)
    }
    
    func setupInline(title: String, index: Int = 0, isOn: Bool = false){
        self.index = index
        self.title = title
        self.isOn = isOn
        label.font = .preferredFont(forTextStyle: .headline)
        checkboxIcon.delegate = self
        let vw = UIView()
        vw.setRoundedBorders()
        addSubviewToLeft(vw, insets: OSInsets.narrowInsets)
        vw.addSubviewFilling(checkboxIcon, insets: OSInsets.smallInsets)
        addSubviewToLeft(label, rightView: vw, insets: OSInsets.defaultInsets)
    }
    
    @discardableResult
    override func withTextColor(_ color: UIColor) -> LabeledCheckbox{
        label.textColor = color
        super.withTextColor(color)
        return self
    }
    
}
