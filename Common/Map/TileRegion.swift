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
    
    init(coordinateRegion: CoordinateRegion, minZoom: Int, maxZoom: Int){
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        super.init(minLatitude: coordinateRegion.minLatitude, maxLatitude: coordinateRegion.maxLatitude, minLongitude: coordinateRegion.minLongitude, maxLongitude: coordinateRegion.maxLongitude)
        tiles.setup(minZoom: minZoom, maxZoom: maxZoom, minLon: minLongitude, maxLon: maxLongitude, minLat: minLatitude, maxLat: maxLatitude)
        size = tiles.size
    }
    
    init(minLatitude: CLLocationDegrees, maxLatitude: CLLocationDegrees, minLongitude: CLLocationDegrees, maxLongitude: CLLocationDegrees, minZoom: Int,  maxZoom: Int){
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        super.init(minLatitude: minLatitude, maxLatitude: maxLatitude, minLongitude: minLongitude, maxLongitude: maxLongitude)
        tiles.setup(minZoom: minZoom, maxZoom: maxZoom, minLon: minLongitude, maxLon: maxLongitude, minLat: minLatitude, maxLat: maxLatitude)
        size = tiles.size
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    func getCopy(minZoom: Int, maxZoom: Int) -> TileRegion{
        let tileRegion = TileRegion(minLatitude: minLatitude, maxLatitude: maxLatitude, minLongitude: minLongitude, maxLongitude: maxLongitude, minZoom: minZoom, maxZoom: maxZoom)
        return tileRegion
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
