/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation

class CoordinateRegion: Equatable, Codable{
    
    static func == (lhs: CoordinateRegion, rhs: CoordinateRegion) -> Bool {
        lhs.maxLatitude == rhs.maxLatitude && lhs.minLatitude == rhs.minLatitude && lhs.maxLongitude == rhs.maxLongitude && lhs.minLongitude == rhs.minLongitude
    }
    
    static var zero = CoordinateRegion()
    
    private enum CodingKeys: String, CodingKey {
        case minLatitude
        case maxLatitude
        case minLongitude
        case maxLongitude
    }
    
    var minLatitude : CLLocationDegrees
    var maxLatitude : CLLocationDegrees
    var minLongitude : CLLocationDegrees
    var maxLongitude : CLLocationDegrees
    
    var center: CLLocationCoordinate2D{
        CLLocationCoordinate2D(latitude: (minLatitude + maxLatitude)/2, longitude: (minLongitude + maxLongitude)/2)
    }
    
    var worldRect: CGRect{
        let x = World.worldX(minLongitude)
        let y = World.worldY(maxLatitude)
        return CGRect(x: x, y: y, width: World.worldX(maxLongitude) - x, height: World.worldY(minLatitude) - y)
    }
    
    init (){
        minLatitude = 0
        maxLatitude = 0
        minLongitude = 0
        maxLongitude = 0
    }
    
    init(topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D){
        maxLatitude = topLeft.latitude
        minLatitude = bottomRight.latitude
        minLongitude = topLeft.longitude
        maxLongitude = bottomRight.longitude
    }
    
    init(minLatitude: CLLocationDegrees, maxLatitude: CLLocationDegrees, minLongitude: CLLocationDegrees, maxLongitude: CLLocationDegrees){
        self.minLatitude = minLatitude
        self.maxLatitude = maxLatitude
        self.minLongitude = minLongitude
        self.maxLongitude = maxLongitude
    }
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        minLatitude = try values.decodeIfPresent(Double.self, forKey: .minLatitude) ?? 0
        minLongitude = try values.decodeIfPresent(Double.self, forKey: .minLongitude) ?? 0
        maxLatitude = try values.decodeIfPresent(Double.self, forKey: .maxLatitude) ?? 0
        maxLongitude = try values.decodeIfPresent(Double.self, forKey: .maxLongitude) ?? 0
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(minLatitude, forKey: .minLatitude)
        try container.encode(minLongitude, forKey: .minLongitude)
        try container.encode(maxLatitude, forKey: .maxLatitude)
        try container.encode(maxLongitude, forKey: .maxLongitude)
    }
    
    func contains(coordinate: CLLocationCoordinate2D) -> Bool{
        coordinate.latitude >= minLatitude && coordinate.latitude <= maxLatitude && coordinate.longitude >= minLongitude && coordinate.longitude <= maxLongitude
    }
    
    open var string : String{
        "minLatitude = \(minLatitude), maxLatitude = \(maxLatitude), minLongitude = \(minLongitude), maxLongitude = \(maxLongitude)"
    }
    
}
