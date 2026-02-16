/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

@Observable class RouteStatus: NSObject, Codable{
    
    static var storeKey: String = "route"
    
    static var shared = RouteStatus()
    
    static func loadStatus(){
        if let status : RouteStatus = StatusManager.shared.getCodable(key: RouteStatus.storeKey){
            RouteStatus.shared = status
        }
    }
    
    var route: Route? = nil
    var visible: Bool = false
    
    func setRoute(_ route: Route){
        self.route = route
        visible = true
        save()
    }
    
    func toggleVisible(){
        visible = !visible
        save()
    }
    
    func removeRoute(){
        route = nil
        visible = false
        save()
    }
    
    func save(){
        StatusManager.shared.saveCodable(key: RouteStatus.storeKey, value: self)
        //Log.debug("route status saved")
    }
    
}


