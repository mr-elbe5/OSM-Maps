/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation

class Trackpoint: Codable, Identifiable, Selectable{
    
    static func getTrackpointBetween(tp1: Trackpoint, tp2: Trackpoint) -> Trackpoint{
        let newLatitude = (tp1.coordinate.latitude + tp2.coordinate.latitude)/2
        let newLongitude = (tp1.coordinate.longitude + tp2.coordinate.longitude)/2
        let newDate = Date(timeIntervalSince1970: (tp1.timestamp.timeIntervalSince1970 + tp2.timestamp.timeIntervalSince1970)/2)
        return Trackpoint(coordinate: CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude), altitude: (tp1.altitude + tp2.altitude)/2, timestamp: newDate)
    }
    
    enum CodingKeys: String, CodingKey{
        case latitude
        case longitude
        case altitude
        case timestamp
    }
    
    var coordinate: CLLocationCoordinate2D
    var altitude: Double
    var timestamp: Date
    var mapPoint: CGPoint
    //runtime
    var selected: Bool = false
    
    // for gpx parser
    init(coordinate: CLLocationCoordinate2D, altitude: CLLocationDistance, timestamp: Date){
        self.coordinate = coordinate
        self.altitude = altitude
        self.timestamp = timestamp
        selected = false
        mapPoint = World.worldPoint(coordinate: coordinate)
    }
    
    // for track recorder
    init(location: CLLocation){
        mapPoint = World.worldPoint(coordinate: location.coordinate)
        coordinate = location.coordinate
        altitude = location.altitude
        timestamp = location.timestamp.toLocalDate()
        selected = false
    }
    
    init(original: Trackpoint){
        self.coordinate = original.coordinate
        self.altitude = original.altitude
        self.timestamp = original.timestamp
        self.mapPoint = original.mapPoint
        self.selected = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
        let longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapPoint = World.worldPoint(coordinate: coordinate)
        altitude = try values.decodeIfPresent(CLLocationDistance.self, forKey: .altitude) ?? 0
        timestamp = try values.decodeIfPresent(Date.self, forKey: .timestamp) ?? Date.localDate
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(timestamp, forKey: .timestamp)
    }
    
}

