/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

class MapMenuView: NSView{
    
    var zoomInButton: NSButton!
    var zoomOutButton: NSButton!
    var toggleCrossButton: NSButton!
    var centerButton: NSButton!
    var refreshButton: NSButton!
    var searchButton: NSButton!
    let markerContainer = NSView()
    var markerButtons: [MarkerMenuButton] = []
    var addPointButton: NSButton!
    var removePointButton: NSButton!
    
    
    var insets = OSInsets(top: OSInsets.defaultInset, left: OSInsets.smallInset, bottom: OSInsets.defaultInset, right: OSInsets.smallInset)
    
    init(){
        super.init(frame: .zero)
        
        zoomInButton = NSButton(icon: "plus", target: self, action: #selector(zoomIn))
        zoomInButton.toolTip = "zoomIn".localize()
        zoomOutButton = NSButton(icon: "minus", target: self, action: #selector(zoomOut))
        zoomOutButton.toolTip = "zoomOut".localize()
        toggleCrossButton = NSButton(icon: "plus.circle", target: self, action: #selector(toggleCross))
        toggleCrossButton.toolTip = "toggleCross".localize()
        refreshButton = NSButton(icon: "arrow.clockwise", target: self, action: #selector(refreshMap))
        refreshButton.toolTip = "refresh".localize()
        searchButton = NSButton(icon: "magnifyingglass", target: self, action: #selector(openSearch))
        searchButton.toolTip = "search".localize()
        addPointButton = NSButton(icon: "plus.circle", target: self, action: #selector(addPoint))
        addPointButton.toolTip = "addPoint".localize()
        removePointButton = NSButton(icon: "minus.circle", target: self, action: #selector(removePoint))
        removePointButton.toolTip = "removePoint".localize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView(){
        addSubviewBelow(zoomInButton, insets: insets)
        addSubviewBelow(zoomOutButton, upperView: zoomInButton, insets: insets)
        addSubviewBelow(toggleCrossButton, upperView: zoomOutButton, insets: insets)
        addSubviewBelow(refreshButton, upperView: toggleCrossButton, insets: insets)
        addSubviewBelow(searchButton, upperView: refreshButton, insets: insets)
        addSubviewBelow(markerContainer, upperView: searchButton, insets: .zero)
        addSubviewBelow(addPointButton, upperView: markerContainer, insets: insets)
        addSubviewBelow(removePointButton, upperView: addPointButton, insets: insets)
        updateButtons()
    }
    
    func updateButtons(){
        markerContainer.removeAllSubviews()
        markerButtons.removeAll()
        var lastView: NSView? = nil
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
            let button = MarkerMenuButton(image: NSImage(named: col)!, target: self, action: #selector(markerButtonPressed))
            button.idx = i
            markerContainer.addSubviewBelow(button, upperView: lastView, insets: insets)
            markerButtons.append(button)
            lastView = button
        }
        lastView?.connectToBottom(of: markerContainer)
    }
    
    func updateState(){
        for idx in 0..<markerButtons.count{
            let btn = markerButtons[idx]
            if idx == VisibleRoute.shared.selectedIndex{
                btn.setWhiteRoundedBorders()
            }
            else{
                btn.unsetRoundedBorders()
            }
        }
    }
    
    
    @objc func zoomIn(){
        MainViewController.shared.zoomIn()
    }
    
    @objc func zoomOut(){
        MainViewController.shared.zoomOut()
    }
    
    @objc func toggleCross() {
        MainViewController.shared.toggleCross()
    }
    
    @objc func refreshMap() {
        MainViewController.shared.refreshMap()
    }
    
    @objc func openSearch() {
        MainViewController.shared.openSearch()
    }
    
    @objc func addPoint() {
        MainViewController.shared.addRoutePoint()
    }
    
    @objc func removePoint() {
        MainViewController.shared.removeRoutePoint()
    }
    
    @objc func markerButtonPressed(_ sender: Any?) {
        if let button = sender as? MarkerMenuButton{
            let idx = button.idx
            MainViewController.shared.markerButtonPressed(idx)
        }
    }
    
}

class MarkerMenuButton: NSButton {
    
    var idx: Int = 0
    
}
    
