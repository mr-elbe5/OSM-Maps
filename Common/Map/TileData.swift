/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import OSLog

struct TileData: Codable{
    
    static var zero = TileData(zoom: 0, x: 0, y: 0)
    
    init(zoom: Int, x: Int, y: Int) {
        self.zoom = zoom
        self.x = x
        self.y = y
    }
    
    var zoom: Int
    var x: Int
    var y: Int
    var flag: Bool = false
    
    var shortDescription : String{
        "\(zoom)-\(x)-\(y)"
    }
    
    func fileUrl(tileSource: TileSource) -> URL{
        BasePaths.tileDirURL.appendingPathComponent(tileSource.name).appendingPathComponent("\(shortDescription).png")
    }
    
    func exists(tileSource: TileSource) -> Bool{
        FileManager.default.fileExists(atPath: fileUrl(tileSource: tileSource).path)
    }
    
}

typealias TileDataList = [TileData]

typealias TileDataGrid = [[TileData]]

extension TileDataGrid{
    
    init(minX: Int, maxX: Int, minY: Int, maxY: Int, zoom: Int){
        self.init()
        for y in minY...maxY{
            var line = TileDataList()
            for x in minX...maxX{
                line.append(TileData(zoom: zoom, x: x, y: y))
            }
            append(line)
        }
    }
    
    func get(x: Int, y: Int) -> TileData{
        self[y][x]
    }
    
}

struct TileDataBlock: Codable{
    
    var minX: Int
    var maxX: Int
    var minY: Int
    var maxY: Int
    var minZoom: Int
    var maxZoom: Int
    var grids: [TileDataGrid]
    
    init(minZoom: Int, maxZoom: Int, minX: Int, maxX: Int, minY: Int, maxY: Int){
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        self.minX = minX
        self.maxX = maxX
        self.minY = minY
        self.maxY = maxY
        grids = [TileDataGrid]()
        for z in minZoom...maxZoom{
            var grid = TileDataGrid(minX: minX, maxX: maxX, minY: minY, maxY: maxY, zoom: z)
        }
    }
    
}
