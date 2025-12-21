/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

class RouteMenuView: UIView {
    
    var startRouteButton = UIButton().asImageButton("marker-green")
    var endRouteButton = UIButton().asImageButton("marker-red")
    var cancelRouteButton = UIButton().asIconButton("xmark.circle", color: .darkText)
    
    let insets = UIEdgeInsets(top: 20, left: 5, bottom: 20, right: 5)
    
    func setup(){
        setBackground(.transparentColor)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        startRouteButton.addAction(UIAction(){ action in
            MainViewController.shared.enableRouteStart()
        }, for: .touchDown)
        endRouteButton.addAction(UIAction(){ action in
            MainViewController.shared.enableRouteEnd()
        }, for: .touchDown)
        cancelRouteButton.addAction(UIAction(){ action in
            MainViewController.shared.cancelRoute()
        }, for: .touchDown)
        addSubviewBelow(startRouteButton, insets: insets)
        addSubviewBelow(endRouteButton, upperView: startRouteButton, insets: insets)
        addSubviewBelow(cancelRouteButton, upperView: endRouteButton, insets: insets)
            .connectToBottom(of: self, inset: 20)
    }
    
    func updateState(_ state: RouteMenuState){
        switch state {
        case .idle:
            startRouteButton.unsetRoundedBorders()
            endRouteButton.unsetRoundedBorders()
        case .setStart:
            startRouteButton.setRoundedBorders()
            endRouteButton.unsetRoundedBorders()
        case .setEnd:
            startRouteButton.unsetRoundedBorders()
            endRouteButton.setRoundedBorders()
        }
    }
    
}




