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
        trackLayerView.isHidden = true
        mapWorldView.addSubviewFilling(trackLayerView, insets: .zero)
        
        routeLayerView.setupView()
        routeLayerView.isHidden = true
        mapWorldView.addSubviewFilling(routeLayerView, insets: .zero)
        
        itemLayerView.setupView()
        itemLayerView.clickDelegate = self
        itemLayerView.dragDelegate = self
        mapWorldView.addSubviewFilling(itemLayerView, insets: .zero)
        
        updateLayerPositions()
        addScrollNotifications()
    }
    
    func updateItemLayer(){
        itemLayerView.updateContent(scale: zoomScale)
    }
    
    func updateItemPositions(){
        itemLayerView.updatePosition(scale: zoomScale)
    }
    
    func updateTrackLayer(){
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
    
    func updateRouteLayer(){
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
    
    func showItemLayer(_ show: Bool){
        showLayer(itemLayerView, show)
    }
    
    func showTrackLayer(_ show: Bool){
        showLayer(trackLayerView, show)
    }
    
    func showRouteLayer(_ show: Bool){
        showLayer(routeLayerView, show)
    }
    
    func showLayer(_ layer: LayerView, _ show: Bool){
        if show{
            layer.isHidden = false
            layer.updateContent(scale: zoomScale)
        }
        else{
            layer.reset()
            layer.isHidden = true
        }
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
        updateLayerPositions()
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



