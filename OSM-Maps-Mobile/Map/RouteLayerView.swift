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
    
    let startMarkerView = RouteMarkerView(image: MapDefaults.routeStartIcon)
    let endMarkerView = RouteMarkerView(image: MapDefaults.routeEndIcon)
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
    
    func setupView(){
        addSubview(startMarkerView)
        addSubview(endMarkerView)
        startMarkerView.isHidden = true
        endMarkerView.isHidden = true
    }
    
    func updatePosition(offset: CGPoint, scale: CGFloat){
        self.offset = offset
        self.scale = scale
        let mapOffset = CGPoint(x: offset.x/scale, y: offset.y/scale).normalizedPoint
        if let coordinate = Route.shared.startCoordinate, coordinate != .zero{
            let mapPoint = CGPoint(coordinate)
            startMarkerView.updatePosition(to: CGPoint(x: (mapPoint.x - mapOffset.x)*scale , y: (mapPoint.y - mapOffset.y)*scale))
            startMarkerView.isHidden = false
        }
        else{
            startMarkerView.isHidden = true
        }
        if let coordinate = Route.shared.endCoordinate, coordinate != .zero{
            let mapPoint = CGPoint(coordinate)
            endMarkerView.updatePosition(to: CGPoint(x: (mapPoint.x - mapOffset.x)*scale , y: (mapPoint.y - mapOffset.y)*scale))
            endMarkerView.isHidden = false
        }
        else{
            endMarkerView.isHidden = true
        }
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        if Route.shared.isComplete{
            var drawPoints = Array<CGPoint>()
            if let offset = offset{
                let mapOffset = CGPoint(x: offset.x/scale, y: offset.y/scale).normalizedPoint
                for idx in 0..<Route.shared.waypoints.count{
                    let coordinate = Route.shared.waypoints[idx].coordinate
                    let mapPoint = CGPoint(coordinate)
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
