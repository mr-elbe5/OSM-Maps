/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation
import OSLog

@Observable class Tile: NSObject, Codable{
    
    static var zero = Tile(zoom: 0, x: 0, y: 0)
    
    static func == (lhs: Tile, rhs: Tile) -> Bool{
        lhs.x == rhs.x && lhs.y == rhs.y && lhs.zoom == rhs.zoom
    }
    
    static func getTile(data: Tile, tileSource: TileSource) -> Tile{
        let tile = Tile(zoom: data.zoom, x: data.x, y: data.y, tileSource: tileSource)
        if tile.fileExists, let fileData = FileManager.default.contents(atPath: tile.fileUrl.path){
            tile.imageData = fileData
        }
        return tile
    }
    
    private enum CodingKeys: String, CodingKey {
        case zoom
        case x
        case y
        case present
    }
    
    var zoom = 0
    var x = 0
    var y = 0
    var present : Bool = false
    var imageData : Data? = nil
    var tileSource : TileSource = Settings.shared.tileSource
    
    var valid: Bool{
        zoom >= 0 && zoom <= 18 && x >= 0 && y >= 0
    }
    
    var fileUrl: URL{
        BasePaths.tileDirURL.appendingPathComponent(tileSource.name).appendingPathComponent("\(asString).png")
    }
    
    var fileExists: Bool{
        FileManager.default.fileExists(atPath: fileUrl.path)
    }
    
    init(zoom: Int, x: Int, y: Int){
        self.zoom = zoom
        self.x = x
        self.y = y
    }
    
    init(zoom: Int, x: Int, y: Int, tileSource: TileSource){
        self.zoom = zoom
        self.x = x
        self.y = y
        self.tileSource = tileSource
    }
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        zoom = try values.decodeIfPresent(Int.self, forKey: .zoom) ?? 0
        x = try values.decodeIfPresent(Int.self, forKey: .x) ?? 0
        y = try values.decodeIfPresent(Int.self, forKey: .y) ?? 0
        present = try values.decodeIfPresent(Bool.self, forKey: .present) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(zoom, forKey: .zoom)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
        try container.encode(present, forKey: .present)
    }
    
    func change(zoom: Int, x: Int, y: Int, tileSource: TileSource){
        self.zoom = zoom
        self.x = x
        self.y = y
        self.tileSource = tileSource
        self.imageData = nil
    }
    
    func checkFileExists(){
        present = fileExists
    }
    
    func setImage() -> Bool{
        if imageData != nil{
            return true
        }
        if fileExists, let fileData = FileManager.default.contents(atPath: fileUrl.path){
            imageData = fileData
            return true
        }
        return false
    }
    
    var asString : String{
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

typealias TileList = Array<Tile>
typealias TileArea = Array<TileList>

