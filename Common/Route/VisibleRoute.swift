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
    
    var routeItem: RouteItem? = nil
    
    var route: Route?{
        routeItem?.route
    }
    
    var selectedIndex: Int = -1
    
    var canRequestRoute: Bool{
        route?.canBeRequested ?? false
    }
    
    init(){
    }
    
    func addRoutePoint(){
        if let route = route, route.navigationPoints.count < VisibleRoute.MAX_NAVIGATION_POINTS{
            route.navigationPoints.append(.zero)
        }
    }
    
    func removeRoutePoint(completion: @escaping () -> Void){
        if let route = route, route.navigationPoints.count > 2{
            route.navigationPoints.removeLast()
            if route.canBeRequested{
                //Log.info("requesting route")
                requestRoute(){
                    completion()
                }
                return
            }
        }
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
    
    func setCoordinateForRoutePoint(_ idx: Int,_ coordinate: CLLocationCoordinate2D) {
        if let route = route, route.navigationPoints.count > idx {
            route.navigationPoints[idx] = Mappoint(coordinate: coordinate)
        }
    }
    
    func updateRoute(completion: @escaping () -> Void) -> Bool{
        if let route = route, route.canBeRequested{
            //Log.info("requesting route")
            requestRoute(){
                completion()
            }
            return true
        }
        return false
    }
    
    func setRouteType(_ type: RouteType, completion: @escaping () -> Void) {
        if let item = routeItem{
            item.route.type = type
        }
        if let route = route, route.canBeRequested{
            requestRoute(){
                completion()
            }
            return
        }
    }
    
    func setRouteItem(_ item: RouteItem){
        self.routeItem = item
    }
    
    func prepareRouteForSaving(completion: (() -> Void)? = nil){
        if let item = routeItem, let route = route, route.isComplete{
            if let startPoint = route.trackpoints.first, let endPoint = route.trackpoints.last {
                item.coordinate = startPoint.coordinate
                item.startLocation = LocationData(coordinate: startPoint.coordinate)
                item.endLocation = LocationData(coordinate: endPoint.coordinate)
                item.route.navigationPoints.removeAll()
                item.updatePreview()
                item.updateLocation(){
                    item.updateLocations(){
                        item.route.updateRoutePoints()
                        item.route.desc = item.desc
                        completion?()
                    }
                }
                _ = item.getPreview()
            }
        }
    }
    
    func reset() {
        routeItem = nil
        selectedIndex = -1
    }
    
    func requestRoute(completion: @escaping () -> Void) {
        guard canRequestRoute else { return }
        if let item = routeItem, let route = route, route.canBeRequested {
            RouteRequest.requestRoute(route: route){ success in
                if success{
                    item.route = route
                    completion()
                }
            }
        }
    }
    
}
    
