/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class VisibleRoute: NSObject{
    
    static var shared = VisibleRoute()
    
    var startCoordinate: CLLocationCoordinate2D?
    var endCoordinate: CLLocationCoordinate2D?
    var type: RouteType = .car
    var coordinates = Array<CLLocationCoordinate2D>()
    var startMapPoint: CGPoint?
    var endMapPoint: CGPoint?
    var points = [CGPoint]()
    var boundingRect: CGRect = .zero
    
    var shouldShow: Bool{
        startCoordinate != nil
    }
    
    var isDefined: Bool{
        startCoordinate != nil && endCoordinate != nil
    }
    
    var isComplete: Bool{
        isDefined && !coordinates.isEmpty
    }
    
    func requestRoute(){
        if isDefined{
            RouteData.shared.reset()
            RouteData.shared.startPoint = startCoordinate!
            RouteData.shared.endPoint = endCoordinate!
            RouteData.shared.type = type
            RouteData.shared.requestRoute(){ success in
                if success{
                    self.setRoute(RouteData.shared)
                }
            }
        }
    }
    
    func setRoute(_ route: RouteData){
        reset()
        for waypoint in route.waypoints{
            coordinates.append(waypoint.coordinate)
        }
        coordinates.forEach{
            addMapPoint(coordinate: $0)
        }
    }
    
    func reset(){
        startCoordinate = nil
        endCoordinate = nil
        coordinates.removeAll()
        startMapPoint = nil
        points.removeAll()
        boundingRect = .zero
    }
    
    func addTrackpoint(_ coordinate: CLLocationCoordinate2D){
        coordinates.append(coordinate)
        addMapPoint(coordinate: coordinate)
    }
    
    func addMapPoint(coordinate: CLLocationCoordinate2D) {
        let scaledMapPoint = World.scaledPoint(coordinate, downScale: MapStatus.shared.scale)
        if let startPoint = startMapPoint{
            let pnt = CGPoint(x: scaledMapPoint.x - startPoint.x, y: scaledMapPoint.y - startPoint.y)
            points.append(pnt)
            updateRect()
        }
        else{
            startMapPoint = scaledMapPoint
            boundingRect = .zero
        }
    }
    
    private func updateRect(){
        var minX: CGFloat = .infinity
        var minY: CGFloat = .infinity
        var maxX: CGFloat = 0
        var maxY: CGFloat = 0
        for pnt in points{
            minX = min(minX, pnt.x)
            minY = min(minY, pnt.y)
            maxX = max(maxX, pnt.x)
            maxY = max(maxY, pnt.y)
        }
        boundingRect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
}
    
