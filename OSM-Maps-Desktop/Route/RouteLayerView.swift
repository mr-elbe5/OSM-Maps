/*
 OSM Maps (Mac)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation

class RouteLayerView: LayerView {
    
    var navigationMarkers = Array<RouteMarkerView>()
    
    override func setupView(){
        updateNavigationMarkers()
    }
    
    override func updatePosition(scale: CGFloat){
        self.scale = scale
        for marker in navigationMarkers{
            marker.updatePosition(scale: scale)
        }
        refresh()
    }
    
    override func updateContent(scale: CGFloat){
        self.scale = scale
        updateNavigationMarkers()
        needsDisplay = true
    }
    
    func updateNavigationMarkers(){
        removeNavigationMarkerViews()
        if let route = VisibleRoute.shared.route{
            isHidden = !route.anyNavigationPointsSet
            for idx in 0..<route.navigationPoints.count{
                let coord = route.navigationPoints[idx].coordinate
                var col = ""
                switch idx{
                case 0:
                    col = "marker-green"
                    break;
                case route.navigationPoints.count - 1:
                    col = "marker-red"
                    break;
                default:
                    col = "marker-yellow"
                }
                let marker = RouteMarkerView(coordinate: coord, image: NSImage(named: col)!)
                marker.baseFrame = RouteMarkerView.upperBaseFrame
                Log.info("coord \(marker.coordinate)")
                addSubview(marker)
                marker.isHidden = (coord == .zero)
                marker.updatePosition(scale: scale)
                navigationMarkers.append(marker)
            }
            needsLayout = true
        }
    }
    
    func setMarkerCoordinate(idx: Int, coordinate: CLLocationCoordinate2D){
        //Log.info("setMarkerCoordinate")
        if idx < navigationMarkers.count{
            let marker = navigationMarkers[idx]
            marker.coordinate = coordinate
            marker.isHidden = false
            marker.updatePosition(scale: scale)
        }
    }
    
    func removeNavigationMarkerViews(){
        for mv in navigationMarkers{
            mv.removeFromSuperview()
        }
        navigationMarkers.removeAll()
    }
    
    override func reset(){
        removeNavigationMarkerViews()
        needsDisplay = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if let route = VisibleRoute.shared.route{
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




