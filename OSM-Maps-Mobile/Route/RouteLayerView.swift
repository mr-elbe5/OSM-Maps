/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

class RouteLayerView: UIView {
    
    var route: Route? = nil
    
    var offset : CGPoint? = nil
    var scale : CGFloat = 0.0
    
    var routeMarkerViews = Array<RouteMarkerView>()
    private var waypointMarkerViews = Array<RouteMarkerView>()
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return VisibleRoute.shared.selectedIndex != -1
    }
    
    func setupView(){
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        updateRouteMarkerViews()
    }
    
    func removeRouteMarkerViews(){
        for mv in routeMarkerViews{
            removeSubview(mv)
        }
        routeMarkerViews.removeAll()
    }
    
    func updateRouteMarkerViews(){
        removeRouteMarkerViews()
        for idx in 0..<VisibleRoute.shared.coordinates.count{
            let coord = VisibleRoute.shared.coordinates[idx]
            var col = ""
            switch idx{
            case 0:
                col = "marker-green"
                break;
            case VisibleRoute.shared.coordinates.count - 1:
                col = "marker-red"
                break;
            default:
                col = "marker-yellow"
            }
            let markerView = RouteMarkerView(coordinate: coord ?? .zero, image: UIImage(named: col))
            addSubview(markerView)
            markerView.baseFrame = RouteMarkerView.upperBaseFrame
            markerView.isHidden = coord == nil
            routeMarkerViews.append(markerView)
        }
    }
    
    func setMarker(idx: Int, coordinate: CLLocationCoordinate2D){
        if idx < routeMarkerViews.count{
            let mv = routeMarkerViews[idx]
            mv.coordinate = coordinate
            mv.isHidden = false
        }
    }
    
    func removeWaypointMarkerViews(){
        for mv in waypointMarkerViews{
            removeSubview(mv)
        }
        waypointMarkerViews.removeAll()
    }
    
    func setRoute(route: Route){
        self.route = route
        removeWaypointMarkerViews()
        for i in 1..<route.waypoints.count - 1{
            let waypoint = route.waypoints[i]
            let markerView = RouteMarkerView(coordinate: waypoint.coordinate, image: MapDefaults.routeMarkerIcon)
            addSubview(markerView)
            waypointMarkerViews.append(markerView)
        }
    }
    
    func reset(){
        removeRouteMarkerViews()
        removeWaypointMarkerViews()
        route = nil
        setNeedsDisplay()
    }
    
    func updatePosition(offset: CGPoint, scale: CGFloat){
        self.offset = offset
        self.scale = scale
        let mapOffset = CGPoint(x: offset.x/scale, y: offset.y/scale).normalizedPoint
        for mv in routeMarkerViews {
            mv.updatePosition(mapOffset: mapOffset, scale: scale)
        }
        for mv in waypointMarkerViews {
            mv.updatePosition(mapOffset: mapOffset, scale: scale)
        }
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        if let route = route{
            var drawPoints = Array<CGPoint>()
            if let offset = offset{
                let mapOffset = CGPoint(x: offset.x/scale, y: offset.y/scale).normalizedPoint
                for idx in 0..<route.points.count{
                    let point = route.points[idx]
                    let mapPoint = CGPoint(point.coordinate)
                    let drawPoint = CGPoint(x: (mapPoint.x - mapOffset.x)*scale , y: (mapPoint.y - mapOffset.y)*scale)
                    drawPoints.append(drawPoint)
                }
            }
            let ctx = UIGraphicsGetCurrentContext()!
            if !drawPoints.isEmpty{
                ctx.beginPath()
                ctx.move(to: drawPoints[0])
                for idx in 1..<drawPoints.count{
                    ctx.addLine(to: drawPoints[idx])
                }
                ctx.setStrokeColor(UIColor.systemBlue.cgColor)
                ctx.setLineWidth(4.0)
                ctx.drawPath(using: .stroke)
                ctx.setFillColor(UIColor.black.cgColor)
            }
        }
    }
    
    @objc func tapped(sender: UITapGestureRecognizer){
        let location = sender.location(in: self)
        let idx = VisibleRoute.shared.selectedIndex
        if idx != -1, idx < VisibleRoute.shared.coordinates.count{
            MainViewController.shared.setCoordinate(idx: idx, screenPoint: location)
        }
    }
    
}
