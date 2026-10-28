/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation
import OSLog

class TileGrid : Codable{
    
    private enum CodingKeys: String, CodingKey {
        case zoom
        case minX
        case minY
        case maxX
        case maxY
        case tileLines
    }
    
    var zoom = 0
    var minX = 0
    var minY = 0
    var maxX = 0
    var maxY = 0
    
    var tileLines = TileLineList()
    
    var tileSource: TileSource{
        Settings.shared.tileSource
    }
    
    subscript(index: Int) -> TileLine {
        get {
            if index < 0 || index >= tileLines.count{
                return TileLine.emptyLine
            }
            return tileLines[index]
        }
        set(newValue) {
            if index >= 0 && index < tileLines.count{
                tileLines[index] = newValue
            }
        }
    }
    
    init(){
    }
    
    init(zoom: Int, minX: Int, minY: Int, maxX: Int, maxY: Int){
        self.zoom = zoom
        self.minX = min(minX, maxX)
        self.maxX = max(maxX, minX)
        self.minY = min(minY, maxY)
        self.maxY = max(maxY, minY)
    }
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        zoom = try values.decodeIfPresent(Int.self, forKey: .zoom) ?? 0
        minX = try values.decodeIfPresent(Int.self, forKey: .minX) ?? 0
        maxX = try values.decodeIfPresent(Int.self, forKey: .maxX) ?? 0
        minY = try values.decodeIfPresent(Int.self, forKey: .minY) ?? 0
        maxY = try values.decodeIfPresent(Int.self, forKey: .maxY) ?? 0
        tileLines = try values.decodeIfPresent(TileLineList.self, forKey: .tileLines) ?? TileLineList()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(zoom, forKey: .zoom)
        try container.encode(minX, forKey: .minX)
        try container.encode(maxX, forKey: .maxX)
        try container.encode(minY, forKey: .minY)
        try container.encode(maxY, forKey: .maxY)
        try container.encode(tileLines, forKey: .tileLines)
    }
    
    var size : Int{
        (maxX - minX + 1) * (maxY - minY + 1)
    }
    
    func initTiles(){
        tileLines.removeAll()
        for y in minY...maxY{
            let line = TileLine(zoom: zoom, y: y, minX: minX, maxX: maxX)
            tileLines.append(line)
            line.initTiles()
        }
    }
    
    /*func getTile(xidx: Int, yidx: Int) -> Tile{
        tileLines[yidx].getTile(xidx: xidx)
    }
    
    */
    
    func checkExistingTiles(tileSource: TileSource) -> Int{
        var count : Int = 0
        for line in tileLines{
            count += line.checkExistingTiles(tileSource: tileSource)
        }
        return count
    }
    
    func getExistingTiles() -> Int{
        var count : Int = 0
        for line in tileLines{
            count += line.getExistingTiles()
        }
        return count
    }
    
}

typealias TileGridList = Array<TileGrid>

class TileLine : Codable{
    
    static var emptyLine = TileLine()
    
    private enum CodingKeys: String, CodingKey {
        case zoom
        case y
        case minX
        case maxX
        case tiles
    }
    
    var zoom = 0
    var y = 0
    var minX = 0
    var maxX = 0
    
    var tiles = TileList()
    
    var tileSource: TileSource{
        Settings.shared.tileSource
    }
    
    subscript(index: Int) -> Tile {
        get {
            if index < 0 || index >= tiles.count{
                return Tile.nullTile
            }
            return tiles[index]
        }
        set(newValue) {
            if index >= 0 && index < tiles.count{
                tiles[index] = newValue
            }
        }
    }
    
    init(){
    }
    
    init(zoom: Int, y: Int, minX: Int, maxX: Int){
        self.zoom = zoom
        self.y = y
        self.minX = min(minX, maxX)
        self.maxX = max(maxX, minX)
    }
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        zoom = try values.decodeIfPresent(Int.self, forKey: .zoom) ?? 0
        y = try values.decodeIfPresent(Int.self, forKey: .y) ?? 0
        minX = try values.decodeIfPresent(Int.self, forKey: .minX) ?? 0
        maxX = try values.decodeIfPresent(Int.self, forKey: .maxX) ?? 0
        tiles = try values.decodeIfPresent(TileList.self, forKey: .tiles) ?? TileList()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(zoom, forKey: .zoom)
        try container.encode(y, forKey: .y)
        try container.encode(minX, forKey: .minX)
        try container.encode(maxX, forKey: .maxX)
        try container.encode(tiles, forKey: .tiles)
    }
    
    func initTiles(){
        tiles.removeAll()
        for x in minX...maxX{
            let tile = Tile(zoom: zoom, x: x,  y: y)
            tiles.append(tile)
        }
    }
    
    /*func getTile(x: Int) -> Tile{
        tiles[x]
    }
    
    */
    
    func checkExistingTiles(tileSource: TileSource) -> Int{
        var count : Int = 0
        for tile in tiles{
            tile.checkFileExists()
            if tile.present{
                count += 1
            }
        }
        return count
    }
    
    func getExistingTiles() -> Int{
        var count : Int = 0
        for tile in tiles{
            if tile.present{
                count += 1
            }
        }
        return count
    }
    
}

typealias TileLineList = Array<TileLine>
