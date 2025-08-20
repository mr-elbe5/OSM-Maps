/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class TableSectionHeader : UIView{
    
    func setupView(title: String){
        let label = TableSectionHeaderLabel()
        label.backgroundColor = .tertiarySystemBackground
        label.text = title
        label.textColor = .label
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.setRoundedBorders(radius: 5)
        addSubviewCentered(label, centerX: self.centerXAnchor, centerY: self.centerYAnchor)
    }
    
}

class TableSectionHeaderLabel: UILabel {
    
    override var intrinsicContentSize: CGSize{
        return getExtendedIntrinsicContentSize(originalSize: super.intrinsicContentSize)
    }
    
}
