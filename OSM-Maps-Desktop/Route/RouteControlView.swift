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
    
    var buttonPanel = NSView()
    var markerButtons: [NavMarkerButton] = []
    let cancelRouteButton = NSButton().asTextButton("cancel".localize(), color: .labelColor)
    let saveRouteButton = NSButton().asTextButton("save".localize(), color: .systemBlue)
    var addPointButton: NSButton!
    var removePointButton: NSButton!
    var scrollView = NSScrollView()
    var statusPanel = NSView()
    var routepointLines = [RoutepointLine]()
    
    func setup(){
        backgroundColor = .black
        let label = NSTextField(labelWithString: "route".localize()).asHeadline()
        addSubviewBelow(label)
        routeTypeSelector.segmentCount = 3
        routeTypeSelector.setImage(NSImage(systemSymbolName: "car", accessibilityDescription: nil)!, forSegment: 0)
        routeTypeSelector.setImage(NSImage(systemSymbolName: "bicycle", accessibilityDescription: nil)!, forSegment: 1)
        routeTypeSelector.setImage(NSImage(systemSymbolName: "figure.walk", accessibilityDescription: nil)!, forSegment: 2)
        routeTypeSelector.selectedSegment = RouteType.getRouteTypeIndex(type: DesktopSettings.shared.routeType)
        routeTypeSelector.target = self
        routeTypeSelector.action = #selector(routeTypeChanged)
        addSubviewBelow(routeTypeSelector, upperView: label)
        addSubviewBelow(buttonPanel, upperView: routeTypeSelector, insets: .zero)
        
        scrollView.asVerticalScrollView(contentView: statusPanel)
        addSubviewBelow(scrollView, upperView: buttonPanel, insets: NSEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
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
        needsDisplay = true
    }
    
    func updateButtons(){
        buttonPanel.removeAllSubviews()
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
                buttonPanel.addSubviewToRight(button, leftView: lastView)
                markerButtons.append(button)
                lastView = button
            }
            removePointButton = NSButton(icon: "minus.circle", target: self, action: #selector(removePoint))
            removePointButton.toolTip = "removePoint".localize()
            buttonPanel.addSubviewToLeft(removePointButton)
            addPointButton = NSButton(icon: "plus.circle", target: self, action: #selector(addPoint))
            addPointButton.toolTip = "addPoint".localize()
            buttonPanel.addSubviewToLeft(addPointButton, rightView: removePointButton)
        }
    }
    
    func updateState(){
        if let route = VisibleRoute.shared.route{
            if route.isEditable{
                for idx in 0..<markerButtons.count{
                    let btn = markerButtons[idx]
                    if idx == VisibleRoute.shared.selectedIndex{
                        btn.backgroundColor = .selectedControlColor
                    }
                    else{
                        btn.backgroundColor = .clear
                    }
                }
                routeTypeSelector.isHidden = false
                routeTypeSelector.isEnabled = true
                buttonPanel.isHidden = false
                saveRouteButton.isHidden = !route.isComplete
                addPointButton.isEnabled = route.navigationPoints.count < VisibleRoute.MAX_NAVIGATION_POINTS
                removePointButton.isEnabled = route.navigationPoints.count > 2
            }
            else{
                routeTypeSelector.isEnabled = false
                addPointButton.isEnabled = false
                removePointButton.isEnabled = false
                buttonPanel.isHidden = true
                saveRouteButton.isHidden = true
            }
        }
        else{
            routeTypeSelector.isHidden = true
            buttonPanel.isHidden = true
            saveRouteButton.isHidden = true
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
        MainViewController.shared.prepareRouteForSaving()
    }
    
    @objc func cancelRoute(){
        MainViewController.shared.cancelRoute()
    }
    
    func updateStatusPanel(){
        statusPanel.removeAllSubviews()
        routepointLines.removeAll()
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
            var routepointLine: RoutepointLine!
            for i in 0..<route.routepoints.count {
                let routepoint = route.routepoints[i]
                if lastDistance > 0 {
                    linePanel = newLine(text: "\("after".localize()) \(lastDistance)m:")
                    statusPanel.addSubviewBelow(linePanel, upperView: lastLine, insets: .zero)
                    lastLine = linePanel
                }
                lastDistance = routepoint.distance
                let iconName: String = routepoint.iconName
                var str = routepoint.directionString
                if !routepoint.name.isEmpty {
                    str += "\("on".localize()) \(routepoint.name)"
                }
                routepointLine = RoutepointLine(idx: i)
                if iconName.isEmpty {
                    routepointLine.setupView(text: str)
                }
                else{
                    routepointLine.setupView(iconName: iconName, text: str)
                }
                statusPanel.addSubviewBelow(routepointLine, upperView: lastLine, insets: .zero)
                routepointLines.append(routepointLine)
                lastLine = routepointLine
            }
            lastLine.connectToBottom(of: statusPanel)
            //Log.info("got \(routepointLines.count) routepoints")
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
        //Log.info(" idx \(idx)")
        let type = RouteType.getRouteType(idx: idx)
        //Log.info(" type \(type.rawValue)")
        DesktopSettings.shared.routeType = type
        DesktopSettings.shared.save()
        MainViewController.shared.setRouteType(type)
    }
    
    class RoutepointLine : NSView {
        
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
        self.imageScaling = .scaleProportionallyDown
        self.bezelStyle = .smallSquare
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
