/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class Trackpoint: Mappoint{
    
    var gpxString: String
    {
        var str = """
        
                    <trkpt lat="\(String(format:"%.7f", latitude))" lon="\(String(format:"%.7f", longitude))">
        """
        if let alt = altitude{
            str += "<ele>\(String(format: "%.1f", alt))</ele>"
        }
        if let time = timestamp{
            str += "<time>\(time.isoString())</time>"
        }
        str += "</trkpt>"
        return str
    }
    
}

extension Trackpoint{
    
    static func getTrackpointBetween(pnt1: Trackpoint, pnt2: Trackpoint) -> Trackpoint{
        let newLatitude = (pnt1.coordinate.latitude + pnt2.coordinate.latitude)/2
        let newLongitude = (pnt1.coordinate.longitude + pnt2.coordinate.longitude)/2
        var newAltitude:Double? = nil
        if let alt1 = pnt1.altitude, let alt2 = pnt2.altitude{
            newAltitude = (alt1 + alt2)/2
        }
        var newTimestamp: Date? = nil
        if let t1 = pnt1.timestamp, let t2 = pnt2.timestamp{
            newTimestamp = Date(timeIntervalSince1970: (t1.timeIntervalSince1970 + t2.timeIntervalSince1970)/2)
        }
        return Trackpoint(coordinate: CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude), altitude: newAltitude, timestamp: newTimestamp)
    }
    
}

typealias TrackpointList = MapPointList<Trackpoint>
