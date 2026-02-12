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
        case navigationPoints
        case type
        case distance
        case duration
        case routepoints
        case waypoints
        case coordinateRegion
        case centerCoordinateLatitude
        case centerCoordinateLongitude
    }
    
    var name : String
    var navigationPoints: MapPointList = []
    var type: RouteType = .car
    var distance: Int = 0
    var duration: TimeInterval = 0.0
    var routepoints: RoutepointList = []
    var waypoints: Array<Waypoint> = []
    
    var coordinateRegion : CoordinateRegion? = nil
    var centerCoordinate : CLLocationCoordinate2D? = nil
    
    var currentTag: String? = nil
    var currentRoutepoint: Routepoint? = nil
    var currentWaypoint: Waypoint? = nil
    
    var startCoordinate: CLLocationCoordinate2D?{
        routepoints.first?.coordinate
    }
    
    var endCoordinate: CLLocationCoordinate2D?{
        routepoints.last?.coordinate
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
        navigationPoints.count > 1 && allNavigationPointsSet && !routepoints.isEmpty
    }
    
    var worldRect: CGRect?{
        coordinateRegion?.worldRect
    }
    
    override init(){
        name = "Route"
        navigationPoints.append(.zero)
        navigationPoints.append(.zero)
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Route"
        let s = try container.decodeIfPresent(String.self, forKey: .type)
        if let s, let type = RouteType(rawValue: s) {
            self.type = type
        }
        distance = try container.decodeIfPresent(Int.self, forKey: .distance) ?? 0
        duration = try container.decodeIfPresent(TimeInterval.self, forKey: .duration) ?? 0.0
        routepoints = try container.decodeIfPresent(MapPointList.self, forKey: .routepoints) ?? []
        waypoints = try container.decodeIfPresent(Array<Waypoint>.self, forKey: .waypoints) ?? []
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
        try container.encodeIfPresent(type.rawValue, forKey: .type)
        try container.encode(distance, forKey: .distance)
        try container.encode(duration, forKey: .duration)
        try container.encode(routepoints, forKey: .routepoints)
        try container.encode(waypoints, forKey: .waypoints)
        try container.encode(coordinateRegion, forKey: .coordinateRegion)
        try container.encodeIfPresent(centerCoordinate?.latitude, forKey: .centerCoordinateLatitude)
        try container.encodeIfPresent(centerCoordinate?.longitude, forKey: .centerCoordinateLongitude)
    }
    
    func reset(){
        name = "Route"
        navigationPoints = [.zero, .zero]
        type = .car
        distance = 0
        duration = 0
        routepoints.removeAll()
        waypoints.removeAll()
    }
    
    func updateCoordinateRegion(){
        let cr = CoordinateRegion()
        if let start = routepoints.first{
            cr.minLatitude = start.coordinate.latitude
            cr.maxLatitude = start.coordinate.latitude
            cr.minLongitude = start.coordinate.longitude
            cr.maxLongitude = start.coordinate.longitude
            for i in 1..<self.routepoints.count{
                let tp = routepoints[i]
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
                </metadata>
                <rte>
            """
            for pnt in routepoints{
                str += pnt.gpxString
            }
            str += """
        
                </rte>
            </gpx>
        """
        return str
    }
    
}

extension Route : XMLParserDelegate{
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentTag = elementName
        switch elementName{
        case "trkpt", "rtept":
            guard let latString = attributeDict["lat"], let lonString = attributeDict["lon"] else { return }
            guard let lat = Double(latString), let lon = Double(lonString) else { return }
            guard let latDegrees = CLLocationDegrees(exactly: lat), let lonDegrees = CLLocationDegrees(exactly: lon) else { return }
            currentRoutepoint = Routepoint(coordinate: CLLocationCoordinate2D(latitude: latDegrees, longitude: lonDegrees))
        case "wpt":
            guard let latString = attributeDict["lat"], let lonString = attributeDict["lon"] else { return }
            guard let lat = Double(latString), let lon = Double(lonString) else { return }
            guard let latDegrees = CLLocationDegrees(exactly: lat), let lonDegrees = CLLocationDegrees(exactly: lon) else { return }
            currentWaypoint = Waypoint(latitude: latDegrees, longitude: lonDegrees)
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
            if let point = currentRoutepoint, let timestamp = string.ISO8601Date(){
                point.timestamp = timestamp
            }
        case "ele":
            if let point = currentRoutepoint, let dist = CLLocationDistance(string){
                point.altitude =  dist
            }
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch currentTag{
        case "trkpt", "rtepnt":
            if let point = currentRoutepoint{
                routepoints.append(point)
                currentRoutepoint = nil
            }
        case  "wpt":
            if let point = currentWaypoint{
                waypoints.append(point)
                currentWaypoint = nil
            }
        default:
            break
        }
        currentTag = nil
    }
    
}
    
