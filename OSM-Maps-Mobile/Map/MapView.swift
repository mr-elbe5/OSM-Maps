/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

class MapView: UIView {
    
    var scrollView = MapScrollView()
    var trackLayerView = TrackLayerView()
    var routeLayerView = RouteLayerView()
    var itemLayerView = MapItemLayerView()
    var currentLocationView = CurrentLocationView(frame: CurrentLocationView.frameRect)
    var crossButton = UIButton().asIconButton("plus.circle", color: .darkText)
    
    var canUpdatePosition = false
    
    var zoom: Int {
        scrollView.zoom
    }
    
    var zoomScale: CGFloat {
        scrollView.zoomScale
    }
    
    var contentOffset : CGPoint{
        scrollView.contentOffset
    }
    
    func setup(){
        backgroundColor = .white
        scrollView.setup()
        scrollView.mapScrollViewDelegate = self
        addSubviewFilling(scrollView, insets: .zero)
        trackLayerView.backgroundColor = .clear
        addSubviewFilling(trackLayerView, insets: .zero)
        routeLayerView.backgroundColor = .clear
        addSubviewFilling(routeLayerView, insets: .zero)
        currentLocationView.backgroundColor = .clear
        addSubview(currentLocationView)
        addSubviewFilling(itemLayerView, insets: .zero)
        updateItemLayer()
        crossButton.addAction(UIAction(){ action in
            let coordinate = self.scrollView.screenCenterCoordinate
            let controller = CrossMenuViewController(coordinate: coordinate, title: "crossLocation".localize())
            controller.modalPresentationStyle = .overCurrentContext
            MainViewController.shared.present(controller, animated: false)
        }, for: .touchDown)
        addSubviewCentered(crossButton, centerX: centerXAnchor, centerY: centerYAnchor)
        crossButton.isHidden = !Preferences.shared.showCenterButton
        let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
    }
    
    @objc func handleDoubleTap() {
        MapStatus.shared.zoomIn()
        zoomToCurrentZoom()
    }
    
    func setStartLocation(){
        Log.info("setting start location")
        Log.info("zooming to \(MapStatus.shared.zoom)")
        scrollView.zoomTo(MapStatus.shared.zoom)
        Log.info("moving to \(MapStatus.shared.centerCoordinate.debugString)")
        scrollView.scrollTo(MapStatus.shared.centerCoordinate)
        //updateLocationLayer()
        canUpdatePosition = true
    }
    
    func updateItemLayer(){
        itemLayerView.setupMarkerViews(zoom: MapStatus.shared.zoom, offset: contentOffset, scale: scrollView.zoomScale)
    }
    
    func updateItemPositions(){
        itemLayerView.updatePosition(offset: contentOffset, scale: scrollView.zoomScale)
    }
    
    func updateTrackPosition(){
        trackLayerView.updatePosition(offset: contentOffset, scale: scrollView.zoomScale)
    }
    
    func updateRoutePosition(){
        routeLayerView.updatePosition(offset: contentOffset, scale: scrollView.zoomScale)
    }
    
    func zoomToCurrentZoom(){
        Log.info("zooming to \(MapStatus.shared.zoom)")
        scrollView.zoomTo(MapStatus.shared.zoom)
        updateCurrentLocationView()
    }
    
    func updateCurrentDirection(){
        currentLocationView.updateDirection(direction: LocationStatus.shared.direction)
    }
    
    func updateCurrentLocationView(){
        currentLocationView.updateLocationPoint(location: LocationStatus.shared.location, offset: contentOffset, scale: zoomScale)
    }
    
    func updateTrackLayer(){
        if VisibleTrack.shared.isPresent{
            trackLayerView.updatePosition(offset: contentOffset, scale: scrollView.zoomScale)
        }
        else{
            trackLayerView.setNeedsDisplay()
        }
    }
    
    func updateRouteLayer(){
        if VisibleRoute.shared.isPresent{
            routeLayerView.updatePosition(offset: contentOffset, scale: scrollView.zoomScale)
        }
        else{
            routeLayerView.setNeedsDisplay()
        }
    }
    
    func refresh(){
        scrollView.tileLayerView.refresh()
        updateItemLayer()
    }
    
    func clearTiles(){
        scrollView.clearTiles()
    }
    
    func focusUserLocation() {
        scrollTo(LocationStatus.shared.location.coordinate)
    }
    
    func scrollTo(_ coordinate: CLLocationCoordinate2D){
        scrollView.scrollTo(coordinate)
    }
    
    func zoomTo(_ zoom: Int, animated: Bool = false){
        scrollView.zoomTo(zoom)
    }
    
    func zoomAndScrollTo(_ zoom: Int, _ coordinate: CLLocationCoordinate2D){
        scrollView.zoomAndScrollTo(zoom, coordinate)
    }
    
    func updateMapStatus(){
        if canUpdatePosition{
            MapStatus.shared.centerCoordinate = scrollView.screenCenterCoordinate
            MapStatus.shared.save()
        }
    }
    
}

extension MapView: MapScrollViewDelegate{
    
    func didZoom() {
        MapStatus.shared.scale = zoomScale
        updateItemLayer()
        updateCurrentLocationView()
    }
    
    func didScroll() {
        scrollView.assertCenteredContent()
        updateMapStatus()
        updateItemLayer()
        updateTrackLayer()
        updateRouteLayer()
        updateCurrentLocationView()
    }
    
    func didFinishZooming() {
        updateItemLayer()
        updateCurrentLocationView()
        updateTrackLayer()
        updateRouteLayer()
    }
    
}

