/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

class MapSource: Codable, Hashable{
    
    static func == (lhs: MapSource, rhs: MapSource) -> Bool {
        lhs.templateUrl == rhs.templateUrl
    }
    
    static var osmSource: MapSource = MapSource(name: "osm", displayName: "OpenStreetMap", templateUrl: "https://tile.openstreetmap.org/{z}/{x}/{y}.png")
    static var elbe5Source: MapSource = MapSource(name: "elbe5", displayName: "Elbe5 Carto", templateUrl: "https://tiles.elbe5.de/carto/{z}/{x}/{y}.png")
    static var elbe5TopoSource: MapSource = MapSource(name: "elbe5Topo", displayName: "Elbe5 Topo", templateUrl: "https://tiles.elbe5.de/topo/{z}/{x}/{y}.png")
    //static var waymarkedTrailsSource: MapSource = MapSource(name: "waymarkedTrails", displayName: "Waymarked Trails", templateUrl: "https://tile.waymarkedtrails.org/hiking/{z}/{x}/{y}.png")
    static var openTopoSource: MapSource = MapSource(name: "openTopo", displayName: "Open Topomap", templateUrl: "https://a.tile.opentopomap.org/{z}/{x}/{y}.png")
    
    enum CodingKeys: String, CodingKey {
        case name
        case displayName
        case templateUrl
    }
    
    var name: String
    var displayName: String
    var templateUrl: String
    
    init(name: String, displayName: String, templateUrl: String){
        self.name = name
        self.displayName = displayName
        self.templateUrl = templateUrl
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try self.name = values.decode(String.self, forKey: .name)
        try self.displayName = values.decode(String.self, forKey: .displayName)
        try self.templateUrl = values.decode(String.self, forKey: .templateUrl)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(templateUrl, forKey: .templateUrl)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

typealias MapSources = Array<MapSource>

extension MapSources{
    
    static var storeKey = "mapSources"
    
    static var shared: MapSources = [.osmSource, .elbe5Source, .elbe5TopoSource, .openTopoSource]
    
    static func load(){
        if let list : MapSources = StatusManager.shared.getCodable(key: MapSources.storeKey){
            MapSources.shared = list
        }
        else{
            Log.error("no saved data available for map sources")
        }
    }
    
    var names: Array<String>{
        var list = Array<String>()
        for i in 0..<count{
            list.append(self[i].name)
        }
        return list
    }
    
    var displayNames: Array<String>{
        var list = Array<String>()
        for i in 0..<count{
            list.append(self[i].displayName)
        }
        return list
    }
    
    func indexOf(source: MapSource) -> Int{
        for i in 0..<count{
            if self[i].name == source.name{
                return i
            }
        }
        return 0
    }
    
    func getByUrl(_ url: String) -> MapSource?{
        for i in 0..<count{
            if self[i].templateUrl == url{
                return self[i]
            }
        }
        return nil
    }
    
    func save(){
        StatusManager.shared.saveCodable(key: MapSources.storeKey, value: self)
        Log.debug("map sources saved")
    }
    
}

