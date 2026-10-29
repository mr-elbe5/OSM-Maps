/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation
import OSLog

class TileRegion : CoordinateRegion{
    
    var minZoom : Int = 0
    var maxZoom : Int = 0
    var size : Int = 0
    
    var tiles = TileDataBlock()
    
    override init(){
        super.init()
    }
    
    init(topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D, minZoom: Int, maxZoom: Int){
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        super.init(topLeft: topLeft, bottomRight: bottomRight)
        tiles.setup(minZoom: minZoom, maxZoom: maxZoom, minLon: minLongitude, maxLon: maxLongitude, minLat: minLatitude, maxLat: maxLatitude)
        size = tiles.size
    }
    
    init(minLatitude: CLLocationDegrees, maxLatitude: CLLocationDegrees, minLongitude: CLLocationDegrees, maxLongitude: CLLocationDegrees, minZoom: Int,  maxZoom: Int, complete: Bool){
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        super.init(minLatitude: minLatitude, maxLatitude: maxLatitude, minLongitude: minLongitude, maxLongitude: maxLongitude)
        tiles.setup(minZoom: minZoom, maxZoom: maxZoom, minLon: minLongitude, maxLon: maxLongitude, minLat: minLatitude, maxLat: maxLatitude)
        size = tiles.size
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    func updateTileSets(){
        tiles.update(minZoom: minZoom, maxZoom: maxZoom)
        size = tiles.size
    }
    
    func getCopy(maxZoom: Int, complete: Bool) -> TileRegion{
        TileRegion(minLatitude: minLatitude, maxLatitude: maxLatitude, minLongitude: minLongitude, maxLongitude: maxLongitude, minZoom: minZoom, maxZoom: maxZoom, complete: complete)
    }
    
    func getJson() -> String{
        let json:String = toJSON()
        Logger.debug("encoded tile region size: \(json.size())")
        return json
    }
    
    override var string : String{
        super.string + ", size = \(size)"
    }
    
}
