/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class GPXParser : XMLParser{
    
    static func parseFile(url: URL) -> GPXData?{
        if let data = FileManager.default.readFile(url: url){
            let parser = GPXParser(data: data)
            guard parser.parse() else { return nil }
            return parser.data
        }
        return nil
    }
    
    override init(data: Data){
        super.init(data: data)
        delegate = self
    }
    
    var data = GPXData()
    
    private var name: String? = nil
    private var currentSegment : GPXSegment? = nil
    private var currentPoint: GPXPoint? = nil
    private var currentElement : String? = nil
    
}

extension GPXParser : XMLParserDelegate{
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == "name"{
            if data.name.isEmpty{
                name = ""
            }
        }
        else if elementName == "trkseg"{
            currentSegment = GPXSegment()
        }
        else if elementName == "trkpt" || elementName == "wpt"{
            guard let latString = attributeDict["lat"], let lonString = attributeDict["lon"] else { return }
            guard let lat = Double(latString), let lon = Double(lonString) else { return }
            guard let latDegrees = CLLocationDegrees(exactly: lat), let lonDegrees = CLLocationDegrees(exactly: lon) else { return }
            
            currentPoint = GPXPoint(coordinate: CLLocationCoordinate2D(latitude: latDegrees, longitude: lonDegrees))
        }
        currentElement = elementName
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if string.isEmpty{
            return
        }
        switch currentElement{
        case "name":
            name? += string
        case "time":
            if let point = currentPoint, let timestamp = string.ISO8601Date(){
                point.timestamp = timestamp
            }
        case "ele":
            if let point = currentPoint, let dist = CLLocationDistance(string){
                point.altitude =  dist
            }
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "name"{
            if let name = name{
                data.name = name
                self.name = nil
            }
        }
        else if elementName == "trkseg"{
            if let segment = currentSegment{
                data.segments.append(segment)
                currentSegment = nil
            }
        }
        else if elementName == "trkpt" || elementName == "wpt"{
            if let segment = currentSegment, let point = currentPoint{
                segment.points.append(point)
                currentPoint = nil
            }
        }
    }
    
}
