/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation

class Trackpoint: LocationData, Identifiable{
    
    static func getTrackpointBetween(tp1: Trackpoint, tp2: Trackpoint) -> Trackpoint{
        let newLatitude = (tp1.coordinate.latitude + tp2.coordinate.latitude)/2
        let newLongitude = (tp1.coordinate.longitude + tp2.coordinate.longitude)/2
        let newDate = Date(timeIntervalSince1970: (tp1.timestamp.timeIntervalSince1970 + tp2.timestamp.timeIntervalSince1970)/2)
        return Trackpoint(coordinate: CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude), altitude: (tp1.altitude + tp2.altitude)/2, timestamp: newDate)
    }
    
    enum CodingKeys: String, CodingKey{
        case timestamp
    }
    
    var timestamp: Date
    
    // for gpx parser
    init(coordinate: CLLocationCoordinate2D, altitude: CLLocationDistance, timestamp: Date){
        self.timestamp = timestamp
        super.init(coordinate: coordinate, altitude: altitude)
    }
    
    // for track recorder
    override init(location: CLLocation){
        timestamp = location.timestamp.toLocalDate()
        super.init(location: location)
    }
    
    init(original: Trackpoint){
        self.timestamp = original.timestamp
        super.init(original: original)
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        timestamp = try values.decodeIfPresent(Date.self, forKey: .timestamp) ?? Date.localDate
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timestamp, forKey: .timestamp)
    }
    
}

