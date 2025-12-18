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

class RouteData{
    
    static var shared: RouteData = RouteData()
    
    var startPoint: CLLocationCoordinate2D = .zero
    var endPoint: CLLocationCoordinate2D = .zero
    var type: RouteType = .car
    var waypoints: Array<Waypoint> = []
    
    init() {
    }
    
    init(startPoint: CLLocationCoordinate2D, endPoint: CLLocationCoordinate2D, type: RouteType) {
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.type = type
    }
    
    func reset(){
        startPoint = .zero
        endPoint = .zero
        type = .car
    }
    
    func requestRoute(completion: @escaping (_ result: Bool) -> Void) {
        RouteRequest.getRouteData(from: startPoint, to: endPoint, type: type){ osrmRouteData in
            if let osrmData = osrmRouteData, self.readOSRMData(from: osrmData){
                completion(true)
            }
            else {
                completion(false)
            }
        }
    }
    
    func readOSRMData(from osrmRouteData: OSRMRouteData) -> Bool {
        Log.info(osrmRouteData.serialize())
        return true
    }
    
}
