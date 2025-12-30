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
    
    let cancelRouteButton = UIButton().asIconButton("xmark", color: .darkText)
    let saveRouteButton = UIButton().asTextButton("save".localize(), color: .systemBlue)
    
    var statusScrollView = UIScrollView()
    var statusPanel = UIView()
    var waypointLines = [WaypointLine]()
    
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
        controlPanel.addSubviewWithAnchors(saveRouteButton, leading: routeTypeSelector.trailingAnchor, insets: .defaultInsets)
            .centerY(routeTypeSelector.centerYAnchor)
        saveRouteButton.addAction(UIAction(){ action in
            MainViewController.shared.saveRoute()
        }, for: .touchDown)
        controlPanel.addSubviewWithAnchors(cancelRouteButton, trailing: controlPanel.trailingAnchor, insets: .defaultInsets)
            .centerY(routeTypeSelector.centerYAnchor)
        cancelRouteButton.addAction(UIAction(){ action in
            MainViewController.shared.cancelRoute()
        }, for: .touchDown)
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
        waypointLines.removeAll()
        if let route = VisibleRoute.shared.route {
            var linePanel = newLine(iconName: "arrow.right", text: "\(route.distance)m")
            statusPanel.addSubviewBelow(linePanel, insets: .zero)
            var lastLine = linePanel
            linePanel = newLine(iconName: "stopwatch", text: route.duration.hmsString())
            statusPanel.addSubviewBelow(linePanel, upperView: lastLine, insets: .zero)
            lastLine = linePanel
            var lastDistance = 0
            var waypointLine: WaypointLine!
            for i in 0..<route.waypoints.count {
                let waypoint = route.waypoints[i]
                if lastDistance > 0 {
                    linePanel = newLine(text: "\("after".localize()) \(lastDistance)m:")
                    statusPanel.addSubviewBelow(linePanel, upperView: lastLine, insets: .zero)
                    lastLine = linePanel
                }
                lastDistance = waypoint.distance
                let iconName: String = waypoint.iconName
                var str = waypoint.directionString
                if !waypoint.name.isEmpty {
                    str += "\("on".localize()) \(waypoint.name)"
                }
                waypointLine = WaypointLine(idx: i)
                waypointLine.setupView(iconName: iconName, text: str)
                statusPanel.addSubviewBelow(waypointLine, upperView: lastLine, insets: .zero)
                lastLine = waypointLine
                waypointLines.append(waypointLine)
            }
            lastLine.connectToBottom(of: statusPanel)
            saveRouteButton.isEnabled = true
        }
        else{
            saveRouteButton.isEnabled = false
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
    
    @objc func routeTypeChanged(){
        let idx = self.routeTypeSelector.selectedSegmentIndex
        Log.info(" idx \(idx)")
        let type = RouteType.getRouteType(idx: idx)
        Log.info(" type \(type.rawValue)")
        MainViewController.shared.setRouteType(type)
    }
    
    func activate(_ idx: Int){
        for waypointLine in waypointLines {
            waypointLine.activate(waypointLine.idx == idx)
        }
    }
    
    class WaypointLine : UIView {
        
        let idx: Int
        
        let label = UILabel()
        
        init(idx: Int) {
            self.idx = idx
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupView(text: String) {
            label.text = text
            addSubviewFilling(label, insets: OSInsets.smallInsets)
        }
        
        func setupView(iconName: String, text: String) {
            let icon = UIImageView(image: UIImage(systemName: iconName))
            icon.tintColor = .darkText
            addSubviewToRight(icon, insets: OSInsets.smallInsets)
            label.text = text
            addSubviewToRight(label, leftView: icon, insets: OSInsets.smallInsets)
        }
        
        func activate(_ flag: Bool){
            label.font = flag ? UIFont.boldSystemFont(ofSize: label.font.pointSize) : UIFont.systemFont(ofSize: label.font.pointSize)
        }
        
    }
}
