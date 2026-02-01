/*
 OSM Maps (Mac)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation

class RouteLayerView: LayerView {
    
    var route: Route? = nil
    
    var routeMarkerViews = Array<RouteMarkerView>()
    private var waypointMarkerViews = Array<RouteMarkerView>()
    
    override func setupView(){
        setupRouteMarkerViews()
    }
    
    override func updateScale(_ scale: CGFloat){
        self.scale = scale
        for marker in routeMarkerViews{
            marker.updatePosition(scale: scale)
        }
        for marker in waypointMarkerViews{
            marker.updatePosition(scale: scale)
        }
        refresh()
    }
    
    override func updateContent(_ scale: CGFloat){
        self.scale = scale
        setupRouteMarkerViews()
    }
    
    func setupRouteMarkerViews(){
        removeRouteMarkerViews()
        isHidden = !VisibleRoute.shared.anyRoutePointsSet
        for idx in 0..<VisibleRoute.shared.routePoints.count{
            let coord = VisibleRoute.shared.routePoints[idx]?.coordinate
            var col = ""
            switch idx{
            case 0:
                col = "marker-green"
                break;
            case VisibleRoute.shared.routePoints.count - 1:
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
            routeMarkerViews.append(marker)
        }
        needsLayout = true
    }
    
    func setMarkerCoordinate(idx: Int, coordinate: CLLocationCoordinate2D){
        //Log.info("setMarkerCoordinate")
        if idx < routeMarkerViews.count{
            let marker = routeMarkerViews[idx]
            marker.coordinate = coordinate
            marker.isHidden = false
            marker.updatePosition(scale: scale)
        }
    }
    
    private func removeRouteMarkerViews(){
        for mv in routeMarkerViews{
            mv.removeFromSuperview()
        }
        routeMarkerViews.removeAll()
    }
    
    private func removeWaypointMarkerViews(){
        for mv in waypointMarkerViews{
            mv.removeFromSuperview()
        }
        waypointMarkerViews.removeAll()
    }
    
    func setRoute(route: Route?){
        self.route = route
        removeWaypointMarkerViews()
        if let route = route{
            for i in 1..<route.waypoints.count - 1{
                let waypoint = route.waypoints[i]
                let marker = RouteMarkerView(coordinate: waypoint.coordinate, image: MapDefaults.routeMarkerIcon)
                marker.frame = RouteMarkerView.centerBaseFrame
                addSubview(marker)
                marker.updatePosition(scale: scale)
                waypointMarkerViews.append(marker)
            }
        }
        needsDisplay = true
    }
    
    override func reset(){
        removeRouteMarkerViews()
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




