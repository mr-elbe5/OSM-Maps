/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

protocol MapScrollViewDelegate{
    func didScroll()
    func didZoom()
    func didFinishZooming()
}

class MapScrollView: UIScrollView {
    
    var zoom: Int{
        return World.zoomLevelAtDownScale(scale: zoomScale)
    }
    
    var tileLayerView = TileLayerView()
    
    var mapScrollViewDelegate: MapScrollViewDelegate?
    
    var screenCenter : CGPoint{
        CGPoint(x: bounds.width/2, y: bounds.height/2)
    }
    
    var screenCenterMapPoint : CGPoint{
        worldPoint(screenPoint: screenCenter)
    }
    
    var screenCenterCoordinate : CLLocationCoordinate2D{
        screenCenterMapPoint.coordinate
    }
    
    func coordinate(screenPoint : CGPoint) -> CLLocationCoordinate2D{
        worldPoint(screenPoint: screenPoint).coordinate
    }
    
    var tileRegion : TileRegion{
        TileRegion(topLeft: coordinate(screenPoint: CGPoint(x: 0, y: 0)), bottomRight: coordinate(screenPoint: CGPoint(x: visibleSize.width, y: visibleSize.height)), maxZoom: World.maxZoom)
    }
    
    func setup(){
        backgroundColor = .white
        isScrollEnabled = true
        isDirectionalLockEnabled = false
        isPagingEnabled = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        scrollsToTop = false
        bounces = false
        bouncesZoom = false
        maximumZoomScale = 1.0
        minimumZoomScale = World.downScale(to: World.minZoom)
        contentSize = World.scrollableWorldSize
        tileLayerView.backgroundColor = .white
        addSubview(tileLayerView)
        tileLayerView.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
        delegate = self
    }

    func clearTiles(){
        tileLayerView.tileLayer.setNeedsDisplay()
    }
    
    func worldPoint(screenPoint : CGPoint) -> CGPoint{
        //division by zoomScale is upScale
        CGPoint(x: (screenPoint.x + contentOffset.x)/zoomScale, y: (screenPoint.y + contentOffset.y)/zoomScale).normalizedPoint
    }
    
    func scrollTo(_ coordinate: CLLocationCoordinate2D){
        //Log.debug("scrolling to \(coordinate)")
        let screenCenter = screenCenter
        //Log.debug("screen center is \(screenCenter)")
        let x = World.scaledX(coordinate.longitude, downScale: zoomScale) + World.scaledExtent(downScale: zoomScale)
        let y = World.scaledY(coordinate.latitude, downScale: zoomScale)
        let pnt = CGPoint(x: min(max(0, x - screenCenter.x), contentSize.width - visibleSize.width),
                          y: min(max(0, y - screenCenter.y), contentSize.height - visibleSize.height))
        //Log.debug("screen offset is \(pnt)")
        setContentOffset(pnt, animated: true)
    }
    
    func zoomTo(_ zoom: Int, animated: Bool = false){
        //Log.debug("zooming to \(zoom)")
        let scale = World.downScale(to: zoom)
        //Log.debug("setting zoom scale to \(scale)")
        setZoomScale(scale, animated: false)
    }
    
    func zoomAndScrollTo(_ zoom: Int, _ coordinate: CLLocationCoordinate2D){
        //Log.debug("zooming to \(zoom) and scrolling to \(coordinate)")
        let scale = World.downScale(to: zoom)
        setZoomScale(scale, animated: false)
        let screenCenter = screenCenter
        //Log.debug("screen center is \(screenCenter)")
        let x = World.scaledX(coordinate.longitude, downScale: scale) + World.scaledExtent(downScale: scale)
        let y = World.scaledY(coordinate.latitude, downScale: scale)
        let pnt = CGPoint(x: min(max(0, x - screenCenter.x), contentSize.width - visibleSize.width),
                          y: min(max(0, y - screenCenter.y), contentSize.height - visibleSize.height))
        //Log.debug("screen offset is \(pnt)")
        setContentOffset(pnt, animated: true)
    }
    
}

extension MapScrollView: UIScrollViewDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        tileLayerView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        mapScrollViewDelegate?.didZoom()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        mapScrollViewDelegate?.didFinishZooming()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isDragging, Settings.shared.followLocation{
            Settings.shared.followLocation = false
        }
        mapScrollViewDelegate?.didScroll()
    }
    
    // for infinite scroll using 3 * content width
    func assertCenteredContent(){
        if contentOffset.x >= 2*contentSize.width/3{
            contentOffset.x -= contentSize.width/3
        }
        else if contentOffset.x < contentSize.width/3{
            contentOffset.x += contentSize.width/3
        }
    }
    
}







