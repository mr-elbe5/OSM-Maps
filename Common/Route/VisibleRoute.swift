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
    
    var anyRoutePointsSet: Bool{
        !routePoints.allSatisfy({
            $0 == nil
        })
    }
    
    var routeIsRequestable: Bool{
        let valid = routePoints.count > 1 && allRoutePointsSet
        //Log.info("isRequestable: \(valid)")
        return valid
    }
    
    var isPresent: Bool{
        anyRoutePointsSet
    }
    
    var isComplete: Bool{
        allRoutePointsSet && routeIsRequestable && route != nil
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
    
    func setRoute(_ route: Route){
        self.route = route
        self.routeType = route.type
        self.routePoints = route.routepoints
    }
    
    func saveRoute(completion: ((Bool) -> Void)?){
        if isComplete{
            let item = RouteItem(route: route!)
            if let startPoint = route!.routepoints.first, let endPoint = route!.routepoints.last {
                item.coordinate = startPoint.coordinate
                item.endLocation = LocationData(coordinate: endPoint.coordinate)
                item.updateLocation(){
                    item.endLocation!.updateLocation(){
                        AppData.shared.addItem(item)
                        AppData.shared.save()
                        completion?(true)
                    }
                }
                _ = item.getPreview()
            }
            else{
                completion?(false)
            }
        }
        else{
            completion?(false)
        }
    }
    
    func reset() {
        routePoints.removeAll()
        routePoints.append(nil)
        routePoints.append(nil)
        route = nil
        selectedIndex = -1
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
    
