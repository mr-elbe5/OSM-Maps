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
    var createRouteButton: NSButton!
    
    
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
        createRouteButton = NSButton(icon: "point.topright.arrow.triangle.backward.to.point.bottomleft.scurvepath", target: self, action: #selector(createRoute))
        createRouteButton.toolTip = "createRoute".localize()
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
        addSubviewBelow(createRouteButton, upperView: searchButton, insets: insets)
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
    
    @objc func createRoute() {
        MainViewController.shared.createRoute()
    }
    
}
    
