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
    
    static func getRouteTypeIndex(type: RouteType) -> Int {
        RouteType.allCases.firstIndex(of: type) ?? 0
    }
}

class Route: Codable{
    
    private enum CodingKeys: String, CodingKey {
        case name
        case navigationPoints
        case type
        case distance
        case duration
        case routepoints
        case waypoints
        case coordinateRegion
        case centerCoordinateLatitude
        case centerCoordinateLongitude
    }
    
    var name : String
    var navigationPoints: Array<MapPoint> = []
    var type: RouteType = .car
    var distance: Int = 0
    var duration: TimeInterval = 0.0
    var routepoints: MapPointList = []
    var waypoints: Array<Waypoint> = []
    
    var coordinateRegion : CoordinateRegion? = nil
    var centerCoordinate : CLLocationCoordinate2D? = nil
    
    var startCoordinate: CLLocationCoordinate2D?{
        routepoints.first?.coordinate
    }
    
    var endCoordinate: CLLocationCoordinate2D?{
        routepoints.last?.coordinate
    }
    
    var canBeRequested: Bool{
        navigationPoints.count > 1 && allNavigationPointsSet
    }
    
    var allNavigationPointsSet: Bool{
        navigationPoints.allSatisfy({
            $0 != .zero
        })
    }
    
    var anyNavigationPointsSet: Bool{
        !navigationPoints.allSatisfy({
            $0 == .zero
        })
    }
    
    var isEditable: Bool{
        !navigationPoints.isEmpty
    }
    
    var isComplete: Bool{
        navigationPoints.count > 1 && allNavigationPointsSet && !routepoints.isEmpty
    }
    
    var worldRect: CGRect?{
        coordinateRegion?.worldRect
    }
    
    init(){
        name = "Route"
        navigationPoints.append(.zero)
        navigationPoints.append(.zero)
    }
    
    init(gpx: GPXData){
        name = "Route"
        routepoints = MapPointList()
        distance = 0
        duration = 0.0
        for segment in gpx.segments{
            for point in segment.points{
                let routepoint = MapPoint(coordinate: point.coordinate)
                routepoints.append(routepoint)
                name = gpx.name
            }
        }
        navigationPoints.append(routepoints.first ?? .zero)
        navigationPoints.append(routepoints.last ?? .zero)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Route"
        let s = try container.decodeIfPresent(String.self, forKey: .type)
        if let s, let type = RouteType(rawValue: s) {
            self.type = type
        }
        distance = try container.decodeIfPresent(Int.self, forKey: .distance) ?? 0
        duration = try container.decodeIfPresent(TimeInterval.self, forKey: .duration) ?? 0.0
        routepoints = try container.decodeIfPresent(MapPointList.self, forKey: .routepoints) ?? []
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
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(type.rawValue, forKey: .type)
        try container.encode(distance, forKey: .distance)
        try container.encode(duration, forKey: .duration)
        try container.encode(routepoints, forKey: .routepoints)
        try container.encode(waypoints, forKey: .waypoints)
        try container.encode(coordinateRegion, forKey: .coordinateRegion)
        try container.encodeIfPresent(centerCoordinate?.latitude, forKey: .centerCoordinateLatitude)
        try container.encodeIfPresent(centerCoordinate?.longitude, forKey: .centerCoordinateLongitude)
    }
    
    func reset(){
        name = "Route"
        navigationPoints = [.zero, .zero]
        type = .car
        distance = 0
        duration = 0
        routepoints.removeAll()
        waypoints.removeAll()
    }
    
    func updateCoordinateRegion(){
        let cr = CoordinateRegion()
        if let start = routepoints.first{
            cr.minLatitude = start.coordinate.latitude
            cr.maxLatitude = start.coordinate.latitude
            cr.minLongitude = start.coordinate.longitude
            cr.maxLongitude = start.coordinate.longitude
            for i in 1..<self.routepoints.count{
                let tp = routepoints[i]
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
    
