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
    
    var points = [MapPoint]()
    
    var isEmpty: Bool{
        get{
            points.isEmpty
        }
    }
    
}


