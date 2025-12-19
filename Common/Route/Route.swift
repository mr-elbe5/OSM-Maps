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

class Route: NSObject, Codable{
    
    static var shared = Route()
    
    private enum CodingKeys: String, CodingKey {
        case startLatitude
        case startLongitude
        case endLatitude
        case endLongitude
        case type
        case distance
        case duration
        case points
        case waypoints
    }
    
    var startCoordinate: CLLocationCoordinate2D?
    var endCoordinate: CLLocationCoordinate2D?
    var type: RouteType = .car
    var distance: Double = 0.0
    var duration: Double = 0.0
    var points: Array<MapPoint> = []
    var waypoints: Array<Waypoint> = []
    
    var shouldShow: Bool{
        startCoordinate != nil
    }
    
    var isDefined: Bool{
        startCoordinate != nil && endCoordinate != nil
    }
    
    var isComplete: Bool{
        isDefined && !points.isEmpty
    }
    
    override init(){
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var latitude = try container.decodeIfPresent(Double.self, forKey: .startLatitude)
        var longitude = try container.decodeIfPresent(Double.self, forKey: .startLongitude)
        if let latitude = latitude, let longitude = longitude {
            startCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        latitude = try container.decodeIfPresent(Double.self, forKey: .endLatitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .endLongitude)
        if let latitude = latitude, let longitude = longitude {
            endCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
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
        if let coordinate = startCoordinate {
            try container.encodeIfPresent(coordinate.latitude, forKey: .startLatitude)
            try container.encodeIfPresent(coordinate.longitude, forKey: .startLongitude)
        }
        if let coordinate = endCoordinate {
            try container.encodeIfPresent(coordinate.latitude, forKey: .endLatitude)
            try container.encodeIfPresent(coordinate.longitude, forKey: .endLongitude)
        }
        try container.encodeIfPresent(type.rawValue, forKey: .type)
        try container.encode(distance, forKey: .distance)
        try container.encode(duration, forKey: .duration)
        try container.encode(points, forKey: .points)
        try container.encode(waypoints, forKey: .waypoints)
    }
    
    func reset(){
        startCoordinate = nil
        endCoordinate = nil
        type = .car
        resetRoute()
    }
    
    func resetRoute(){
        distance = 0.0
        duration = 0.0
        points.removeAll()
    }
    
    func requestRoute(completion: @escaping (_ result: Bool) -> Void) {
        if let startCoordinate = startCoordinate, let endCoordinate = endCoordinate {
            RouteRequest.getRouteData(from: startCoordinate, to: endCoordinate, type: type){ osrmRouteData in
                if let osrmData = osrmRouteData, self.readOSRMData(from: osrmData){
                    completion(true)
                }
                else {
                    completion(false)
                }
            }
        }
    }
    
    func readOSRMData(from osrmRouteData: OSRMRouteData) -> Bool {
        Log.info("found routes: \(osrmRouteData.routes.count)")
        resetRoute()
        if let route = osrmRouteData.routes.first {
            distance = route.distance
            duration = route.duration
            for leg in route.legs {
                for step in leg.steps {
                    for coordinate in step.geometry.coordinates2D {
                        points.append(MapPoint(coordinate: coordinate))
                    }
                    if let maneuver = step.maneuver, let coordinate = maneuver.coordinates2D{
                        let waypoint = Waypoint(coordinate: coordinate)
                        waypoint.name = step.name
                        waypoint.distance = step.distance
                        waypoint.duration = step.duration
                        waypoint.type = maneuver.type
                        waypoint.direction = maneuver.modifier
                        waypoints.append(waypoint)
                    }
                }
            }
        }
        return true
    }
    
}
    
