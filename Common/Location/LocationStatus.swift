/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class LocationStatus: Identifiable{
    
    static var shared = LocationStatus()
    
    var location: CLLocation
    var direction: CLLocationDirection
    
    var coordinate: CLLocationCoordinate2D {
        return location.coordinate
    }
    
    var accuracy: CLLocationAccuracy {
        return location.horizontalAccuracy
    }

    init(){
        location = MapDefaults.startLocation
        direction = 0
    }

}


