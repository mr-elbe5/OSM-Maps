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
    
    var coordinate: CLLocationCoordinate2D
    var altitude: Double
    var street: String
    var city: String
    
    var isUpdated: Bool = false
    
    var selected: Bool = false
    
    var hasValidCoordinate: Bool {
        return coordinate != .zero
    }
    
    init(){
        coordinate = .zero
        altitude = 0
        street = ""
        city = ""
    }
    
    init(coordinate: CLLocationCoordinate2D){
        self.coordinate = coordinate
        altitude = 0
        street = ""
        city = ""
    }
    
    init(coordinate: CLLocationCoordinate2D, altitude: Double){
        self.coordinate = coordinate
        self.altitude = altitude
        street = ""
        city = ""
    }
    
    init(location: CLLocation){
        self.coordinate = location.coordinate
        self.altitude = location.altitude
        street = ""
        city = ""
    }
    
    init(original: LocationData){
        self.coordinate = original.coordinate
        self.altitude = original.altitude
        self.street = original.street
        self.city = original.city
    }
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
        let longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        altitude = try values.decodeIfPresent(Double.self, forKey: .altitude) ?? 0
        street = try values.decodeIfPresent(String.self, forKey: .street) ?? ""
        city = try values.decodeIfPresent(String.self, forKey: .city) ?? ""
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.coordinate.latitude, forKey: .latitude)
        try container.encode(self.coordinate.longitude, forKey: .longitude)
        try container.encode(self.altitude, forKey: .altitude)
        try container.encode(self.street, forKey: .street)
        try container.encode(self.city, forKey: .city)
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

typealias LocationList<T: LocationData> = Array<T>

extension LocationList{
    
    var allSelected: Bool{
        get{
            allSatisfy({
                $0.selected
            })
        }
    }
    
    var allUnselected: Bool{
        get{
            allSatisfy({
                !$0.selected
            })
        }
    }
    
    var anySelected: Bool{
        get{
            !allUnselected
        }
    }
    
    mutating func selectAll(){
        for item in self{
            item.selected = true
        }
    }
    
    mutating func deselectAll(){
        for item in self{
            item.selected = false
        }
    }
    
    mutating func toggleSelection(){
        var selected = false
        for item in self{
            if item.selected{
                selected = true
                break
            }
        }
        for item in self{
            item.selected = !selected
        }
    }
    
}




