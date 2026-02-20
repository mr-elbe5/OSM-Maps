/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class LocationData: Mappoint{
    
    static func updateLocations(for locations: [LocationData?], result: @escaping(Bool) -> Void){
        var done = 0
        var hasErrors: Bool = false
        for i in 0..<locations.count{
            if let location = locations[i]{
                location.updateLocation(){
                    done += 1
                    if done == locations.count{
                        result(!hasErrors)
                    }
                }
            }
            else{
                done += 1
                hasErrors = true
                if done == locations.count{
                    result(false)
                }
            }
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case street
        case city
    }
    
    var street: String
    var city: String
    
    var isUpdated: Bool = false
    
    var hasValidCoordinate: Bool {
        return coordinate != .zero
    }
    
    init(){
        street = ""
        city = ""
        super.init(coordinate: .zero)
    }
    
    init(coordinate: CLLocationCoordinate2D){
        street = ""
        city = ""
        super.init(coordinate: coordinate)
    }
    
    override init(location: CLLocation){
        street = ""
        city = ""
        super.init(location: location)
    }
    
    init(original: LocationData){
        self.street = original.street
        self.city = original.city
        super.init(coordinate: original.coordinate, altitude: original.altitude, timestamp: original.timestamp)
    }
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        street = try values.decodeIfPresent(String.self, forKey: .street) ?? ""
        city = try values.decodeIfPresent(String.self, forKey: .city) ?? ""
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try super .encode(to: encoder)
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
    
    var flatAddress: String{
        if !street.isEmpty{
            if !city.isEmpty{
                return "\(street), \(city)"
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
                    onCompletion?()
                }
            })
        }
        else{
            onCompletion?()
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




