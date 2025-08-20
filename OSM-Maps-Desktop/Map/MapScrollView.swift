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
        mapWorldView.addSubviewFilling(tileLayerView, insets: .zero)
        mapWorldView.addSubviewFilling(trackLayerView, insets: .zero)
        trackLayerView.isHidden = true
        mapWorldView.addSubviewFilling(itemLayerView, insets: .zero)
        itemLayerView.dragDelegate = self
        updateItemLayer()
        addScrollNotifications()
    }
    
    func updateItemLayer(){
        itemLayerView.setupMarkerViews(zoom: MapStatus.shared.zoom, scale: zoomScale)
    }
    
    func updateTrackLayer(){
        trackLayerView.update(scale: zoomScale)
    }
    
    func showTrack(_ show: Bool){
        if show{
            trackLayerView.isHidden = false
            trackLayerView.update(scale: zoomScale)
        }
        else{
            trackLayerView.isHidden = true
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
            updateItemLayer()
            if VisibleTrack.shared.isPresent{
                updateTrackLayer()
            }
        }
        else if dy < 0.0{
            zoomOut()
            updateItemLayer()
            if VisibleTrack.shared.isPresent{
                updateTrackLayer()
            }
        }
    }
    
    @objc override func scrollViewDidScroll(){
        MapStatus.shared.centerCoordinate = screenCenterCoordinate
        trackLayerView.update(scale: zoomScale)
        mapDelegate?.didScroll(to: screenCenterCoordinate)
    }
    
}

extension MapScrollView: DragDelegate{
    
    func mouseDragged(dx: CGFloat, dy: CGFloat){
        scrollBy(dx: -dx, dy: -dy)
        MapStatus.shared.centerCoordinate = screenCenterCoordinate
        mapDelegate?.didScroll(to: screenCenterCoordinate)
    }
    
}



