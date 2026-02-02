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
    
    var navigationMarkerViews = Array<RouteMarkerView>()
    private var waypointMarkerViews = Array<RouteMarkerView>()
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return VisibleRoute.shared.selectedIndex != -1 || subviews.contains(where: {
            $0 is RouteMarkerView && $0.point(inside: self.convert(point, to: $0), with: event)
        })
    }
    
    func setupView(){
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        setupNavigationMarkers()
    }
    
    private func removeNavigationMarkerViews(){
        for mv in navigationMarkerViews{
            removeSubview(mv)
        }
        navigationMarkerViews.removeAll()
    }
    
    func setupNavigationMarkers(){
        removeNavigationMarkerViews()
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
            let markerView = RouteMarkerView(idx: idx, coordinate: coord ?? .zero, image: UIImage(named: col))
            markerView.addAction(UIAction{ action in
                MainViewController.shared.activateWaypoint(idx)
            }, for: .touchDown)
            addSubview(markerView)
            markerView.baseFrame = RouteMarkerView.upperBaseFrame
            markerView.isHidden = coord == nil
            navigationMarkerViews.append(markerView)
        }
    }
    
    func setMarkerCoordinate(idx: Int, coordinate: CLLocationCoordinate2D){
        if idx < navigationMarkerViews.count{
            let mv = navigationMarkerViews[idx]
            mv.coordinate = coordinate
            mv.isHidden = false
        }
    }
    
    private func removeWaypointMarkerViews(){
        for mv in waypointMarkerViews{
            removeSubview(mv)
        }
        waypointMarkerViews.removeAll()
    }
    
    func setRoute(route: Route?){
        self.route = route
        removeWaypointMarkerViews()
        if let route = route{
            for i in 1..<route.waypoints.count - 1{
                let waypoint = route.waypoints[i]
                let markerView = RouteMarkerView(idx: i, coordinate: waypoint.coordinate, image: MapDefaults.waypointMarkerIcon)
                markerView.baseFrame = RouteMarkerView.centerBaseFrame
                markerView.addAction(UIAction{ action in
                    MainViewController.shared.activateWaypoint(i)
                }, for: .touchDown)
                addSubview(markerView)
                waypointMarkerViews.append(markerView)
            }
        }
        setNeedsDisplay()
    }
    
    func reset(){
        removeNavigationMarkerViews()
        removeWaypointMarkerViews()
        route = nil
        setupNavigationMarkers()
        setNeedsDisplay()
    }
    
    func updatePosition(offset: CGPoint, scale: CGFloat){
        self.offset = offset
        self.scale = scale
        let mapOffset = CGPoint(x: offset.x/scale, y: offset.y/scale).normalizedPoint
        for mv in navigationMarkerViews {
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
                for idx in 0..<route.routepoints.count{
                    let point = route.routepoints[idx]
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
    
    @objc func tapped(event: UITapGestureRecognizer){
        Log.info("tapped with idx \(VisibleRoute.shared.selectedIndex)")
        let location = event.location(in: self)
        let idx = VisibleRoute.shared.selectedIndex
        if idx != -1, idx < VisibleRoute.shared.navigationPoints.count{
            MainViewController.shared.setRoutePoint(idx: idx, screenPoint: location)
        }
    }
    
}
