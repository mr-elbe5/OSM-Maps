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
    
    var statusScrollView = UIScrollView()
    var statusPanel = UIView()
    
    func setup(){
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        controlPanel.backgroundColor = .transparentColor
        addSubviewBelow(controlPanel, insets: .zero)
        
        routeTypeSelector.insertSegment(with: UIImage(systemName: "car"), at: 0, animated: false)
        routeTypeSelector.insertSegment(with: UIImage(systemName: "bicycle"), at: 1, animated: false)
        routeTypeSelector.insertSegment(with: UIImage(systemName: "figure.walk"), at: 2, animated: false)
        routeTypeSelector.selectedSegmentIndex = 0
        routeTypeSelector.addTarget(self, action: #selector(routeTypeChanged), for: .valueChanged)
        controlPanel.addSubviewToRight(routeTypeSelector, insets: OSInsets.smallInsets)
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setImage(UIImage(systemName: "xmark.circle")?.withTintColor(.darkText), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelRoute), for: .touchDown)
        controlPanel.addSubviewToRight(cancelButton, leftView: routeTypeSelector)
        
        statusScrollView.scrollsToTop = false
        addSubviewBelow(statusScrollView, upperView: controlPanel, insets: .zero)
            .height(200)
            .connectToBottom(of: self)
        statusPanel.backgroundColor = .transparentColor
        statusScrollView.addSubviewWithAnchors(statusPanel, top: statusScrollView.topAnchor, leading: statusScrollView.leadingAnchor, bottom: statusScrollView.bottomAnchor, insets: .zero)
            .width(statusScrollView.widthAnchor, inset: 0)
    }
    
    func setupStatusPanel(){
        statusPanel.removeAllSubviews()
        if let route = VisibleRoute.shared.route {
            var linePanel = UIView()
            var icon = UIImageView(image: UIImage(systemName: "arrow.right"))
            icon.tintColor = .darkText
            linePanel.addSubviewToRight(icon, insets: OSInsets.smallInsets)
            var label = UILabel()
            label.textColor = .darkText
            label.text = "\(route.distance)m"
            linePanel.addSubviewToRight(label, leftView: icon, insets: OSInsets.smallInsets)
            statusPanel.addSubviewBelow(linePanel)
            var lastLine = linePanel
            linePanel = UIView()
            icon = UIImageView(image: UIImage(systemName: "stopwatch"))
            icon.tintColor = .darkText
            linePanel.addSubviewToRight(icon, insets: OSInsets.smallInsets)
            label = UILabel()
            label.textColor = .darkText
            label.text = "\(route.duration)s"
            linePanel.addSubviewToRight(label, leftView: icon, insets: OSInsets.smallInsets)
            statusPanel.addSubviewBelow(linePanel, upperView: lastLine)
            lastLine = linePanel
            lastLine.connectToBottom(of: statusPanel)
        }
    }
    
    func showRoutePanel(){
        isHidden = false
        updateRoutePanel()
    }
    
    func updateRoutePanel(){
        
    }
    
    @objc func routeTypeChanged(){
        let idx = self.routeTypeSelector.selectedSegmentIndex
        Log.info(" idx \(idx)")
        let type = RouteType.getRouteType(idx: idx)
        Log.info(" type \(type.rawValue)")
        MainViewController.shared.setRouteType(type)
    }
    
    @objc func cancelRoute(){
        MainViewController.shared.cancelRoute()
        isHidden = true
    }
    
}
