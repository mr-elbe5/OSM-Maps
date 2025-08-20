/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

extension CLLocation{
    
    var string: String{
        "lat: \(coordinate.latitude), lon: \(coordinate.longitude), speed: \(speed), course: \(course), time: \(timestamp.timestampString())"
    }
    
}
