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
        cancelButton.setImage(UIImage(systemName: "xmark.circle")?.withTintColor(.darkText, renderingMode: .alwaysOriginal), for: .normal)
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
            var linePanel = newLine(iconName: "arrow.right", text: "\(route.distance)m")
            statusPanel.addSubviewBelow(linePanel, insets: .zero)
            var lastLine = linePanel
            linePanel = newLine(iconName: "stopwatch", text: "\(route.duration)s")
            statusPanel.addSubviewBelow(linePanel, upperView: lastLine, insets: .zero)
            lastLine = linePanel
            var lastDistance = 0
            for i in 0..<route.waypoints.count {
                let waypoint = route.waypoints[i]
                if lastDistance > 0 {
                    linePanel = newLine(text: "nach \(lastDistance)m:")
                    statusPanel.addSubviewBelow(linePanel, upperView: lastLine, insets: .zero)
                    lastLine = linePanel
                }
                lastDistance = waypoint.distance
                var iconName: String = ""
                var str = ""
                switch waypoint.type {
                case "depart":
                    iconName = "flag"
                    str = "start".localize() + " "
                case "arrive":
                    iconName = "flag.pattern.checkered"
                    str = "arrived".localize() + " "
                case "turn":
                    switch waypoint.direction {
                    case "left", "slight left", "sharp left":
                        iconName = "arrow.left"
                        str = "turnLeft".localize() + " "
                        break
                    case "right", "slight right", "sharp right":
                        iconName = "arrow.right"
                        str = "turnRight".localize() + " "
                        break
                    default:
                        iconName = "arrow.up"
                        str = "straight".localize() + " "
                        break
                }
                default:
                    break
                }
                if !waypoint.name.isEmpty {
                    str += "\("on".localize()) \(waypoint.name)"
                }
                linePanel = newLine(iconName: iconName, text: str)
                statusPanel.addSubviewBelow(linePanel, upperView: lastLine, insets: .zero)
                lastLine = linePanel
            }
            lastLine.connectToBottom(of: statusPanel)
        }
    }
    
    func newLine(iconName: String, text: String) -> UIView {
        let linePanel = UIView()
        let icon = UIImageView(image: UIImage(systemName: iconName))
        icon.tintColor = .darkText
        linePanel.addSubviewToRight(icon, insets: OSInsets.smallInsets)
        let label = UILabel()
        label.text = text
        linePanel.addSubviewToRight(label, leftView: icon, insets: OSInsets.smallInsets)
        return linePanel
    }
    
    func newLine(text: String) -> UIView {
        let linePanel = UIView()
        let label = UILabel()
        label.text = text
        linePanel.addSubviewToRight(label, insets: OSInsets.smallInsets)
        return linePanel
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
