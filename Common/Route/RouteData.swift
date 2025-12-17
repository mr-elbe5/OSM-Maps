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

class RouteData: Codable{
    
    enum CodingKeys: String, CodingKey {
        case startLatitude
        case startLongitude
        case endLatitude
        case endLongitude
        case type
        case waypoints
    }
    
    var startPoint: CLLocationCoordinate2D = .zero
    var endPoint: CLLocationCoordinate2D = .zero
    var type: RouteType = .car
    var waypoints: Array<Waypoint> = []
    
    init(startPoint: CLLocationCoordinate2D, endPoint: CLLocationCoordinate2D, type: RouteType) {
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.type = type
    }
    
    required init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        var lat = try values.decodeIfPresent(Double.self, forKey: .startLatitude)
        var lon = try values.decodeIfPresent(Double.self, forKey: .startLongitude)
        if let lat = lat, let lon = lon{
            startPoint = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        lat = try values.decodeIfPresent(Double.self, forKey: .endLatitude)
        lon = try values.decodeIfPresent(Double.self, forKey: .endLongitude)
        if let lat = lat, let lon = lon{
            endPoint = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        let s = try values.decodeIfPresent(String.self, forKey: .type)
        if let s = s, let type = RouteType(rawValue: s) {
            self.type = type
        }
        waypoints = try values.decodeIfPresent([Waypoint].self, forKey: .waypoints) ?? []
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(startPoint.latitude, forKey: .startLatitude)
        try container.encode(startPoint.longitude, forKey: .startLongitude)
        try container.encode(endPoint.latitude, forKey: .endLatitude)
        try container.encode(endPoint.longitude, forKey: .endLongitude)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(waypoints, forKey: .waypoints)
    }
    
}
