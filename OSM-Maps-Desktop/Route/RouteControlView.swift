/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation

class RouteControlView : NSView{
    
    var controlPanel = NSView()
    var routeTypeSelector = NSSegmentedControl()
    
    let cancelRouteButton = NSButton().asIconButton("xmark", color: .labelColor)
    let saveRouteButton = NSButton().asTextButton("save".localize(), color: .systemBlue)
    
    var statusScrollView = NSScrollView()
    var statusPanel = NSView()
    var waypointLines = [WaypointLine]()
    
    func setup(){
        controlPanel.backgroundColor = .transparentColor
        addSubviewBelow(controlPanel, insets: .zero)
        routeTypeSelector.setImage(NSImage(systemSymbolName: "car", accessibilityDescription: nil)!, forSegment: 0)
        routeTypeSelector.setImage(NSImage(systemSymbolName: "bicycle", accessibilityDescription: nil)!, forSegment: 1)
        routeTypeSelector.setImage(NSImage(systemSymbolName: "figure.walk", accessibilityDescription: nil)!, forSegment: 2)
        routeTypeSelector.selectedSegment = 0
        routeTypeSelector.target = self
        routeTypeSelector.action = #selector(routeTypeChanged)
        controlPanel.addSubviewToRight(routeTypeSelector, insets: OSInsets.smallInsets)
        controlPanel.addSubviewWithAnchors(saveRouteButton, leading: routeTypeSelector.trailingAnchor, insets: .defaultInsets)
            .centerY(routeTypeSelector.centerYAnchor)
        
        saveRouteButton.target = self
        saveRouteButton.action = #selector(saveRoute)
        controlPanel.addSubviewWithAnchors(cancelRouteButton, trailing: controlPanel.trailingAnchor, insets: .defaultInsets)
            .centerY(routeTypeSelector.centerYAnchor)
        cancelRouteButton.target = self
        cancelRouteButton.action = #selector(cancelRoute)
        addSubviewBelow(statusScrollView, upperView: controlPanel, insets: .zero)
            .connectToBottom(of: self)
        statusPanel.backgroundColor = .transparentColor
        statusScrollView.addSubviewWithAnchors(statusPanel, top: statusScrollView.topAnchor, leading: statusScrollView.leadingAnchor, bottom: statusScrollView.bottomAnchor, insets: .zero)
            .width(statusScrollView.widthAnchor, inset: 0)
    }
    
    @objc func saveRoute(){
        MainViewController.shared.saveRoute()
    }
    
    @objc func cancelRoute(){
        MainViewController.shared.cancelRoute()
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
    
    func newLine(iconName: String, text: String) -> NSView {
        let linePanel = NSView()
        let icon = NSImageView(image: NSImage(systemSymbolName: iconName, accessibilityDescription: nil)!)
        linePanel.addSubviewToRight(icon, insets: OSInsets.smallInsets)
        let label = NSTextField(labelWithString: text)
        linePanel.addSubviewToRight(label, leftView: icon, insets: OSInsets.smallInsets)
        return linePanel
    }
    
    func newLine(text: String) -> NSView {
        let linePanel = NSView()
        let label = NSTextField(labelWithString: text)
        linePanel.addSubviewToRight(label, insets: OSInsets.smallInsets)
        return linePanel
    }
    
    @objc func routeTypeChanged(){
        let idx = self.routeTypeSelector.indexOfSelectedItem
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
    
    class WaypointLine : NSView {
        
        let idx: Int
        
        let label = NSTextField(labelWithString: "")
        
        init(idx: Int) {
            self.idx = idx
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupView(text: String) {
            label.stringValue = text
            addSubviewFilling(label, insets: OSInsets.smallInsets)
        }
        
        func setupView(iconName: String, text: String) {
            let icon = NSImageView(image: NSImage(systemSymbolName: iconName, accessibilityDescription: nil)!)
            addSubviewToRight(icon, insets: OSInsets.smallInsets)
            label.stringValue = text
            addSubviewToRight(label, leftView: icon, insets: OSInsets.smallInsets)
        }
        
        func activate(_ flag: Bool){
            label.font = flag ? NSFont.boldSystemFont(ofSize: label.font!.pointSize) : NSFont.systemFont(ofSize: label.font!.pointSize)
        }
        
    }
}
