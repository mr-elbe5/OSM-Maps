/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class Routepoint: Mappoint{
    
    enum CodingKeys: String, CodingKey {
        case name
        case type
        case distance
        case duration
    }
    
    var name: String = ""
    var type: String = ""
    var distance: Int = 0
    var duration: Int = 0
    
    var iconName: String{
        switch type {
        case "depart":
            return "flag"
        case "arrive":
            return "flag.pattern.checkered"
        case "left":
            return "arrow.turn.up.left"
        case "right":
            return "arrow.turn.up.right"
        case  "roundabout":
            return "arrow.counterclockwise.circle"
        case "uturn":
            return "arrow.uturn.down"
        default:
            return "arrow.up"
        }
    }
    
    var directionString: String{
        switch type {
        case "depart":
            return "start".localize() + " "
        case "arrive":
            return "arrived".localize() + " "
        case "left":
            return "turnLeft".localize() + " "
        case "right":
            return "turnRight".localize() + " "
        case  "roundabout":
            return "roundabout".localize() + " "
        case "uturn":
            return "uturn".localize() + " "
        case "straight":
            return "straight".localize() + " "
        default:
            return ""
        }
    }
    
    init(latitude: Double, longitude: Double) {
        super.init(latitude: latitude, longitude: longitude)
    }
    
    init(coordinate: CLLocationCoordinate2D) {
        super.init(coordinate: coordinate)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        type = try values.decodeIfPresent(String.self, forKey: .type) ?? ""
        distance = try values.decodeIfPresent(Int.self, forKey: .distance) ?? 0
        duration = try values.decodeIfPresent(Int.self, forKey: .duration) ?? 0
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try super.encode(to: encoder)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encode(distance, forKey: .distance)
        try container.encode(duration, forKey: .duration)
    }
    
    var gpxString: String
    {
        var str =
        """
        
                <rtept lat="\(String(format:"%.7f", latitude))" lon="\(String(format:"%.7f", longitude))">
        """
        if let alt = altitude{
            str += "<ele>\(String(format: "%.1f", alt))</ele>"
        }
        if let time = timestamp{
            str += "<time>\(time.isoString())</time>"
        }
        str += "<type>\(type)</type>"
        if !name.isEmpty{
            str += "<name>\(name)</name>"
        }
        str += "<cmt>distance: \(distance)m, duration: \(duration)s</cmt>"
        str += "</rtept>"
        return str
    }
    
}

typealias RoutepointList = MapPointList<Routepoint>
