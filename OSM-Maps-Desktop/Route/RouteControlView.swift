/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation

class RouteControlView : NSView{
    
    static var selectBackground: NSColor = .white.withAlphaComponent(0.2)
    
    var routeTypeSelector = NSSegmentedControl()
    
    var markerButtons: [NavMarkerButton] = []
    var pointPanel = NSView()
    let cancelRouteButton = NSButton().asTextButton("cancel".localize(), color: .labelColor)
    let saveRouteButton = NSButton().asTextButton("save".localize(), color: .systemBlue)
    var addPointButton: NSButton!
    var removePointButton: NSButton!
    var scrollView = NSScrollView()
    var statusPanel = NSView()
    var waypointLines = [WaypointLine]()
    
    func setup(){
        backgroundColor = .black
        let label = NSTextField(labelWithString: "route".localize()).asHeadline()
        addSubviewBelow(label)
        routeTypeSelector.segmentCount = 3
        routeTypeSelector.setImage(NSImage(systemSymbolName: "car", accessibilityDescription: nil)!, forSegment: 0)
        routeTypeSelector.setImage(NSImage(systemSymbolName: "bicycle", accessibilityDescription: nil)!, forSegment: 1)
        routeTypeSelector.setImage(NSImage(systemSymbolName: "figure.walk", accessibilityDescription: nil)!, forSegment: 2)
        routeTypeSelector.selectedSegment = 0
        routeTypeSelector.target = self
        routeTypeSelector.action = #selector(routeTypeChanged)
        addSubviewBelow(routeTypeSelector, upperView: label)
        addSubviewWithAnchors(pointPanel, top: routeTypeSelector.bottomAnchor, leading: leadingAnchor, insets: .zero)
        addPointButton = NSButton(icon: "plus.circle", target: self, action: #selector(addPoint))
        addPointButton.toolTip = "addPoint".localize()
        addSubviewWithAnchors(addPointButton, top: routeTypeSelector.bottomAnchor, leading: pointPanel.trailingAnchor)
        removePointButton = NSButton(icon: "minus.circle", target: self, action: #selector(removePoint))
        removePointButton.toolTip = "removePoint".localize()
        addSubviewWithAnchors(removePointButton, top: routeTypeSelector.bottomAnchor, leading: addPointButton.trailingAnchor, trailing: trailingAnchor)
        scrollView.asVerticalScrollView(contentView: statusPanel)
        addSubviewBelow(scrollView, upperView: pointPanel, insets: NSEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
        cancelRouteButton.target = self
        cancelRouteButton.action = #selector(cancelRoute)
        addSubviewWithAnchors(cancelRouteButton, top: scrollView.bottomAnchor, leading: leadingAnchor, trailing: centerXAnchor, bottom: bottomAnchor, insets: .defaultInsets)
        saveRouteButton.target = self
        saveRouteButton.action = #selector(saveRoute)
        addSubviewWithAnchors(saveRouteButton, top: scrollView.bottomAnchor,  leading: centerXAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: .defaultInsets)
        update()
    }
    
    func update(){
        isHidden = VisibleRoute.shared.route == nil
        updateButtons()
        updateState()
        updateStatusPanel()
    }
    
    func updateButtons(){
        pointPanel.removeAllSubviews()
        markerButtons.removeAll()
        if let route = VisibleRoute.shared.route {
            var lastView: NSView? = nil
            for i in 0..<route.navigationPoints.count {
                var col = ""
                switch i {
                case 0:
                    col = "marker-green"
                case route.navigationPoints.count-1:
                    col = "marker-red"
                default:
                    col = "marker-yellow"
                }
                let button = NavMarkerButton(idx: i, image: NSImage(named: col)!, target: self, action: #selector(markerButtonPressed))
                pointPanel.addSubviewToRight(button, leftView: lastView)
                markerButtons.append(button)
                lastView = button
            }
        }
    }
    
    func updateState(){
        if let route = VisibleRoute.shared.route, route.isEditable{
            pointPanel.isHidden = false
            for idx in 0..<markerButtons.count{
                let btn = markerButtons[idx]
                if idx == VisibleRoute.shared.selectedIndex{
                    btn.backgroundColor = Self.selectBackground
                }
                else{
                    btn.backgroundColor = .clear
                }
            }
            saveRouteButton.isHidden = !route.isComplete
            addPointButton.isHidden = false
            removePointButton.isHidden = false
            addPointButton.isEnabled = route.navigationPoints.count < VisibleRoute.MAX_NAVIGATION_POINTS
            removePointButton.isEnabled = route.navigationPoints.count > 2
        }
        else{
            saveRouteButton.isHidden = true
            pointPanel.isHidden = true
            addPointButton.isHidden = true
            removePointButton.isHidden = true
        }
    }
    
    @objc func addPoint() {
        MainViewController.shared.addRoutePoint()
    }
    
    @objc func removePoint() {
        MainViewController.shared.removeRoutePoint()
    }
    
    @objc func markerButtonPressed(_ sender: Any?) {
        if let button = sender as? NavMarkerButton{
            let idx = button.idx
            MainViewController.shared.markerButtonPressed(idx)
        }
    }
    
    @objc func saveRoute(){
        MainViewController.shared.saveRoute()
    }
    
    @objc func cancelRoute(){
        MainViewController.shared.cancelRoute()
    }
    
    func updateStatusPanel(){
        statusPanel.removeAllSubviews()
        waypointLines.removeAll()
        if let route = VisibleRoute.shared.route {
            var linePanel = newLine(iconName: "arrow.right", text: "\(route.distance)m")
            statusPanel.addSubviewBelow(linePanel, insets: NSEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
            var lastLine: NSView = linePanel
            linePanel = newLine(iconName: "stopwatch", text: route.duration.hmsString())
            statusPanel.addSubviewBelow(linePanel, upperView: lastLine, insets: NSEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
            lastLine = linePanel
            let label = NSTextField(labelWithString: "waypoints".localize()).asHeadline()
            statusPanel.addSubviewBelow(label, upperView: lastLine, insets: .defaultInsets)
            lastLine = label
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
                if iconName.isEmpty {
                    waypointLine.setupView(text: str)
                }
                else{
                    waypointLine.setupView(iconName: iconName, text: str)
                }
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

class NavMarkerButton: NSButton {
    
    var idx: Int
    
    init(idx: Int, image: NSImage, target: NSView, action: Selector) {
        self.idx = idx
        super.init(frame: .zero)
        self.image = image
        self.target = target
        self.action = action
        self.bezelStyle = .smallSquare
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
