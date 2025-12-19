/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

enum RouteType: String, CaseIterable {
    case foot, bike, car
}

class Route: NSObject{
    
    static var shared = Route()
    
    var startCoordinate: CLLocationCoordinate2D?
    var endCoordinate: CLLocationCoordinate2D?
    var type: RouteType = .car
    var distance: Double = 0.0
    var duration: Double = 0.0
    var waypoints: Array<Waypoint> = []
    
    var shouldShow: Bool{
        startCoordinate != nil
    }
    
    var isDefined: Bool{
        startCoordinate != nil && endCoordinate != nil
    }
    
    var isComplete: Bool{
        isDefined && !waypoints.isEmpty
    }
    
    func reset(){
        startCoordinate = nil
        endCoordinate = nil
        type = .car
        resetRoute()
    }
    
    func resetRoute(){
        distance = 0.0
        duration = 0.0
        waypoints.removeAll()
    }
    
    func requestRoute(completion: @escaping (_ result: Bool) -> Void) {
        if let startCoordinate = startCoordinate, let endCoordinate = endCoordinate {
            RouteRequest.getRouteData(from: startCoordinate, to: endCoordinate, type: type){ osrmRouteData in
                if let osrmData = osrmRouteData, self.readOSRMData(from: osrmData){
                    completion(true)
                }
                else {
                    completion(false)
                }
            }
        }
    }
    
    func readOSRMData(from osrmRouteData: OSRMRouteData) -> Bool {
        Log.info("found routes: \(osrmRouteData.routes.count)")
        resetRoute()
        if let route = osrmRouteData.routes.first {
            distance = route.distance
            duration = route.duration
            for leg in route.legs {
                for step in leg.steps {
                    for coordinate in step.geometry.coordinates2D {
                        let waypoint = Waypoint(coordinate: coordinate)
                        waypoints.append(waypoint)
                    }
                }
            }
        }
        return true
    }
    
}
    
