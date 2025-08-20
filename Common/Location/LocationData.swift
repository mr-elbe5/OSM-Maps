/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class LocationData: Codable{
    
    private enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case altitude
        case street
        case city
    }
    
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var street: String
    var city: String
    
    var isUpdated: Bool = false
    
    var hasValidCoordinate: Bool {
        return latitude != 0 || longitude != 0
    }
    
    init(){
        latitude = 0
        longitude = 0
        altitude = 0
        street = ""
        city = ""
    }
    
    init(coordinate: CLLocationCoordinate2D){
        latitude = coordinate.latitude
        longitude = coordinate.longitude
        altitude = 0
        street = ""
        city = ""
    }
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
        longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
        altitude = try values.decodeIfPresent(Double.self, forKey: .altitude) ?? 0
        street = try values.decodeIfPresent(String.self, forKey: .street) ?? ""
        city = try values.decodeIfPresent(String.self, forKey: .city) ?? ""
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.latitude, forKey: .latitude)
        try container.encode(self.longitude, forKey: .longitude)
        try container.encode(self.altitude, forKey: .altitude)
        try container.encode(self.street, forKey: .street)
        try container.encode(self.city, forKey: .city)
    }
    
    var coordinate: CLLocationCoordinate2D{
        get{
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set{
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
    
    var worldPoint: CGPoint{
        CGPoint(coordinate)
    }
    
    var address: String{
        if !street.isEmpty{
            if !city.isEmpty{
                return "\(street)\n\(city)"
            }
            return street
        }
        if !city.isEmpty{
            return city
        }
        return ""
    }
    
    func updateLocation(onCompletion: (() -> Void)? = nil){
        if !isUpdated, hasValidCoordinate{
            CLPlacemark.getPlacemark(for: coordinate, result: { placemark in
                if let placemark = placemark {
                    self.street = placemark.street ?? ""
                    self.city = placemark.city ?? ""
                }
                ElevationProvider.shared.getElevation(for: self.coordinate){ result in
                    self.altitude = result
                    self.isUpdated = true
                }
            })
        }
    }

}


