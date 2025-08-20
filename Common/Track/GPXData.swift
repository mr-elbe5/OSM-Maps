/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class GPXData{
    
    var name: String = ""
    var segments = [GPXSegment]()
    
    var isEmpty: Bool{
        get{
            segments.isEmpty || segments.first!.isEmpty
        }
    }
    
}

class GPXSegment{
    
    var points = [GPXPoint]()
    
    var isEmpty: Bool{
        get{
            points.isEmpty
        }
    }
    
}

class GPXPoint{
    
    var coordinate : CLLocationCoordinate2D
    var altitude : CLLocationDistance = 0
    var timestamp : Date? = nil
    
    var location: CLLocation{
        get{
            CLLocation(coordinate: coordinate, altitude: altitude, horizontalAccuracy: 0, verticalAccuracy: 0, course: 0, speed: 0, timestamp: timestamp ?? Date())
        }
    }
    
    init(coordinate: CLLocationCoordinate2D){
        self.coordinate = coordinate
    }
    
}
