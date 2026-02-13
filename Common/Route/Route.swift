/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

enum RouteType: String, CaseIterable {
    case car
    case bike
    case foot
    
    static func getRouteType(idx: Int) -> RouteType {
        RouteType.allCases[idx]
    }
    
    static func getRouteTypeIndex(type: RouteType) -> Int {
        RouteType.allCases.firstIndex(of: type) ?? 0
    }
}

class Route: NSObject, Codable{
    
    static func loadFromFile(gpxUrl: URL) -> Route?{
        if let data = FileManager.default.readFile(url: gpxUrl){
            let parser = XMLParser(data: data)
            let route = Route()
            parser.delegate = route
            guard parser.parse() else { return nil }
            return route
        }
        return nil
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case desc
        case creationDate
        case navigationPoints
        case type
        case distance
        case duration
        case trackpoints
        case routepoints
        case waypoints //deprecated
        case coordinateRegion
        case centerCoordinateLatitude
        case centerCoordinateLongitude
    }
    
    var name : String
    var desc = ""
    var creationDate: Date
    var navigationPoints: MapPointList = []
    var type: RouteType = .car
    var distance: Int = 0
    var duration: TimeInterval = 0.0
    var trackpoints: TrackpointList = []
    var routepoints: RoutepointList = []
    
    var coordinateRegion : CoordinateRegion? = nil
    var centerCoordinate : CLLocationCoordinate2D? = nil
    
    var currentTag: String? = nil
    var currentPoint: Mappoint? = nil
    
    var startCoordinate: CLLocationCoordinate2D?{
        trackpoints.first?.coordinate
    }
    
    var endCoordinate: CLLocationCoordinate2D?{
        trackpoints.last?.coordinate
    }
    
    var canBeRequested: Bool{
        navigationPoints.count > 1 && allNavigationPointsSet
    }
    
    var allNavigationPointsSet: Bool{
        navigationPoints.allSatisfy({
            $0 != .zero
        })
    }
    
    var anyNavigationPointsSet: Bool{
        !navigationPoints.allSatisfy({
            $0 == .zero
        })
    }
    
    var isEditable: Bool{
        !navigationPoints.isEmpty
    }
    
    var isComplete: Bool{
        navigationPoints.count > 1 && allNavigationPointsSet && !trackpoints.isEmpty
    }
    
    var worldRect: CGRect?{
        coordinateRegion?.worldRect
    }
    
