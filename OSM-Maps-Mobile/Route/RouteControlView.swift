/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

class RouteControlView : UIView{
    
    var controlPanel = UIView()
    var routeTypeSelector = UISegmentedControl()
    
    var statusPanel = UIView()
    var distanceLabel = UILabel(text: "0 m")
    var durationLabel = UILabel(text: "00:00")
    
    func setup(){
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        controlPanel.backgroundColor = .systemBackground
        addSubviewBelow(controlPanel)
        
        routeTypeSelector.insertSegment(with: UIImage(systemName: "car"), at: 0, animated: false)
        routeTypeSelector.insertSegment(with: UIImage(systemName: "bicycle"), at: 1, animated: false)
        routeTypeSelector.insertSegment(with: UIImage(systemName: "figure.walk"), at: 2, animated: false)
        routeTypeSelector.selectedSegmentIndex = 0
        routeTypeSelector.addTarget(self, action: #selector(routeTypeChanged), for: .valueChanged)
        controlPanel.addSubviewToRight(routeTypeSelector, insets: OSInsets.smallInsets)
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelRoute), for: .touchDown)
        controlPanel.addSubviewToRight(cancelButton, leftView: routeTypeSelector)
        
        statusPanel.backgroundColor = .systemBackground
        addSubviewBelow(statusPanel, upperView: controlPanel)
            .connectToBottom(of: self)
        
        var linePanel = UIView()
        let distanceIcon = UIImageView(image: UIImage(systemName: "arrow.right"))
        distanceIcon.tintColor = .darkText
        linePanel.addSubviewToRight(distanceIcon, insets: OSInsets.smallInsets)
        distanceLabel.textColor = .darkText
        linePanel.addSubviewToRight(distanceLabel, leftView: distanceIcon, insets: OSInsets.smallInsets)
        statusPanel.addSubviewBelow(linePanel)
            .connectToBottom(of: statusPanel)
    }
    
    func showRoutePanel(){
        isHidden = false
        updateRoutePanel()
    }
    
    func updateRoutePanel(){
        
    }
    
    @objc func routeTypeChanged(){
        MainViewController.shared.setRouteType(RouteType.getRouteType(idx: self.routeTypeSelector.selectedSegmentIndex))
    }
    
    @objc func cancelRoute(){
        MainViewController.shared.cancelRoute()
        isHidden = true
    }
    
}
