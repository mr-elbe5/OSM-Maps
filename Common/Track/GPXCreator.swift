/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class GPXCreator : NSObject{
    
    static var temporaryFileName = "track.gpx"
    
    static func createTemporaryFile(track: Track) -> URL?{
        let fileName = track.name.replacingOccurrences(of: " ", with: "_")
        if let url = URL(string: "track_\(fileName)_\(track.startTime.fileDate()).gpx", relativeTo: BasePaths.tempURL){
            let s = trackString(track: track)
            if let data = s.data(using: .utf8){
                return FileManager.default.saveFile(data : data, url: url) ? url : nil
            }
        }
        return nil
    }
    
    static func trackPointString(tp: Trackpoint) -> String{
            """
            
                  <trkpt lat="\(String(format:"%.7f", tp.coordinate.latitude))" lon="\(String(format:"%.7f", tp.coordinate.longitude))">
                    <ele>\(String(format: "%.1f",tp.altitude))</ele>
                    <time>\(tp.timestamp.isoString())</time>
                  </trkpt>
            """
    }
    
    static func trackString(track: Track) -> String{
        var str = """
    <?xml version='1.0' encoding='UTF-8'?>
    <gpx version="1.1" creator="OSM Maps" xmlns="http://www.topografix.com/GPX/1/1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">
      <metadata>
        <name>\(track.name)</name>
      </metadata>
      <trk>
        <trkseg>
    """
        for tp in track.trackpoints{
            str += trackPointString(tp: tp)
        }
        str += """
        
        </trkseg>
      </trk>
    </gpx>
    """
        //Log.debug("GPXCreator trackString: \(str)")
        return str
    }
    
}

