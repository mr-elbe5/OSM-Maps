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
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
    
    func updatePosition(offset: CGPoint, scale: CGFloat){
        self.offset = offset
        self.scale = scale
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        if VisibleRoute.shared.isPresent{
            var startPoint = CGPoint.zero
            var endPoint = CGPoint.zero
            var drawPoints = Array<CGPoint>()
            if let offset = offset{
                let mapOffset = CGPoint(x: offset.x/scale, y: offset.y/scale).normalizedPoint
                if let coordinate = VisibleRoute.shared.startCoordinate{
                    let mapPoint = CGPoint(coordinate)
                    startPoint = CGPoint(x: (mapPoint.x - mapOffset.x)*scale , y: (mapPoint.y - mapOffset.y)*scale)
                }
                if let coordinate = VisibleRoute.shared.endCoordinate{
                    let mapPoint = CGPoint(coordinate)
                    endPoint = CGPoint(x: (mapPoint.x - mapOffset.x)*scale , y: (mapPoint.y - mapOffset.y)*scale)
                }
                for idx in 0..<VisibleRoute.shared.coordinates.count{
                    let coordinate = VisibleRoute.shared.coordinates[idx]
                    let mapPoint = CGPoint(coordinate)
                    let drawPoint = CGPoint(x: (mapPoint.x - mapOffset.x)*scale , y: (mapPoint.y - mapOffset.y)*scale)
                    drawPoints.append(drawPoint)
                }
            }
            let ctx = UIGraphicsGetCurrentContext()!
            if startPoint != .zero{
                ctx.draw(MapDefaults.routeStartIcon.cgImage!, in: CGRect(x: startPoint.x, y: startPoint.y, width: 16, height: 16))
            }
            if endPoint != .zero{
                ctx.draw(MapDefaults.routeEndIcon.cgImage!, in: CGRect(x: endPoint.x, y: endPoint.y, width: 16, height: 16))
            }
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
