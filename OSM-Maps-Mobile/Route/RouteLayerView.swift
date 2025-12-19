/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

class RouteLayerView: UIView {
    
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
    
    func setRoute(){
        for mv in markerViews{
            mv.removeFromSuperview()
        }
        markerViews.removeAll()
        for waypoint in Route.shared.waypoints{
            let markerView = RouteMarkerView(coordinate: waypoint.coordinate, image: MapDefaults.routeMarkerIcon)
            addSubview(markerView)
            markerViews.append(markerView)
        }
    }
    
    func updatePosition(offset: CGPoint, scale: CGFloat){
        self.offset = offset
        self.scale = scale
        let mapOffset = CGPoint(x: offset.x/scale, y: offset.y/scale).normalizedPoint
        if let coordinate = Route.shared.startCoordinate, coordinate != .zero{
            startMarkerView.coordinate = coordinate
            startMarkerView.updatePosition(mapOffset: mapOffset, scale: scale)
            startMarkerView.isHidden = false
        }
        else{
            startMarkerView.isHidden = true
        }
        if let coordinate = Route.shared.endCoordinate, coordinate != .zero{
            endMarkerView.coordinate = coordinate
            endMarkerView.updatePosition(mapOffset: mapOffset, scale: scale)
            endMarkerView.isHidden = false
        }
        else{
            endMarkerView.isHidden = true
        }
        for markerView in markerViews {
            markerView.updatePosition(mapOffset: mapOffset, scale: scale)
        }
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        if Route.shared.isComplete{
            var drawPoints = Array<CGPoint>()
            if let offset = offset{
                let mapOffset = CGPoint(x: offset.x/scale, y: offset.y/scale).normalizedPoint
                for idx in 0..<Route.shared.points.count{
                    let point = Route.shared.points[idx]
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
