/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation
import OSLog

class TileRegion : CoordinateRegion{
    
    private enum CodingKeys: String, CodingKey {
        case minZoom
        case maxZoom
        case size
        case zoomGrids
    }
    
    var minZoom : Int = 0
    var maxZoom : Int = 0
    var size : Int = 0
    
    var zoomGrids = TileGridList()
    
    var isEmpty: Bool{
        zoomGrids.isEmpty
    }
    
    override init(){
        super.init()
    }
    
    init(topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D, minZoom: Int,  maxZoom: Int, complete: Bool){
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        super.init(topLeft: topLeft, bottomRight: bottomRight)
        setupTiles(complete: complete)
    }
    
    init(minLatitude: CLLocationDegrees, maxLatitude: CLLocationDegrees, minLongitude: CLLocationDegrees, maxLongitude: CLLocationDegrees, minZoom: Int,  maxZoom: Int, complete: Bool){
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        super.init(minLatitude: minLatitude, maxLatitude: maxLatitude, minLongitude: minLongitude, maxLongitude: maxLongitude)
        setupTiles(complete: complete)
    }
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        minZoom = try values.decodeIfPresent(Int.self, forKey: .minZoom) ?? 0
        maxZoom = try values.decodeIfPresent(Int.self, forKey: .maxZoom) ?? 0
        size = try values.decodeIfPresent(Int.self, forKey: .size) ?? 0
        zoomGrids = try values.decodeIfPresent(TileGridList.self, forKey: .zoomGrids) ?? TileGridList()
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(minZoom, forKey: .minZoom)
        try container.encode(maxZoom, forKey: .maxZoom)
        try container.encode(size, forKey: .size)
        try container.encode(zoomGrids, forKey: .zoomGrids)
    }
    
    func getCopy(maxZoom: Int, complete: Bool) -> TileRegion{
        TileRegion(minLatitude: minLatitude, maxLatitude: maxLatitude, minLongitude: minLongitude, maxLongitude: maxLongitude, minZoom: minZoom, maxZoom: maxZoom, complete: complete)
    }
    
    func getJson() -> String{
        let json:String = toJSON()
        Logger.debug("encoded tile region size: \(json.size())")
        return json
    }
    
    func setupTiles(complete: Bool){
        zoomGrids.removeAll()
        size = 0
        for zoom in minZoom...maxZoom{
            let bottomLeftTile = tileCoordinate(latitude: minLatitude, longitude: minLongitude, zoom: zoom)
            let topRightTile = tileCoordinate(latitude: maxLatitude, longitude: maxLongitude, zoom: zoom)
            let tileGrid = TileGrid(zoom: zoom, minX: bottomLeftTile.x, minY: bottomLeftTile.y, maxX: topRightTile.x, maxY: topRightTile.y)
            size += tileGrid.size
            zoomGrids.append(tileGrid)
            if complete{
                tileGrid.initTiles()
            }
        }
    }
    
    func checkExistingTiles(tileSource: TileSource) -> Int{
        var count : Int = 0
        for zoomLevel in zoomGrids{
            count += zoomLevel.checkExistingTiles(tileSource: tileSource)
        }
        return count
    }
    
    func getExistingTiles() -> Int{
        var count : Int = 0
        for zoomLevel in zoomGrids{
            count += zoomLevel.getExistingTiles()
        }
        return count
    }
    
    func tileCoordinate(latitude: CLLocationDegrees, longitude: CLLocationDegrees, zoom: Int) -> (x: Int, y: Int){
        let x = World.tileX(longitude, withZoom: zoom)
        let y = World.tileY(latitude, withZoom: zoom)
        return (x: Int(x), y: Int(y))
    }
    
    override var string : String{
        super.string + ", size = \(size)"
    }
    
}