    override init(){
        name = "Route"
        creationDate = Date()
        navigationPoints.append(.zero)
        navigationPoints.append(.zero)
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Route"
        desc = try container.decodeIfPresent(String.self, forKey: .desc) ?? ""
        creationDate = try container.decodeIfPresent(Date.self, forKey: .creationDate) ?? .zero
        let s = try container.decodeIfPresent(String.self, forKey: .type)
        if let s, let type = RouteType(rawValue: s) {
            self.type = type
        }
        distance = try container.decodeIfPresent(Int.self, forKey: .distance) ?? 0
        duration = try container.decodeIfPresent(TimeInterval.self, forKey: .duration) ?? 0.0
        if container.contains(.trackpoints){
            trackpoints = try container.decodeIfPresent(TrackpointList.self, forKey: .trackpoints) ?? []
            routepoints = try container.decodeIfPresent(RoutepointList.self, forKey: .routepoints) ?? []
        }
        else{ //deprecated
            trackpoints = try container.decodeIfPresent(MapPointList.self, forKey: .routepoints) ?? []
            routepoints = try container.decodeIfPresent(Array<Routepoint>.self, forKey: .waypoints) ?? []
        }
        coordinateRegion = try container.decodeIfPresent(CoordinateRegion.self, forKey: .coordinateRegion)
        if let lat = try container.decodeIfPresent(CLLocationDegrees.self, forKey: .centerCoordinateLatitude), lat != 0,
           let lon = try container.decodeIfPresent(CLLocationDegrees.self, forKey: .centerCoordinateLongitude){
            if lat != 0 || lon != 0{
                centerCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
        }
        super.init()
        if coordinateRegion == nil{
            updateCoordinateRegion()
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(desc, forKey: .desc)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encodeIfPresent(type.rawValue, forKey: .type)
        try container.encode(distance, forKey: .distance)
        try container.encode(duration, forKey: .duration)
        try container.encode(trackpoints, forKey: .trackpoints)
        try container.encode(routepoints, forKey: .routepoints)
        try container.encode(coordinateRegion, forKey: .coordinateRegion)
        try container.encodeIfPresent(centerCoordinate?.latitude, forKey: .centerCoordinateLatitude)
        try container.encodeIfPresent(centerCoordinate?.longitude, forKey: .centerCoordinateLongitude)
    }
    
    func reset(){
        name = "Route"
        creationDate = Date()
        navigationPoints = [.zero, .zero]
        type = .car
        distance = 0
        duration = 0
        trackpoints.removeAll()
        routepoints.removeAll()
    }
    
    func updateCoordinateRegion(){
        let cr = CoordinateRegion()
        if let start = trackpoints.first{
            cr.minLatitude = start.coordinate.latitude
            cr.maxLatitude = start.coordinate.latitude
            cr.minLongitude = start.coordinate.longitude
            cr.maxLongitude = start.coordinate.longitude
            for i in 1..<self.trackpoints.count{
                let tp = trackpoints[i]
                if tp.coordinate.latitude < cr.minLatitude{
                    cr.minLatitude = tp.coordinate.latitude
                }
                if tp.coordinate.latitude > cr.maxLatitude{
                    cr.maxLatitude = tp.coordinate.latitude
                }
                if tp.coordinate.longitude < cr.minLongitude{
                    cr.minLongitude = tp.coordinate.longitude
                }
                if tp.coordinate.longitude > cr.maxLongitude{
                    cr.maxLongitude = tp.coordinate.longitude
                }
            }
            coordinateRegion = cr
            centerCoordinate = cr.center
        }
    }
    
    func updateRoutePoints(){
        var date = creationDate
        for pnt in routepoints{
            date += TimeInterval(pnt.duration)
            pnt.timestamp = date
        }
    }
    
    func createGPXFile() -> URL?{
        let fileName = name.replacingOccurrences(of: " ", with: "_")
        if let url = URL(string: "route_\(fileName).gpx", relativeTo: URL.temporaryDirectory){
            let s = gpxString()
            if let data = s.data(using: .utf8){
                return FileManager.default.saveFile(data : data, url: url) ? url : nil
            }
        }
        return nil
    }
    
    func gpxString() -> String{
        var str = """
            <?xml version='1.0' encoding='UTF-8'?>
            <gpx version="1.1" creator="OSM Maps" xmlns="http://www.topografix.com/GPX/1/1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">
                <metadata>
                    <name>\(name)</name>
                    <time>\(creationDate.isoString())</time>
                </metadata>
                <rte>
                    <name>\(name)</name>
                    <desc>\(desc)</desc>
                    <type>\(type.rawValue)</type>
            """
        for pnt in routepoints{
            str += pnt.gpxString
        }
        str += """
                
                </rte>
                <trk>
                    <trkseg>
            """
        for tp in trackpoints{
            str += tp.gpxString
        }
        str += """
                
                </trkseg>
            </trk>
        </gpx>
        """
        return str
    }
    
}

extension Route : XMLParserDelegate{
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentTag = elementName
        switch elementName{
        case "trkpt":
            guard let latString = attributeDict["lat"], let lonString = attributeDict["lon"] else { return }
            guard let lat = Double(latString), let lon = Double(lonString) else { return }
            guard let latDegrees = CLLocationDegrees(exactly: lat), let lonDegrees = CLLocationDegrees(exactly: lon) else { return }
            currentPoint = Trackpoint(coordinate: CLLocationCoordinate2D(latitude: latDegrees, longitude: lonDegrees))
        case "rtept":
            guard let latString = attributeDict["lat"], let lonString = attributeDict["lon"] else { return }
            guard let lat = Double(latString), let lon = Double(lonString) else { return }
            guard let latDegrees = CLLocationDegrees(exactly: lat), let lonDegrees = CLLocationDegrees(exactly: lon) else { return }
            currentPoint = Routepoint(coordinate: CLLocationCoordinate2D(latitude: latDegrees, longitude: lonDegrees))
        case "wpt":
            guard let latString = attributeDict["lat"], let lonString = attributeDict["lon"] else { return }
            guard let lat = Double(latString), let lon = Double(lonString) else { return }
            guard let latDegrees = CLLocationDegrees(exactly: lat), let lonDegrees = CLLocationDegrees(exactly: lon) else { return }
            currentPoint = Routepoint(latitude: latDegrees, longitude: lonDegrees)
        default :
            break
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if string.isEmpty{
            return
        }
        switch currentTag{
        case "name":
            name += string
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
        switch currentTag{
        case "trkpt":
            if let point = currentPoint as? Trackpoint{
                trackpoints.append(point)
                currentPoint = nil
            }
        case "rtepnt":
            if let point = currentPoint as? Routepoint{
                navigationPoints.append(point)
                currentPoint = nil
            }
        case  "wpt":
            if let point = currentPoint as? Routepoint{
                routepoints.append(point)
                currentPoint = nil
            }
        default:
            break
        }
        currentTag = nil
    }
    
}
    
