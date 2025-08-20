/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class TopMenuView: UIView {
    
    func setup(){
        setBackground(.transparentColor)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        let insets = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
        
        let crossButton = UIButton().asIconButton("plus.circle", color: .darkText)
        addSubviewToRight(crossButton, insets: insets)
        crossButton.addAction(UIAction(){ action in
            MainViewController.shared.toggleCross()
        }, for: .touchDown)
        
        let focusCurrentLocationButton = UIButton().asIconButton("record.circle", color: .darkText)
        addSubviewToRight(focusCurrentLocationButton, leftView: crossButton, insets: insets)
            .centerX(centerXAnchor)
        focusCurrentLocationButton.addAction(UIAction(){ action in
            MainViewController.shared.focusUserLocation()
        }, for: .touchDown)
        
        let searchButton = UIButton().asIconButton("magnifyingglass", color: .darkText)
        addSubviewToRight(searchButton, leftView: focusCurrentLocationButton, insets: insets)
            .connectToRight(of: self, inset: insets.right)
        searchButton.addAction(UIAction(){ action in
            MainViewController.shared.openSearch()
        }, for: .touchDown)
    }
    
}
