/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class VisibleRoute{
    
    static var shared = VisibleRoute()
    
    private var startCoordinate: CLLocationCoordinate2D?
    private var endCoordinate: CLLocationCoordinate2D?
    private var routeType: RouteType = Preferences.shared.routeType
    
    var route: Route? = nil
    
    var shouldShow: Bool{
        startCoordinate != nil || endCoordinate != nil
    }
    
    func setStartCoordinate(_ coordinate: CLLocationCoordinate2D, completion: @escaping (Bool) -> Void) {
        startCoordinate = coordinate
        if endCoordinate != nil{
            requestRoute(){ success in
                completion(success)
            }
        }
        else{
            completion(false)
        }
    }
    
    func setEndCoordinate(_ coordinate: CLLocationCoordinate2D, completion: @escaping (Bool) -> Void) {
        endCoordinate = coordinate
        if startCoordinate != nil{
            requestRoute(){ success in
                completion(success)
            }
        }
        else{
            completion(false)
        }
    }
    
    func setRouteType(_ type: RouteType, completion: @escaping (Bool) -> Void) {
        self.routeType = type
        if startCoordinate != nil && endCoordinate != nil{
            requestRoute(){ success in
                completion(success)
            }
        }
        else{
            completion(false)
        }
    }
    
    func reset() {
        startCoordinate = nil
        endCoordinate = nil
        route = nil
    }
    
    func requestRoute(completion: @escaping (_ result: Bool) -> Void) {
        if let startCoordinate = startCoordinate, let endCoordinate = endCoordinate {
            RouteRequest.getRoute(from: startCoordinate, to: endCoordinate, type: routeType){ route in
                if let route = route{
                    self.route = route
                    completion(true)
                }
                else {
                    self.route = nil;
                    completion(false)
                }
            }
        }
    }
    
}
    
