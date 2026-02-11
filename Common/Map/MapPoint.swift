/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class MapPoint: Codable, Equatable{
    
    static var zero = MapPoint(coordinate: .zero)
    
    static func == (lhs: MapPoint, rhs: MapPoint) -> Bool {
        lhs.coordinate.latitude == rhs.coordinate.latitude && lhs.coordinate.longitude == rhs.coordinate.longitude
    }
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case altitude
        case timestamp
    }
    
    var latitude: Double
    var longitude: Double
    var altitude: Double? = nil
    var timestamp: Date? = nil
    
    //runtime
    var selected: Bool = false
    
    var coordinate: CLLocationCoordinate2D{
        get{
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set{
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
    
    var location: CLLocation{
        get{
            if let altitude = altitude{
                if let timestamp = timestamp{
                    return CLLocation(coordinate: coordinate, altitude: altitude, horizontalAccuracy: 0, verticalAccuracy: 0, course: 0, speed: 0, timestamp: timestamp)
                }
                return CLLocation(coordinate: coordinate, altitude: altitude, horizontalAccuracy: 0, verticalAccuracy: 0, course: 0, speed: 0, timestamp: Date.zero)
            }
            return CLLocation(latitude: latitude, longitude: longitude)
        }
    }
    
    init(latitude: Double, longitude: Double, altitude: Double? = nil, timestamp: Date? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.timestamp = timestamp
    }
    
    init(coordinate: CLLocationCoordinate2D, altitude: Double? = nil, timestamp: Date? = nil) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.altitude = altitude
        self.timestamp = timestamp
    }
    
    init(location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.altitude = location.altitude
        self.timestamp = location.timestamp
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        latitude = try values.decode(Double.self, forKey: .latitude)
        longitude = try values.decode(Double.self, forKey: .longitude)
        altitude = try values.decodeIfPresent(Double.self, forKey: .altitude)
        timestamp = try values.decodeIfPresent(Date.self, forKey: .timestamp)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encodeIfPresent(altitude, forKey: .altitude)
        try container.encodeIfPresent(timestamp, forKey: .timestamp)
    }
    
}

extension MapPoint{
    
    static func getMapPointBetween(pnt1: MapPoint, pnt2: MapPoint) -> MapPoint{
        let newLatitude = (pnt1.coordinate.latitude + pnt2.coordinate.latitude)/2
        let newLongitude = (pnt1.coordinate.longitude + pnt2.coordinate.longitude)/2
        var newAltitude:Double? = nil
        if let alt1 = pnt1.altitude, let alt2 = pnt2.altitude{
            newAltitude = (alt1 + alt2)/2
        }
        var newTimestamp: Date? = nil
        if let t1 = pnt1.timestamp, let t2 = pnt2.timestamp{
            newTimestamp = Date(timeIntervalSince1970: (t1.timeIntervalSince1970 + t2.timeIntervalSince1970)/2)
        }
        return MapPoint(coordinate: CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude), altitude: newAltitude, timestamp: newTimestamp)
    }
    
}
