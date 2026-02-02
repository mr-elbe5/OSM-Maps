/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class VisibleRoute{
    
    static var shared = VisibleRoute()
    
    static var MAX_NAVIGATION_POINTS: Int = 7
    
    var navigationPoints: [MapPoint?] = []
    var routeType: RouteType = Preferences.shared.routeType
    
    var route: Route? = nil
    
    var selectedIndex: Int = -1
    
    var allNavigationPointsSet: Bool{
        navigationPoints.allSatisfy({
            $0 != nil
        })
    }
    
    var anyNavigationPointsSet: Bool{
        !navigationPoints.allSatisfy({
            $0 == nil
        })
    }
    
    var routeIsRequestable: Bool{
        let valid = navigationPoints.count > 1 && allNavigationPointsSet
        //Log.info("isRequestable: \(valid)")
        return valid
    }
    
    var isPresent: Bool{
        anyNavigationPointsSet
    }
    
    var isComplete: Bool{
        allNavigationPointsSet && routeIsRequestable && route != nil
    }
    
    init(){
        navigationPoints.append(nil)
        navigationPoints.append(nil)
    }
    
    func addRoutePoint(){
        if navigationPoints.count < VisibleRoute.MAX_NAVIGATION_POINTS{
            navigationPoints.append(nil)
        }
    }
    
    func removeRoutePoint(completion: @escaping (Bool) -> Void){
        if navigationPoints.count > 2{
            navigationPoints.removeLast()
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
        if navigationPoints.count > idx {
            navigationPoints[idx] = MapPoint(coordinate: coordinate)
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
        self.navigationPoints = route.navigationPoints
    }
    
    func saveRoute(completion: ((Bool) -> Void)? = nil){
        if isComplete{
            let item = RouteItem(route: route!)
            if let startPoint = route!.navigationPoints.first, let endPoint = route!.navigationPoints.last {
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
        navigationPoints.removeAll()
        navigationPoints.append(nil)
        navigationPoints.append(nil)
        route = nil
        selectedIndex = -1
    }
    
    func requestRoute(completion: @escaping (_ result: Bool) -> Void) {
        if routeIsRequestable {
            var coordinates = [CLLocationCoordinate2D]()
            var navPoints = MapPointList()
            for pnt in navigationPoints{
                if let pnt = pnt{
                    coordinates.append(pnt.coordinate)
                    navPoints.append(pnt)
                }
            }
            RouteRequest.getRoute(coordinates: coordinates, type: routeType){ route in
                if let route = route{
                    self.route = route
                    route.navigationPoints = navPoints
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
    
