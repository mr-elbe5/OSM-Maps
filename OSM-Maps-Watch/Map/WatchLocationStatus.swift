/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

@Observable class WatchLocationStatus: Identifiable{
    
    static var shared = WatchLocationStatus()
    
    var location: CLLocation
    var direction: CLLocationDirection
    
    var coordinate: CLLocationCoordinate2D {
        return location.coordinate
    }
    
    var accuracy: CLLocationAccuracy {
        return location.horizontalAccuracy != 0 ? location.horizontalAccuracy : 500
    }

    init(){
        location = MapDefaults.startLocation
        direction = 0
    }

}

typealias LocationStatus = WatchLocationStatus

