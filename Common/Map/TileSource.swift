/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

class TileSource: Codable, Hashable{
    
    static func == (lhs: TileSource, rhs: TileSource) -> Bool {
        lhs.templateUrl == rhs.templateUrl
    }
    
    static var dummyTileSource: TileSource = TileSource(name: "dummy", displayName: "Dummy", templateUrl: "")
    
    static var osmSource: TileSource = TileSource(name: "osm", displayName: "OpenStreetMap", templateUrl: "https://tile.openstreetmap.org/{z}/{x}/{y}.png")
    static var elbe5Source: TileSource = TileSource(name: "elbe5", displayName: "Elbe5 Carto", templateUrl: "https://tiles.elbe5.de/carto/{z}/{x}/{y}.png")
    static var elbe5TopoSource: TileSource = TileSource(name: "elbe5Topo", displayName: "Elbe5 Topo", templateUrl: "https://tiles.elbe5.de/topo/{z}/{x}/{y}.png")
    static var openTopoSource: TileSource = TileSource(name: "openTopo", displayName: "Open Topomap", templateUrl: "https://a.tile.opentopomap.org/{z}/{x}/{y}.png")
    
    static var waymarkedTrailsSource: TileSource = TileSource(name: "waymarkedTrails", displayName: "Waymarked Trails", templateUrl: "https://tile.waymarkedtrails.org/hiking/{z}/{x}/{y}.png")
    
    static var defaultTileSource: TileSource = TileSource.osmSource
    
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

typealias TileSources = Array<TileSource>

extension TileSources{
    
    static var storeKey = "tileSources"
    
    static var shared: TileSources = [.osmSource, .elbe5Source, .elbe5TopoSource, .openTopoSource]
    
    static var overlayStoreKey = "overlayTileSources"
    
    static var sharedOverlays: TileSources = [.waymarkedTrailsSource]
    
    static func load(){
        if let list : TileSources = StatusManager.shared.getCodable(key: TileSources.storeKey){
            TileSources.shared = list
        }
        else{
            Log.error("no saved data available for tile sources")
        }
        if let list : TileSources = StatusManager.shared.getCodable(key: TileSources.overlayStoreKey){
            TileSources.sharedOverlays = list
        }
        else{
            Log.error("no saved data available for overlay tile sources")
        }
    }
    
    static func setDefaults(){
        shared = [.osmSource, .elbe5Source, .elbe5TopoSource, .openTopoSource]
        save()
    }
    
    static func setOverlayDefaults(){
        sharedOverlays = [.waymarkedTrailsSource]
        saveOverlays()
    }
    
    static func save(){
        StatusManager.shared.saveCodable(key: storeKey, value: shared)
        Log.debug("tile sources saved")
    }
    
    static func saveOverlays(){
        StatusManager.shared.saveCodable(key: overlayStoreKey, value: sharedOverlays)
        Log.debug("overlay tile sources saved")
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
    
    func indexOf(source: TileSource) -> Int{
        for i in 0..<count{
            if self[i].name == source.name{
                return i
            }
        }
        return 0
    }
    
    func getByUrl(_ url: String) -> TileSource?{
        for i in 0..<count{
            if self[i].templateUrl == url{
                return self[i]
            }
        }
        return nil
    }
    
    mutating func remove(_ tileSource: TileSource){
        if tileSource != .defaultTileSource{
            self.removeAll(where: { $0 == tileSource})
            if Settings.shared.tileSource == tileSource{
                Settings.shared.tileSource = .defaultTileSource
            }
        }
    }
    
}
