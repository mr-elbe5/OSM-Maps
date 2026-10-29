/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import OSLog

class TileData: Codable{
    
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
    
    var minLon: Double = 0
    var maxLon: Double = 0
    var minLat: Double = 0
    var maxLat: Double = 0
    var minZoom: Int = 0
    var maxZoom: Int = 0
    var grids = [TileDataGrid]()
    
    var size: Int{
        var count = 0
        for grid in grids{
            if !grid.isEmpty{
                count += grid.count * grid[0].count
            }
        }
        return count
    }
    
    init(){
    }
    
    mutating func setup(minZoom: Int, maxZoom: Int, minLon: Double, maxLon: Double, minLat: Double, maxLat: Double){
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        self.minLon = minLon
        self.maxLon = maxLon
        self.minLat = minLat
        self.maxLat = maxLat
        setupGrids()
    }
    
    mutating func update(minZoom: Int, maxZoom: Int){
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        setupGrids()
    }
    
    private mutating func setupGrids(){
        grids.removeAll()
        for z in minZoom...maxZoom{
            let minX = World.tileX(minLon, withZoom: z)
            let minY = World.tileY(maxLat, withZoom: z)
            let maxX = World.tileX(maxLon, withZoom: z)
            let maxY = World.tileY(minLat, withZoom: z)
            let grid = TileDataGrid(minX: minX, maxX: maxX, minY: minY, maxY: maxY, zoom: z)
            grids.append(grid)
        }
    }
    
    func checkExistingTiles(tileSource: TileSource) -> Int{
        var count : Int = 0
        for grid in grids{
            for line in grid{
                for tile in line{
                    if tile.exists(tileSource: tileSource){
                        tile.flag = true
                        count += 1
                    }
                }
            }
        }
        return count
    }
    
    func getExistingTiles() -> Int{
        var count : Int = 0
        for grid in grids{
            for line in grid{
                for tile in line{
                    if tile.flag{
                        count += 1
                    }
                }
            }
        }
        return count
    }
    
}
