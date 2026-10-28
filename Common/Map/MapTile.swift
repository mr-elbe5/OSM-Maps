/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import OSLog

class MapTile{
    
    static func getTile(data: MapTileData, tileSource: TileSource) -> MapTile{
        let tile = MapTile(zoom: data.zoom, x: data.x, y: data.y, tileSource: tileSource)
        //Logger.debug("get tile \(tile.shortDescription)")
        if tile.fileExists, let fileData = FileManager.default.contents(atPath: tile.fileUrl.path){
            tile.imageData = fileData
        }
        return tile
    }
    
    static var dummyTile: MapTile = MapTile(zoom: 0, x: 0, y: 0, tileSource: TileSource.dummyTileSource)

    var x: Int
    var y: Int
    var zoom: Int
    
    var tileSource: TileSource
    
    var imageData : Data? = nil
    
    init(zoom: Int, x: Int, y: Int, tileSource: TileSource){
        self.zoom = zoom
        self.x = x
        self.y = y
        self.tileSource = tileSource
    }
    
    var valid: Bool{
        zoom >= 0 && zoom <= 18 && x >= 0 && y >= 0
    }
    
    var fileUrl: URL{
        BasePaths.tileDirURL.appendingPathComponent(tileSource.name).appendingPathComponent("\(shortDescription).png")
    }
    
    var fileExists: Bool{
        FileManager.default.fileExists(atPath: fileUrl.path)
    }
    
    var shortDescription : String{
        "\(zoom)-\(x)-\(y)"
    }
    
    var rectInZoomedWorld : CGRect{
        let origin = CGPoint(x: Double(x)*World.tileExtent , y: Double(y)*World.tileExtent)
        return CGRect(origin: origin, size: World.tileSize)
    }
    
    var rectInWorld : CGRect{
        let scale = World.upScale(from: zoom)
        let origin = CGPoint(x: Double(x)*World.tileExtent*scale , y: Double(y)*World.tileExtent*scale)
        let scaledTileExtent = World.tileExtent/scale
        return CGRect(origin: origin, size: CGSize(width: scaledTileExtent, height: scaledTileExtent))
    }
        
    var tileUrl: URL{
        URL(string: tileSource.templateUrl.replacingOccurrences(of: "{z}", with: String(zoom)).replacingOccurrences(of: "{x}", with: String(x)).replacingOccurrences(of: "{y}", with: String(y)))!
    }
    
}

typealias MapTileList = [MapTile]

struct MapTileData: Codable{
    
    init(zoom: Int, x: Int, y: Int, tileSource: TileSource) {
        self.zoom = zoom
        self.x = x
        self.y = y
        self.tileSource = tileSource
    }
    
    var zoom: Int
    var x: Int
    var y: Int
    
    var tileSource: TileSource
    
    var shortDescription : String{
        "\(zoom)-\(x)-\(y)"
    }
    
    var fileUrl: URL{
        BasePaths.tileDirURL.appendingPathComponent(tileSource.name).appendingPathComponent("\(shortDescription).png")
    }
    
    var exists: Bool{
        FileManager.default.fileExists(atPath: fileUrl.path)
    }
    
}

typealias MapTileDataList = [MapTileData]
