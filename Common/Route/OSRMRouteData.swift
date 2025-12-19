/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 Code apapted from OSRMResponse by Ringo Wathelet
 */

import Foundation
import CoreLocation

class OSRMRouteData: Decodable {
    
    let code: String
    let routes: [OSRMRoute]
    
    enum CodingKeys: String, CodingKey {
        case code, routes, waypoints
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try container.decodeIfPresent(String.self, forKey: .code) ?? ""
        if code != "Ok" {
            self.routes = []
            return
        }
        self.routes = try container.decodeIfPresent([OSRMRoute].self, forKey: .routes) ?? []
    }
}

class OSRMRoute: Decodable {
    
    var legs: [OSRMLeg] = []
    var duration: Double = 0
    var distance: Double = 0

    enum CodingKeys: String, CodingKey {
        case legs
        case duration
        case distance
    }
    
    init(){
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.legs = try container.decodeIfPresent([OSRMLeg].self, forKey: .legs) ?? []
        self.distance = try container.decodeIfPresent(Double.self, forKey: .distance) ?? 0
        self.duration = try container.decodeIfPresent(Double.self, forKey: .duration) ?? 0
    }
}

class OSRMGeometry: Decodable {
    
    var coordinates: [[Double]] = []
    var type: String = "car"
    
    enum CodingKeys: String, CodingKey {
        case coordinates
        case type
    }
    
    init(){
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.coordinates = try container.decodeIfPresent([[Double]].self, forKey: .coordinates) ?? []
        self.type = try container.decodeIfPresent(String.self, forKey: .type) ?? "car"
    }

    var coordinates2D: [CLLocationCoordinate2D] {
        coordinates.compactMap { coord in
            guard coord.count >= 2 else { return nil }
            return CLLocationCoordinate2D(latitude: coord[1], longitude: coord[0])
        }
    }

}

class OSRMLeg: Decodable {
    
    var duration: Double = 0
    var steps: [OSRMStep] = []
    
    enum CodingKeys: String, CodingKey {
        case duration
        case steps
    }
    
    init(){
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.duration = try container.decodeIfPresent(Double.self, forKey: .duration) ?? 0
        self.steps = try container.decodeIfPresent([OSRMStep].self, forKey: .steps) ?? []
    }
}

class OSRMStep: Decodable {
    
    var geometry: OSRMGeometry
    var maneuver: OSRMManeuver?
    var name: String
    var duration : Double
    var distance: Double
    
    enum CodingKeys: String, CodingKey {
        case intersections
        case geometry
        case maneuver
        case name
        case ref
        case duration
        case distance
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.geometry = try container.decodeIfPresent(OSRMGeometry.self, forKey: .geometry) ?? OSRMGeometry()
        self.maneuver = try container.decodeIfPresent(OSRMManeuver.self, forKey: .maneuver)
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        if self.name.isEmpty{
            self.name = try container.decodeIfPresent(String.self, forKey: .ref) ?? ""
        }
        self.duration = try container.decodeIfPresent(Double.self, forKey: .duration) ?? 0.0
        self.distance = try container.decodeIfPresent(Double.self, forKey: .distance) ?? 0.0
    }
}

class OSRMManeuver: Decodable {
    
    var location: [Double] = []
    var type: String = ""
    var modifier: String = ""

    enum CodingKeys: String, CodingKey {
        case location
        case type
        case modifier
    }
    
    init() {
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.location = try container.decodeIfPresent([Double].self, forKey: .location) ?? []
        self.type = try container.decodeIfPresent(String.self, forKey: .type) ?? ""
        self.modifier = try container.decodeIfPresent(String.self, forKey: .modifier) ?? ""
    }
    
    var coordinates2D: CLLocationCoordinate2D? {
        guard location.count == 2 else { return nil }
        return CLLocationCoordinate2D(latitude: location[1], longitude: location[0])
    }
    
}

