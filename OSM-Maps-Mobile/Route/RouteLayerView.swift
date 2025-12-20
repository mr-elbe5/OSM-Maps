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
    
    let startMarkerView = RouteMarkerView(coordinate: .zero, image: MapDefaults.routeStartIcon)
    let endMarkerView = RouteMarkerView(coordinate: .zero, image: MapDefaults.routeEndIcon)
    var markerViews = Array<RouteMarkerView>()
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
    
    func setupView(){
        addSubview(startMarkerView)
        addSubview(endMarkerView)
        startMarkerView.isHidden = true
        endMarkerView.isHidden = true
    }
    
    func setStartMarker(coordinate: CLLocationCoordinate2D){
        startMarkerView.coordinate = coordinate
        startMarkerView.isHidden = false
    }
    
    func setEndMarker(coordinate: CLLocationCoordinate2D){
        endMarkerView.coordinate = coordinate
        endMarkerView.isHidden = false
    }
    
    func setRoute(route: Route){
        self.route = route
        for mv in markerViews{
            mv.removeFromSuperview()
        }
        markerViews.removeAll()
        for waypoint in route.waypoints{
            let markerView = RouteMarkerView(coordinate: waypoint.coordinate, image: MapDefaults.routeMarkerIcon)
            addSubview(markerView)
            markerViews.append(markerView)
        }
    }
    
    func reset(){
        startMarkerView.coordinate = .zero
        startMarkerView.isHidden = true
        endMarkerView.coordinate = .zero
        endMarkerView.isHidden = true
        for mv in markerViews{
            self.removeSubview(mv)
        }
        markerViews.removeAll()
        route = nil
        setNeedsDisplay()
    }
    
    func updatePosition(offset: CGPoint, scale: CGFloat){
        self.offset = offset
        self.scale = scale
        let mapOffset = CGPoint(x: offset.x/scale, y: offset.y/scale).normalizedPoint
        if !startMarkerView.isHidden{
            startMarkerView.updatePosition(mapOffset: mapOffset, scale: scale)
        }
        if !endMarkerView.isHidden{
            endMarkerView.updatePosition(mapOffset: mapOffset, scale: scale)
        }
        for markerView in markerViews {
            markerView.updatePosition(mapOffset: mapOffset, scale: scale)
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
    
}
