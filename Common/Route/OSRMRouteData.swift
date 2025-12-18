/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 Code apapted from OSRMResponse by Ringo Wathelet
 */

import Foundation
import CoreLocation

/*
 {"code":"Ok","routes":[{"legs":[{"steps":[{"intersections":[{"out":0,"entry":[true],"bearings":[130],"location":[51.365239,10.394297]}],"driving_side":"right","geometry":{"coordinates":[[51.365239,10.394297],[51.365239,10.394297]],"type":"LineString"},"maneuver":{"bearing_after":130,"bearing_before":0,"location":[51.365239,10.394297],"type":"depart"},"name":"","mode":"driving","weight":0,"duration":0,"distance":0},{"intersections":[{"in":0,"entry":[true],"bearings":[310],"location":[51.365239,10.394297]}],"driving_side":"right","geometry":{"coordinates":[[51.365239,10.394297],[51.365239,10.394297]],"type":"LineString"},"maneuver":{"bearing_after":0,"bearing_before":130,"location":[51.365239,10.394297],"type":"arrive"},"name":"","mode":"driving","weight":0,"duration":0,"distance":0}],"weight":0,"summary":"","duration":0,"distance":0}],"weight_name":"routability","geometry":{"coordinates":[[51.365239,10.394297],[51.365239,10.394297]],"type":"LineString"},"weight":0,"duration":0,"distance":0}],"waypoints":[{"distance":245890.1741,"name":"","location":[51.365239,10.394297]},{"distance":247548.9449,"name":"","location":[51.365239,10.394297]}]}
 */

public struct OSRMRouteData: Codable, Identifiable, Sendable {
    public let id = UUID()
    
    public let code: String
    public let routes: [OSRMRoute]
    public let waypoints: [OSRMPoint?]
    
    enum CodingKeys: String, CodingKey {
        case code, routes, waypoints
    }
    
    public init(code: String, routes: [OSRMRoute], waypoints: [OSRMPoint?]) {
        self.code = code
        self.routes = routes
        self.waypoints = waypoints
    }
}

public struct OSRMRoute: Codable, Identifiable, Sendable {
    public let id = UUID()

    public let geometry: OSRMGeometry
    public let legs: [OSRMLeg]
    public let weightName: String
    public let weight, duration, distance: Double
    public let confidence: Double?

    enum CodingKeys: String, CodingKey {
        case confidence, legs, geometry, weight, duration, distance
        case weightName = "weight_name"
    }
    
    public init(confidence: Double, legs: [OSRMLeg], weightName: String, geometry: OSRMGeometry, weight: Double, duration: Double, distance: Double) {
        self.confidence = confidence
        self.legs = legs
        self.weightName = weightName
        self.geometry = geometry
        self.weight = weight
        self.duration = duration
        self.distance = distance
    }
}

public struct OSRMGeometry: Codable, Identifiable, Sendable {
    public let id = UUID()
    
    public let coordinates: [[Double]]
    public let type: String
    
    enum CodingKeys: String, CodingKey {
        case coordinates, type
    }
    
    public init(coordinates: [[Double]], type: String) {
        self.coordinates = coordinates
        self.type = type
    }

    public var coordinates2D: [CLLocationCoordinate2D] {
        coordinates.compactMap { coord in
            guard coord.count >= 2 else { return nil }
            return CLLocationCoordinate2D(latitude: coord[1], longitude: coord[0])
        }
    }

}

public struct OSRMLeg: Codable, Identifiable, Sendable {
    public let id = UUID()
    
    public let summary: String
    public let weight: Double
    public let duration: Double
    public let steps: [OSRMStep]
    
    enum CodingKeys: String, CodingKey {
        case summary, weight, duration, steps
    }
    
    public init(summary: String, weight: Double, duration: Double, steps: [OSRMStep]) {
        self.summary = summary
        self.weight = weight
        self.duration = duration
        self.steps = steps
    }
}

public struct OSRMStep: Codable, Identifiable, Sendable {
    public let id = UUID()
    
    public let intersections: [OSRMIntersection]?
    public let drivingSide: String
    public let geometry: OSRMGeometry
    public let maneuver: OSRMManeuver
    public let name, mode: String
    public let weight, duration, distance: Double
    
