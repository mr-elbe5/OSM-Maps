/*
 OSM Maps (Mac)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation

class RouteLayerView: LayerView {
    
    var route: Route? = nil
    
    var navigationMarkerViews = Array<RouteMarkerView>()
    private var waypointMarkerViews = Array<RouteMarkerView>()
    
    override func setupView(){
        setupNavigationMarkers()
    }
    
    override func updateScale(_ scale: CGFloat){
        self.scale = scale
        for marker in navigationMarkerViews{
            marker.updatePosition(scale: scale)
        }
        for marker in waypointMarkerViews{
            marker.updatePosition(scale: scale)
        }
        refresh()
    }
    
    override func updateContent(_ scale: CGFloat){
        self.scale = scale
        setupNavigationMarkers()
        setupWaypointMarkers()
        needsDisplay = true
    }
    
    func setupNavigationMarkers(){
        removeNavigationMarkerViews()
        isHidden = !VisibleRoute.shared.anyNavigationPointsSet
        for idx in 0..<VisibleRoute.shared.navigationPoints.count{
            let coord = VisibleRoute.shared.navigationPoints[idx]?.coordinate
            var col = ""
            switch idx{
            case 0:
                col = "marker-green"
                break;
            case VisibleRoute.shared.navigationPoints.count - 1:
                col = "marker-red"
                break;
            default:
                col = "marker-yellow"
            }
            let marker = RouteMarkerView(coordinate: coord ?? .zero, image: NSImage(named: col)!)
            marker.baseFrame = RouteMarkerView.upperBaseFrame
            Log.info("coord \(marker.coordinate)")
            addSubview(marker)
            marker.isHidden = (coord == nil)
            marker.updatePosition(scale: scale)
            navigationMarkerViews.append(marker)
        }
        needsLayout = true
    }
    
    func setMarkerCoordinate(idx: Int, coordinate: CLLocationCoordinate2D){
        //Log.info("setMarkerCoordinate")
        if idx < navigationMarkerViews.count{
            let marker = navigationMarkerViews[idx]
            marker.coordinate = coordinate
            marker.isHidden = false
            marker.updatePosition(scale: scale)
        }
    }
    
    private func removeNavigationMarkerViews(){
        for mv in navigationMarkerViews{
            mv.removeFromSuperview()
        }
        navigationMarkerViews.removeAll()
    }
    
    private func removeWaypointMarkerViews(){
        for mv in waypointMarkerViews{
            mv.removeFromSuperview()
        }
        waypointMarkerViews.removeAll()
    }
    
    func setRoute(route: Route?){
        self.route = route
        setupWaypointMarkers()
        needsDisplay = true
    }
    
    func setupWaypointMarkers(){
        removeWaypointMarkerViews()
        if let route = route{
            for i in 1..<route.waypoints.count - 1{
                let waypoint = route.waypoints[i]
                let marker = RouteMarkerView(coordinate: waypoint.coordinate, image: MapDefaults.waypointMarkerIcon)
                marker.frame = RouteMarkerView.centerBaseFrame
                addSubview(marker)
                marker.updatePosition(scale: scale)
                waypointMarkerViews.append(marker)
            }
        }
    }
    
    override func reset(){
        removeNavigationMarkerViews()
        removeWaypointMarkerViews()
        route = nil
        needsDisplay = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if let route = route{
            var drawPoints = Array<CGPoint>()
            for idx in 0..<route.routepoints.count{
                let point = route.routepoints[idx]
                let mapPoint = CGPoint(point.coordinate)
                let drawPoint = CGPoint(x: mapPoint.x*scale , y: mapPoint.y*scale)
                drawPoints.append(drawPoint)
            }
            let ctx = NSGraphicsContext.current!.cgContext
            if !drawPoints.isEmpty{
                ctx.beginPath()
                ctx.move(to: drawPoints[0])
                for idx in 1..<drawPoints.count{
                    ctx.addLine(to: drawPoints[idx])
                }
                ctx.setStrokeColor(NSColor.systemBlue.cgColor)
                ctx.setLineWidth(4.0)
                ctx.drawPath(using: .stroke)
                ctx.setFillColor(NSColor.black.cgColor)
            }
        }
    }
    
}




