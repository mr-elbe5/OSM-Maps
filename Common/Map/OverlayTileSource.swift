/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import OSLog

class OverlayTileSource: TileSource{
    
    static var waymarkedTrailsSource: OverlayTileSource = OverlayTileSource(name: "waymarkedTrails", displayName: "Waymarked Trails", templateUrl: "https://tile.waymarkedtrails.org/hiking/{z}/{x}/{y}.png")
    
    enum CodingKeys: String, CodingKey {
        case idx
        case active
    }
    
    var idx: Int = 0
    var active: Bool = false
    
    override init(name: String, displayName: String, templateUrl: String){
        super.init(name: name, displayName: displayName, templateUrl: templateUrl)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try idx = values.decode(Int.self, forKey: .idx)
        try active = values.decode(Bool.self, forKey: .active)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(idx, forKey: .idx)
        try container.encode(active, forKey: .active)
    }
    
}

extension OverlayTileSource: Comparable{
    
    public static func < (lhs: OverlayTileSource, rhs: OverlayTileSource) -> Bool {
        lhs.idx < rhs.idx
    }
    
}

typealias OverlayTileSources = Array<OverlayTileSource>

extension OverlayTileSources{
    
    static var storeKey = "overlayTileSources"
    
    static var shared: OverlayTileSources = [.waymarkedTrailsSource]
    
    static func load(){
        if let list : OverlayTileSources = StatusManager.shared.getCodable(key: OverlayTileSources.storeKey){
            OverlayTileSources.shared = list
            OverlayTileSources.shared.updateIndices()
        }
        else{
            Logger.error("no saved data available for overlay tile sources")
        }
    }
    
    static func setDefaults(){
        shared = [.waymarkedTrailsSource]
        shared.save()
    }
    
    func save(){
        StatusManager.shared.saveCodable(key: Self.storeKey, value: self)
        Logger.debug("overlay tile sources saved")
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
    
    func getByName(_ name: String) -> OverlayTileSource?{
        for i in 0..<count{
            if self[i].name == name{
                return self[i]
            }
        }
        return nil
    }
    
    func getByUrl(_ url: String) -> OverlayTileSource?{
        for i in 0..<count{
            if self[i].templateUrl == url{
                return self[i]
            }
        }
        return nil
    }
    
    mutating func remove(_ tileSource: OverlayTileSource){
        if tileSource != .defaultTileSource{
            self.removeAll(where: { $0 == tileSource})
            if Settings.shared.tileSource == tileSource{
                Settings.shared.tileSource = .defaultTileSource
            }
        }
    }
    
    mutating func moveUp(idx: Int){
        if idx == 0{
            return
        }
        let source = self.remove(at: idx)
        self.insert(source, at: idx-1)
        updateIndices()
        save()
    }
    
    func updateIndices(){
        for i in 0..<count{
            self[i].idx = i
        }
    }
    
}
