/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation

class MapScrollView : PlainMapScrollView{
    
    override var zoom: Int{
        get{
            MapStatus.shared.zoom
        }
        set{
            MapStatus.shared.scale = World.downScale(to: newValue)
        }
    }
    
    override var zoomScale : Double{
        get{
            MapStatus.shared.scale
        }
    }
    
    var trackLayerView = TrackLayerView()
    var routeLayerView = RouteLayerView()
    var itemLayerView = ItemLayerView()
    
    override func setupView(){
        hasVerticalScroller = false
        hasHorizontalScroller = false
        let clipView = FlippedClipView()
        contentView = clipView
        contentView.setAnchors(top:clipView.topAnchor, leading: clipView.leadingAnchor, trailing: clipView.trailingAnchor)
        clipView.drawsBackground = false
        mapWorldView.frame = World.scaledWorld(zoom: MapStatus.shared.zoom)
        documentView = mapWorldView
        
        tileLayerView.setupView()
        mapWorldView.addSubviewFilling(tileLayerView, insets: .zero)
        
        trackLayerView.setupView()
        mapWorldView.addSubviewFilling(trackLayerView, insets: .zero)
        
        routeLayerView.setupView()
        mapWorldView.addSubviewFilling(routeLayerView, insets: .zero)
        
        itemLayerView.setupView()
        itemLayerView.clickDelegate = self
        itemLayerView.dragDelegate = self
        mapWorldView.addSubviewFilling(itemLayerView, insets: .zero)
        
        updateLayerPositions()
        addScrollNotifications()
    }
    
    func updateItemLayerContent(){
        itemLayerView.updateContent(scale: zoomScale)
    }
    
    func updateItemPositions(){
        itemLayerView.updatePosition(scale: zoomScale)
    }
    
    func updateTrackLayerContent(){
        if VisibleTrack.shared.isPresent{
            trackLayerView.updatePosition(scale: zoomScale)
        }
        else{
            trackLayerView.needsDisplay = true
        }
    }
    
    func updateTrackPosition(){
        trackLayerView.updatePosition(scale: zoomScale)
    }
    
    func updateRouteLayerContent(){
        routeLayerView.updateContent(scale: zoomScale)
    }
    
    func updateRoutePosition(){
        routeLayerView.updatePosition(scale: zoomScale)
    }
    
    func updateLayerPositions(){
        updateItemPositions()
        updateTrackPosition()
        updateRoutePosition()
    }
    
    func updateLayerContents(){
        updateItemLayerContent()
        updateTrackLayerContent()
        updateRouteLayerContent()
    }
    
    override func scrollWheel(with event: NSEvent) {
        if !event.modifierFlags.contains(.option){
            super.scrollWheel(with: event)
            return
        }
        let dy = event.deltaY
        if dy > 0.0 {
            zoomIn()
        }
        else if dy < 0.0{
            zoomOut()
        }
        updateLayerContents()
    }
    
    @objc override func scrollViewDidScroll(){
        MapStatus.shared.centerCoordinate = screenCenterCoordinate
        updateLayerPositions()
        mapDelegate?.didScroll(to: screenCenterCoordinate)
    }
    
}

extension MapScrollView: ClickDelegate {
    
    public func clicked(with event: NSEvent) {
        if let route = VisibleRoute.shared.route{
            var pnt = event.locationInWindow
            pnt = convert(event.locationInWindow, from: nil)
            let idx = VisibleRoute.shared.selectedIndex
            if idx != -1, idx < route.navigationPoints.count{
                let coordinate = worldPoint(screenPoint: pnt).coordinate
                MainViewController.shared.setRouteCoordinate(idx: idx, coordinate: coordinate)
            }
        }
    }
    
}

extension MapScrollView: DragDelegate{
    
    func mouseDragged(dx: CGFloat, dy: CGFloat){
        scrollBy(dx: -dx, dy: -dy)
        MapStatus.shared.centerCoordinate = screenCenterCoordinate
        mapDelegate?.didScroll(to: screenCenterCoordinate)
    }
    
}



