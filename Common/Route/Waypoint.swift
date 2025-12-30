/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class Waypoint: MapPoint{
    
    enum CodingKeys: String, CodingKey {
        case name
        case type
        case direction
        case distance
        case duration
    }
    
    var name: String = ""
    var type: String = ""
    var direction: String = ""
    var distance: Int = 0
    var duration: Int = 0
    
    var iconName: String{
        switch type {
        case "depart":
            return "flag"
        case "arrive":
            return "flag.pattern.checkered"
        case "turn":
            switch direction {
            case "left", "slight left", "sharp left":
                return "arrow.left"
            case "right", "slight right", "sharp right":
                return "arrow.right"
            default:
                return "arrow.up"
        }
        default:
            break
        }
        return ""
    }
    
    var directionString: String{
        switch type {
        case "depart":
            return "start".localize() + " "
        case "arrive":
            return "arrived".localize() + " "
        case "turn":
            switch direction {
            case "left", "slight left", "sharp left":
                return "turnLeft".localize() + " "
            case "right", "slight right", "sharp right":
                return "turnRight".localize() + " "
            default:
                return "straight".localize() + " "
        }
        default:
            break
        }
        return ""
    }
    
    override init(coordinate: CLLocationCoordinate2D) {
        super.init(coordinate: coordinate)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        type = try values.decodeIfPresent(String.self, forKey: .type) ?? ""
        direction = try values.decodeIfPresent(String.self, forKey: .direction) ?? ""
        distance = try values.decodeIfPresent(Int.self, forKey: .distance) ?? 0
        duration = try values.decodeIfPresent(Int.self, forKey: .duration) ?? 0
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try super.encode(to: encoder)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encode(direction, forKey: .direction)
        try container.encode(distance, forKey: .distance)
        try container.encode(duration, forKey: .duration)
    }
    
}
