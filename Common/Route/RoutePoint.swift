/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class Routepoint: Mappoint{
    
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
        str += "</rtept>"
        return str
    }
    
}

typealias RoutepointList = MapPointList<Routepoint>
