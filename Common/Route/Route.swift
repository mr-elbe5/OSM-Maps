/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

enum RouteType: String, CaseIterable {
    case car
    case bike
    case foot
    
    static func getRouteType(idx: Int) -> RouteType {
        RouteType.allCases[idx]
    }
}

class Route: NSObject, Codable{
    
    private enum CodingKeys: String, CodingKey {
        case type
        case distance
        case duration
        case points
        case waypoints
    }
    
    var type: RouteType = .car
    var distance: Double = 0.0
    var duration: Double = 0.0
    var points: Array<MapPoint> = []
    var waypoints: Array<Waypoint> = []
    
    var startCoordinate: CLLocationCoordinate2D?{
        points.first?.coordinate
    }
    
    var endCoordinate: CLLocationCoordinate2D?{
        points.last?.coordinate
    }
    
    override init(){
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let s = try container.decodeIfPresent(String.self, forKey: .type)
        if let s, let type = RouteType(rawValue: s) {
            self.type = type
        }
        distance = try container.decodeIfPresent(Double.self, forKey: .distance) ?? 0.0
        duration = try container.decodeIfPresent(Double.self, forKey: .duration) ?? 0.0
        points = try container.decodeIfPresent(Array<MapPoint>.self, forKey: .points) ?? []
        waypoints = try container.decodeIfPresent(Array<Waypoint>.self, forKey: .waypoints) ?? []
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(type.rawValue, forKey: .type)
        try container.encode(distance, forKey: .distance)
        try container.encode(duration, forKey: .duration)
        try container.encode(points, forKey: .points)
        try container.encode(waypoints, forKey: .waypoints)
    }
    
    func reset(){
        type = .car
        distance = 0.0
        duration = 0.0
        points.removeAll()
        waypoints.removeAll()
    }
    
}
    
