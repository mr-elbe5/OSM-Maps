/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

@Observable class RouteStatus: NSObject{
    
    static var storeKey: String = "route"
    
    static var shared = RouteStatus()
    
    static func loadStatus(){
        if let route : Route = StatusManager.shared.getCodable(key: RouteStatus.storeKey){
            RouteStatus.shared.route = route
        }
    }
    
    var route: Route? = nil
    var visible: Bool = false
    
    func setRoute(_ route: Route){
        self.route = route
        visible = true
        save()
    }
    
    func removeRoute(){
        route = nil
        visible = false
        save()
    }
    
    func save(){
        StatusManager.shared.saveCodable(key: RouteStatus.storeKey, value: route)
        Log.debug("route saved")
    }
    
}