    enum CodingKeys: String, CodingKey {
        case intersections
        case drivingSide = "driving_side"
        case geometry, maneuver, name, mode, weight, duration, distance
    }
    
    public init(intersections: [OSRMIntersection]?, drivingSide: String, geometry: OSRMGeometry, maneuver: OSRMManeuver, name: String, mode: String, weight: Double, duration: Double, distance: Double) {
        self.intersections = intersections
        self.drivingSide = drivingSide
        self.geometry = geometry
        self.maneuver = maneuver
        self.name = name
        self.mode = mode
        self.weight = weight
        self.duration = duration
        self.distance = distance
    }
}

public struct OSRMManeuver: Codable, Identifiable, Sendable {
    public let id = UUID()
    
    public let location: [Double]
    public let bearingBefore: Double?
    public let bearingAfter: Double?
    public let type: String
    public let modifier: String?

    enum CodingKeys: String, CodingKey {
        case location, type, modifier
        case bearingBefore = "bearing_before"
        case bearingAfter = "bearing_after"
    }
    
    public init(location: [Double], bearingBefore: Double?, bearingAfter: Double?, type: String, modifier: String?) {
        self.location = location
        self.bearingBefore = bearingBefore
        self.bearingAfter = bearingAfter
        self.type = type
        self.modifier = modifier
    }
    
    public var coordinates2D: CLLocationCoordinate2D? {
        guard location.count == 2 else { return nil }
        return CLLocationCoordinate2D(latitude: location[1], longitude: location[0])
    }
    
}

public struct OSRMLane: Codable, Identifiable, Sendable {
    public let id = UUID()
    
    public let valid: Bool
    public let indications: [String]
    
    enum CodingKeys: String, CodingKey {
        case valid, indications
    }
    
    public init(valid: Bool, indications: [String]) {
        self.valid = valid
        self.indications = indications
    }
}

public struct OSRMIntersection: Codable, Identifiable, Sendable {
    public let id = UUID()
    
    public let location: [Double]
    public let bearings: [Int]
    public let entry: [Bool]

    // match
    public let out: Int?
    public let intersectionIn: Int?
    public let lanes: [OSRMLane]?
    
    enum CodingKeys: String, CodingKey {
        case location, bearings, entry, out, lanes
        case intersectionIn = "in"
    }
    
    public init(out: Int?, entry: [Bool], bearings: [Int], location: [Double], intersectionIn: Int?, lanes: [OSRMLane]?) {
        self.out = out
        self.entry = entry
        self.bearings = bearings
        self.location = location
        self.intersectionIn = intersectionIn
        self.lanes = lanes
    }
    
    public var coordinates2D: CLLocationCoordinate2D? {
        guard location.count == 2 else { return nil }
        return CLLocationCoordinate2D(latitude: location[1], longitude: location[0])
    }
}

public struct OSRMPoint: Codable, Identifiable, Sendable {
    public let id = UUID()
    
    public let name: String
    public let location: [Double]
    
    // macth
    public let alternativesCount, waypointIndex: Int?
    public let distance: Double?
    public let hint: String?
    public let matchingsIndex: Int?
    
    // trip
    public let tripIndex: Int?

    enum CodingKeys: String, CodingKey {
        case distance, name, location, hint
        case alternativesCount = "alternatives_count"
        case waypointIndex = "waypoint_index"
        case matchingsIndex = "matchings_index"
        case tripIndex = "trips_index"
    }
    
    public init(name: String, location: [Double], alternativesCount: Int? = nil, waypointIndex: Int? = nil, distance: Double? = nil,  hint: String? = nil, matchingsIndex: Int? = nil, tripIndex: Int? = nil) {
        self.alternativesCount = alternativesCount
        self.waypointIndex = waypointIndex
        self.distance = distance
        self.name = name
        self.location = location
        self.hint = hint
        self.matchingsIndex = matchingsIndex
        self.tripIndex = tripIndex
    }
    
    public var coordinates2D: CLLocationCoordinate2D? {
        guard location.count == 2 else { return nil }
        return CLLocationCoordinate2D(latitude: location[1], longitude: location[0])
    }
}
