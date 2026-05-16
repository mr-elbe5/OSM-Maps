/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import OSLog

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
        routeLayerView.setupView()
        currentLocationView.backgroundColor = .clear
        addSubview(currentLocationView)
        addSubviewFilling(itemLayerView, insets: .zero)
        updateItemLayer()
        itemLayerView.isHidden = !Settings.shared.showMapPins
        crossButton.addAction(UIAction(){ action in
            let coordinate = self.scrollView.screenCenterCoordinate
            let controller = CrossMenuViewController(coordinate: coordinate, title: "crossLocation".localize())
            controller.modalPresentationStyle = .overCurrentContext
            MainViewController.shared.present(controller, animated: false)
        }, for: .touchDown)
        addSubviewCentered(crossButton, centerX: centerXAnchor, centerY: centerYAnchor)
        crossButton.isHidden = !Settings.shared.showCenterButton
        let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
    }
    
    @objc func handleDoubleTap() {
        MapStatus.shared.zoomIn()
        zoomToCurrentZoom()
    }
    
    func setStartLocation(){
        Logger.info("setting start location")
        Logger.info("zooming to \(MapStatus.shared.zoom)")
        scrollView.zoomTo(MapStatus.shared.zoom)
        Logger.info("moving to \(MapStatus.shared.centerCoordinate.debugString)")
        scrollView.scrollTo(MapStatus.shared.centerCoordinate)
        canUpdatePosition = true
    }
    
    func updateItemLayer(){
        itemLayerView.setupMarkerViews(zoom: MapStatus.shared.zoom, offset: contentOffset, scale: scrollView.zoomScale)
    }
    
    func updateItemPositions(){
        itemLayerView.updatePosition(offset: contentOffset, scale: scrollView.zoomScale)
    }
    
    func updateTrackLayer(){
        if VisibleTrack.shared.isPresent{
            trackLayerView.updatePosition(offset: contentOffset, scale: scrollView.zoomScale)
        }
        else{
            trackLayerView.setNeedsDisplay()
        }
    }
    
    func updateTrackPosition(){
        trackLayerView.updatePosition(offset: contentOffset, scale: scrollView.zoomScale)
    }
    
    func updateRouteLayer(){
        routeLayerView.updateView()
        routeLayerView.updatePosition(offset: contentOffset, scale: scrollView.zoomScale)
    }
    
    func updateRoutePosition(){
        routeLayerView.updatePosition(offset: contentOffset, scale: scrollView.zoomScale)
    }
    
    func updateCurrentDirection(){
        currentLocationView.updateDirection(direction: LocationStatus.shared.direction)
    }
    
    func updateCurrentLocationView(){
        currentLocationView.updateLocationPoint(location: LocationStatus.shared.location, offset: contentOffset, scale: zoomScale)
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
    
    func zoomToCurrentZoom(){
        Logger.info("zooming to \(MapStatus.shared.zoom)")
        scrollView.zoomTo(MapStatus.shared.zoom)
        updateCurrentLocationView()
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
        updateItemPositions()
        updateTrackPosition()
        updateRoutePosition()
        updateCurrentLocationView()
    }
    
    func didScroll() {
        scrollView.assertCenteredContent()
        updateMapStatus()
        updateItemPositions()
        updateTrackPosition()
        updateRoutePosition()
        updateCurrentLocationView()
    }
    
    func didFinishZooming() {
    }
    
}

