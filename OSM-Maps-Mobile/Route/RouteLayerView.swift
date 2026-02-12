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
    
    var navigationMarkers = Array<RouteMarkerView>()
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return VisibleRoute.shared.selectedIndex != -1 || subviews.contains(where: {
            $0 is RouteMarkerView && $0.point(inside: self.convert(point, to: $0), with: event)
        })
    }
    
    func setupView(){
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        updateNavigationMarkers()
    }
    
    func updateView(){
        isHidden = VisibleRoute.shared.routeItem == nil
        updateNavigationMarkers()
        setNeedsDisplay()
    }
    
    private func removeNavigationMarkers(){
        for mv in navigationMarkers{
            removeSubview(mv)
        }
        navigationMarkers.removeAll()
    }
    
    func updateNavigationMarkers(){
        removeNavigationMarkers()
        if let route = VisibleRoute.shared.route{
            for idx in 0..<route.navigationPoints.count{
                let navPnt = route.navigationPoints[idx]
                let coord = navPnt.coordinate
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
                if let image = UIImage(named: col){
                    let markerView = RouteMarkerView(idx: idx, coordinate: coord, image: image)
                    addSubview(markerView)
                    markerView.baseFrame = RouteMarkerView.upperBaseFrame
                    markerView.isHidden = coord == .zero
                    navigationMarkers.append(markerView)
                }
            }
        }
    }
    
    func updatePosition(offset: CGPoint, scale: CGFloat){
        self.offset = offset
        self.scale = scale
        let mapOffset = CGPoint(x: offset.x/scale, y: offset.y/scale).normalizedPoint
        for mv in navigationMarkers {
            mv.updatePosition(mapOffset: mapOffset, scale: scale)
        }
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        if let route = VisibleRoute.shared.route{
            var drawPoints = Array<CGPoint>()
            if let offset = offset{
                let mapOffset = CGPoint(x: offset.x/scale, y: offset.y/scale).normalizedPoint
                for idx in 0..<route.trackpoints.count{
                    let point = route.trackpoints[idx]
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
        if let route = VisibleRoute.shared.route{
            //Log.info("tapped with idx \(VisibleRoute.shared.selectedIndex)")
            let location = event.location(in: self)
            let idx = VisibleRoute.shared.selectedIndex
            if idx != -1, idx < route.navigationPoints.count{
                MainViewController.shared.setRoutePoint(idx: idx, screenPoint: location)
            }
        }
        
    }
    
}
