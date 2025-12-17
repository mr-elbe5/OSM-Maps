/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class Waypoint: Codable{
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
    
    var coordinate: CLLocationCoordinate2D = .zero
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    required init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let lat = try values.decodeIfPresent(Double.self, forKey: .latitude)
        let lon = try values.decodeIfPresent(Double.self, forKey: .longitude)
        if let lat = lat, let lon = lon{
            coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
    }
    
}
