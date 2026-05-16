/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation
import OSLog

import UniformTypeIdentifiers

class MapView: NSView {
    
    var menuView = MapMenuView()
    var scrollView = MapScrollView()
    var crossLocationView = NSButton().asIconButton("plus.circle", color: .black)
    
    override func setupView(){
        addSubviewWithAnchors(menuView, top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, insets: .zero)
            .width(40)
        menuView.setupView()
        
        addSubviewWithAnchors(scrollView, top: topAnchor, leading: menuView.trailingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: .zero)
        scrollView.setupView()
        scrollView.mapDelegate = self
        crossLocationView.isBordered = false
        crossLocationView.font = .systemFont(ofSize: 20)
        crossLocationView.target = self
        crossLocationView.action = #selector(showCrossLocationMenu)
        addSubviewCentered(crossLocationView, centerX: scrollView.centerXAnchor, centerY: scrollView.centerYAnchor)
        crossLocationView.isHidden = !DesktopSettings.shared.showCenterButton
        
    }
    
    func setDefaultLocation(){
        scrollView.zoomTo(zoom: MapStatus.shared.zoom, at: MapStatus.shared.centerCoordinate)
    }
    
    func refresh(){
        scrollView.tileLayerView.refresh()
    }
    
    func showLocationOnMap(coordinate: CLLocationCoordinate2D) {
        scrollView.scrollToScreenCenter(coordinate: coordinate)
        scrollView.updateLayerPositions()
    }
    
    func showMapRectOnMap(worldRect: CGRect) {
        let viewSize = bounds.scaleBy(0.9).size
        scrollView.zoomTo(zoom: World.getZoomToFit(worldRect: worldRect, scaledSize: viewSize))
        scrollView.scrollToScreenCenter(coordinate: worldRect.centerCoordinate)
        //Logger.info("scrollZoom = \(MapStatus.shared.zoom)")
        //Logger.info("scrollScale = \(scrollView.zoomScale)")
        scrollView.updateLayerPositions()
    }
    
    @objc func showCrossLocationMenu(){
        let menu = CrossButtonMenu()
        menu.popover.show(relativeTo: self.crossLocationView.frame, of: self, preferredEdge: .maxY)
    }
    
    func zoomIn() {
        scrollView.zoomIn()
    }
    
    func zoomOut() {
        scrollView.zoomOut()
    }
    
    func toggleCross() {
        crossLocationView.isHidden = !crossLocationView.isHidden
        DesktopSettings.shared.showCenterButton = !crossLocationView.isHidden
        DesktopSettings.shared.save()
    }
    
    func toggleMarkers() {
        DesktopSettings.shared.showMapPins = !DesktopSettings.shared.showMapPins
        DesktopSettings.shared.save()
        scrollView.updateItemLayerContent()
    }
    
    func refreshMap() {
        refresh()
        scrollView.updateLayerPositions()
    }
    
    func importTrack() {
        scrollView.updateItemLayerContent()
    }
    
}

extension MapView : MapScrollViewDelegate{
    
    func didScroll(to coordinate: CLLocationCoordinate2D) {
        MapStatus.shared.centerCoordinate = coordinate
        MapStatus.shared.save()
    }
    
    func didZoom(to zoom: Int) {
        MapStatus.shared.scale = World.downScale(to: zoom)
        MapStatus.shared.save()
        scrollView.updateLayerContents()
    }
    
    override func autoscroll(with event: NSEvent) -> Bool {
        scrollView.autoscroll(with: event)
    }
    
}

