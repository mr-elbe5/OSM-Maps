/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

class RouteMenuView: UIView {
    
    let insets = UIEdgeInsets(top: 20, left: 5, bottom: 20, right: 5)
    
    var markerButtons: [UIButton] = []
    let addPointButton = UIButton().asIconButton("plus.circle")
    let removePointButton = UIButton().asIconButton("minus.circle")
    
    func setup(){
        setBackground(.transparentColor)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        addPointButton.addAction(UIAction(){ action in
            MainViewController.shared.addRoutePoint()
        }, for: .touchDown)
        removePointButton.addAction(UIAction(){ action in
            MainViewController.shared.removeRoutePoint()
        }, for: .touchDown)
        updateButtons()
    }
    
    func updateButtons(){
        removeAllSubviews()
        markerButtons.removeAll()
        var lastView: UIView? = nil
        for i in 0..<VisibleRoute.shared.navigationPoints.count {
            var col = ""
            switch i {
            case 0:
                col = "marker-green"
            case VisibleRoute.shared.navigationPoints.count-1:
                col = "marker-red"
            default:
                col = "marker-yellow"
            }
            let button = UIButton().asImageButton(col)
            addSubviewBelow(button, upperView: lastView, insets: insets)
            button.addAction(UIAction(){ action in
                MainViewController.shared.markerButtonPressed(i)
            }, for: .touchDown)
            markerButtons.append(button)
            lastView = button
        }
        addSubviewBelow(addPointButton, upperView: lastView, insets: insets)
        addSubviewBelow(removePointButton, upperView: addPointButton, insets: insets)
        removePointButton.connectToBottom(of: self, inset: 20)
    }
    
    func updateState(){
        for idx in 0..<markerButtons.count{
            let btn = markerButtons[idx]
            if idx == VisibleRoute.shared.selectedIndex{
                btn.setRoundedBorders()
            }
            else{
                btn.unsetRoundedBorders()
            }
        }
        addPointButton.isEnabled = VisibleRoute.shared.navigationPoints.count < VisibleRoute.MAX_NAVIGATION_POINTS
        removePointButton.isEnabled = VisibleRoute.shared.navigationPoints.count > 2
    }
    
}

