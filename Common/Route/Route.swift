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

class Route: Codable{
    
    private enum CodingKeys: String, CodingKey {
        case navigationPoints
        case type
        case distance
        case duration
        case routePoints
        case waypoints
        case coordinateRegion
        case centerCoordinateLatitude
        case centerCoordinateLongitude
    }
    
    var navigationPoints: Array<MapPoint> = []
    var type: RouteType = .car
    var distance: Int = 0
    var duration: TimeInterval = 0.0
    var routePoints: MapPointList = []
    var waypoints: Array<Waypoint> = []
    
    var coordinateRegion : CoordinateRegion? = nil
    var centerCoordinate : CLLocationCoordinate2D? = nil
    
    var startCoordinate: CLLocationCoordinate2D?{
        routePoints.first?.coordinate
    }
    
    var endCoordinate: CLLocationCoordinate2D?{
        routePoints.last?.coordinate
    }
    
    var worldRect: CGRect?{
        coordinateRegion?.worldRect
    }
    
    init(){
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        navigationPoints = try container.decodeIfPresent(Array<MapPoint>.self, forKey: .navigationPoints) ?? []
        let s = try container.decodeIfPresent(String.self, forKey: .type)
        if let s, let type = RouteType(rawValue: s) {
            self.type = type
        }
        distance = try container.decodeIfPresent(Int.self, forKey: .distance) ?? 0
        duration = try container.decodeIfPresent(TimeInterval.self, forKey: .duration) ?? 0.0
        routePoints = try container.decodeIfPresent(MapPointList.self, forKey: .routePoints) ?? []
        waypoints = try container.decodeIfPresent(Array<Waypoint>.self, forKey: .waypoints) ?? []
        coordinateRegion = try container.decodeIfPresent(CoordinateRegion.self, forKey: .coordinateRegion)
        if let lat = try container.decodeIfPresent(CLLocationDegrees.self, forKey: .centerCoordinateLatitude), lat != 0,
           let lon = try container.decodeIfPresent(CLLocationDegrees.self, forKey: .centerCoordinateLongitude){
            if lat != 0 || lon != 0{
                centerCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
        }
        if coordinateRegion == nil{
            updateCoordinateRegion()
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(navigationPoints, forKey: .navigationPoints)
        try container.encodeIfPresent(type.rawValue, forKey: .type)
        try container.encode(distance, forKey: .distance)
        try container.encode(duration, forKey: .duration)
        try container.encode(routePoints, forKey: .routePoints)
        try container.encode(waypoints, forKey: .waypoints)
        try container.encode(coordinateRegion, forKey: .coordinateRegion)
        if let centerCoordinate = centerCoordinate{
            try container.encode(centerCoordinate.latitude, forKey: .centerCoordinateLatitude)
            try container.encode(centerCoordinate.longitude, forKey: .centerCoordinateLongitude)
        }
    }
    
    func reset(){
        navigationPoints.removeAll()
        type = .car
        distance = 0
        duration = 0
        routePoints.removeAll()
        waypoints.removeAll()
    }
    
    func updateCoordinateRegion(){
        let cr = CoordinateRegion()
        if let start = routePoints.first{
            cr.minLatitude = start.coordinate.latitude
            cr.maxLatitude = start.coordinate.latitude
            cr.minLongitude = start.coordinate.longitude
            cr.maxLongitude = start.coordinate.longitude
            for i in 1..<self.routePoints.count{
                let tp = routePoints[i]
                if tp.coordinate.latitude < cr.minLatitude{
                    cr.minLatitude = tp.coordinate.latitude
                }
                if tp.coordinate.latitude > cr.maxLatitude{
                    cr.maxLatitude = tp.coordinate.latitude
                }
                if tp.coordinate.longitude < cr.minLongitude{
                    cr.minLongitude = tp.coordinate.longitude
                }
                if tp.coordinate.longitude > cr.maxLongitude{
                    cr.maxLongitude = tp.coordinate.longitude
                }
            }
            coordinateRegion = cr
            centerCoordinate = cr.center
        }
    }
    
}
    
