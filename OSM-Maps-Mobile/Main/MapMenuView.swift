/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

class MapMenuView: UIView {
    
    let insets = UIEdgeInsets(top: 20, left: 5, bottom: 20, right: 5)
    
    func setup(){
        setBackground(.transparentColor)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        let zoomInButton = UIButton().asIconButton("plus", color: .darkText)
        addSubviewBelow(zoomInButton, insets: insets)
        zoomInButton.addAction(UIAction(){ action in
            MainViewController.shared.zoomIn()
        }, for: .touchDown)
        
        let zoomOutButton = UIButton().asIconButton("minus", color: .darkText)
        addSubviewBelow(zoomOutButton, upperView: zoomInButton, insets: insets)
        zoomOutButton.addAction(UIAction(){ action in
            MainViewController.shared.zoomOut()
        }, for: .touchDown)
        let togglePinsButton = UIButton().asIconButton("mappin.slash", color: .darkText)
        addSubviewBelow(togglePinsButton, upperView: zoomOutButton, insets: insets)
        togglePinsButton.addAction(UIAction(){ action in
            MainViewController.shared.toggleMapPins()
        }, for: .touchDown)
        let hideRouteButton = UIButton().asImageButton("marker-gray")
        addSubviewBelow(hideRouteButton, upperView: togglePinsButton, insets: insets)
        hideRouteButton.addAction(UIAction(){ action in
            MainViewController.shared.hideRoute()
        }, for: .touchDown)
        let refreshButton = UIButton().asIconButton("arrow.clockwise", color: .darkText)
        addSubviewBelow(refreshButton, upperView: hideRouteButton, insets: insets)
            .connectToBottom(of: self, inset: 20)
        refreshButton.addAction(UIAction(){ action in
            MainViewController.shared.refreshMap()
        }, for: .touchDown)
    }
    
}






