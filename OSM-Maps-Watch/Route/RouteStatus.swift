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
    
    enum CodingKeys: String, CodingKey {
        case route
        case visible
    }
    
    var route: Route? = nil
    var visible: Bool = false
    
    override init(){
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        route = try values.decodeIfPresent(Route.self, forKey: .route)
        visible = try values.decodeIfPresent(Bool.self, forKey: .visible) ?? true
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(route, forKey: .route)
        try container.encode(visible, forKey: .visible)
    }
    
    func setRoute(_ route: Route){
        self.route = route
        visible = true
        save()
        showOnMap()
    }
    
    func toggleVisible(){
        visible = !visible
        save()
        if visible{
           showOnMap()
        }
    }
    
    private func showOnMap(){
        if let route = route{
            if route.coordinateRegion == nil{
                route.updateCoordinateRegion()
            }
            if let coordinate = route.centerCoordinate{
                WatchSettings.shared.followLocation = false
                WatchMapStatus.shared.setCenterCoordinate(coordinate)
                WatchMapStatus.shared.updateTiles()
            }
        }
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


