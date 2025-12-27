/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class VisibleRoute{
    
    static var shared = VisibleRoute()
    
    var coordinates: [CLLocationCoordinate2D?] = []
    var routeType: RouteType = Preferences.shared.routeType
    
    var route: Route? = nil
    
    var selectedIndex: Int = -1
    
    var allCoordinatesValid: Bool{
        coordinates.allSatisfy({
            $0 != nil
        })
    }
    
    var isValid: Bool{
        coordinates.count > 1 && allCoordinatesValid
    }
    
    init(){
        coordinates.append(nil)
        coordinates.append(nil)
    }
    
    func addCoordinate(){
        coordinates.append(nil)
    }
    
    func removeCoordinate(){
        if coordinates.count > 2{
            coordinates.removeLast()
        }
    }
    
    func setIndex(_ idx: Int){
        if selectedIndex == idx{
            selectedIndex = -1
        }
        else{
            selectedIndex = idx
        }
        Log.info("selected index = \(selectedIndex)")
    }
    
    func setCoordinate(_ idx: Int,_ coordinate: CLLocationCoordinate2D, completion: @escaping (Bool) -> Void) {
        if coordinates.count > idx {
            coordinates[idx] = coordinate
            if isValid{
                requestRoute(){ success in
                    completion(success)
                }
                return
            }
        }
        completion(false)
    }
    
    func setRouteType(_ type: RouteType, completion: @escaping (Bool) -> Void) {
        self.routeType = type
        if isValid{
            requestRoute(){ success in
                completion(success)
            }
            return
        }
        completion(false)
    }
    
    func reset() {
        coordinates.removeAll()
        route = nil
    }
    
    func requestRoute(completion: @escaping (_ result: Bool) -> Void) {
        if isValid {
            RouteRequest.getRoute(coordinates: coordinates as! [CLLocationCoordinate2D], type: routeType){ route in
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
    
