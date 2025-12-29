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
    
    func setup(){
        setBackground(.transparentColor)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        updateButtons()
    }
    
    func updateButtons(){
        removeAllSubviews()
        markerButtons.removeAll()
        var lastView: UIView? = nil
        for i in 0..<VisibleRoute.shared.routePoints.count {
            var col = ""
            switch i {
            case 0:
                col = "marker-green"
            case VisibleRoute.shared.routePoints.count-1:
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
        let addPointButton = UIButton().asIconButton("plus.circle")
        addSubviewBelow(addPointButton, upperView: lastView, insets: insets)
        addPointButton.addAction(UIAction(){ action in
            MainViewController.shared.addRoutePoint()
        }, for: .touchDown)
        let removePointButton = UIButton().asIconButton("minus.circle")
        addSubviewBelow(removePointButton, upperView: addPointButton, insets: insets)
        removePointButton.addAction(UIAction(){ action in
            MainViewController.shared.removeRoutePoint()
        }, for: .touchDown)
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
    }
    
}




