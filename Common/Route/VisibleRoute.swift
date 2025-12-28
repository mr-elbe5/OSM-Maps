/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class VisibleRoute{
    
    static var shared = VisibleRoute()
    
    static var MAX_ROUTE_POINTS: Int = 7
    
    var routePoints: [MapPoint?] = []
    var routeType: RouteType = Preferences.shared.routeType
    
    var route: Route? = nil
    
    var selectedIndex: Int = -1
    
    var allRoutePointsSet: Bool{
        routePoints.allSatisfy({
            $0 != nil
        })
    }
    
    var routeIsRequestable: Bool{
        let valid = routePoints.count > 1 && allRoutePointsSet
        //Log.info("isRequestable: \(valid)")
        return valid
    }
    
    init(){
        routePoints.append(nil)
        routePoints.append(nil)
    }
    
    func addRoutePoint(){
        if routePoints.count < VisibleRoute.MAX_ROUTE_POINTS{
            routePoints.append(nil)
        }
    }
    
    func removeRoutePoint(completion: @escaping (Bool) -> Void){
        if routePoints.count > 2{
            routePoints.removeLast()
            if routeIsRequestable{
                //Log.info("requesting route")
                requestRoute(){ success in
                    completion(success)
                }
                return
            }
        }
        completion(false)
    }
    
    func setIndex(_ idx: Int){
        if selectedIndex == idx{
            selectedIndex = -1
        }
        else{
            selectedIndex = idx
        }
        //Log.info("selected index = \(selectedIndex)")
    }
    
    func setCoordinateForRoutePoint(_ idx: Int,_ coordinate: CLLocationCoordinate2D, completion: @escaping (Bool) -> Void) {
        if routePoints.count > idx {
            routePoints[idx] = MapPoint(coordinate: coordinate)
            if routeIsRequestable{
                //Log.info("requesting route")
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
        if routeIsRequestable{
            requestRoute(){ success in
                completion(success)
            }
            return
        }
        completion(false)
    }
    
    func saveRoute(){
        if let route = route{
            route.navigationPoints.removeAll()
            for i in 0..<routePoints.count{
                if let point = routePoints[i]{
                    route.navigationPoints.append(MapPoint(coordinate: point.coordinate))
                }
            }
            let item = RouteItem(route: route)
            if let startPoint = route.routePoints.first {
                item.coordinate = startPoint.coordinate
                item.updateLocation(){
                    AppData.shared.addItem(item)
                }
            }
        }
    }
    
    func reset() {
        routePoints.removeAll()
        routePoints.append(nil)
        routePoints.append(nil)
        route = nil
    }
    
    func requestRoute(completion: @escaping (_ result: Bool) -> Void) {
        if routeIsRequestable {
            var coordinates = [CLLocationCoordinate2D]()
            for pnt in routePoints{
                if let pnt = pnt{
                    coordinates.append(pnt.coordinate)
                }
            }
            RouteRequest.getRoute(coordinates: coordinates, type: routeType){ route in
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
    
