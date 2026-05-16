/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import OSLog

class MapStatus: Identifiable, Codable{
    
    static var storeKey = "mapstatus"
    
    static var shared = MapStatus()
    
    static func load(){
        if let status : MapStatus = StatusManager.shared.getCodable(key: MapStatus.storeKey){
            shared = status
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case scale
        case latitude
        case longitude
    }
    
    var scale : CGFloat = World.downScale(to: MapDefaults.startZoom)
    var zoom: Int{
        World.zoomLevelAtDownScale(scale: scale)
    }
    var centerCoordinate: CLLocationCoordinate2D = MapDefaults.startLocation.coordinate{
        didSet {
            coordinateRegion = nil
        }
    }
    var visibleMapRect: CGRect = .zero{
        didSet{
            coordinateRegion = nil
        }
    }
    
    private var coordinateRegion: CoordinateRegion? = nil
    
    var scaledWorldCenterPoint: CGPoint{
        World.scaledPoint(centerCoordinate, downScale: scale)
    }

    init(){
        centerCoordinate = MapDefaults.startLocation.coordinate
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        scale = try values.decodeIfPresent(Double.self, forKey: .scale) ?? World.downScale(to: MapDefaults.startZoom)
        let latitude = try values.decodeIfPresent(Double.self, forKey: .latitude)
        let longitude = try values.decodeIfPresent(Double.self, forKey: .longitude)
        if let latitude = latitude, let longitude = longitude{
            centerCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        else {
            centerCoordinate = MapDefaults.startLocation.coordinate
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(scale, forKey: .scale)
        try container.encode(centerCoordinate.latitude, forKey: .latitude)
        try container.encode(centerCoordinate.longitude, forKey: .longitude)
    }
    
    func getCenterCoordinate() -> CLLocationCoordinate2D{
        centerCoordinate
    }
    
    func setZoom(_ zoom: Int){
        //Logger.debug("setZoom \(zoom)")
        scale = World.downScale(to: zoom)
        //Logger.debug("scale is \(scale)")
        coordinateRegion = nil
    }
    
    func zoomIn(){
        if zoom < World.maxZoom{
            setZoom(zoom + 1)
            save()
        }
    }
    
    func zoomOut(){
        if zoom > World.minZoom{
            setZoom(zoom - 1)
            save()
        }
    }
    
    func getCoordinateRegion() -> CoordinateRegion{
        if coordinateRegion == nil{
            let scaledWorldCenterPoint = scaledWorldCenterPoint
            let topLeft = CGPoint(x: scaledWorldCenterPoint.x - visibleMapRect.width/2,
                                  y: scaledWorldCenterPoint.y - visibleMapRect.height/2)
            let bottomRight = CGPoint(x: topLeft.x + visibleMapRect.width,
                                      y: topLeft.y + visibleMapRect.height)
            let topLeftCoordinate = World.coordinate(scaledX: topLeft.x, scaledY: topLeft.y, downScale: scale)
            let bottomRightCoordinate = World.coordinate(scaledX: bottomRight.x, scaledY: bottomRight.y, downScale: scale)
            coordinateRegion = CoordinateRegion(topLeft: topLeftCoordinate, bottomRight: bottomRightCoordinate)
        }
        return coordinateRegion!
    }
    
    func isInCoordinateRect(coordinate: CLLocationCoordinate2D) -> Bool{
        return getCoordinateRegion().contains(coordinate: coordinate)
    }
    
    func save(){
        StatusManager.shared.saveCodable(key: MapStatus.storeKey, value: self)
    }

}


