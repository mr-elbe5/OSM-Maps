//
//  TrackItem.swift
//  OSM Maps
//
//  Created by Michael Rönnau on 28.12.25.
//


/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import CloudKit
import SwiftUI

class RouteItem: MapItem{
    
    static var itemType: String = "route"
    
    static var previewSize: CGFloat = 512
    static var imageSize: CGFloat = 2048
    
    static func == (lhs: RouteItem, rhs: RouteItem) -> Bool {
        lhs.id == rhs.id
    }
    
    private enum CodingKeys: String, CodingKey {
        case route
        case endLocation
    }
    
    var route : Route
    var endLocation : LocationData?
    
    override var itemType: String{
        RouteItem.itemType
    }
    
    override var coordinate: CLLocationCoordinate2D{
        get{
            route.startCoordinate ?? .zero
        }
        set {
            super.coordinate = newValue
        }
    }
    
    var coordinateRegion: CoordinateRegion?{
        var reg = route.coordinateRegion
        if reg == nil || reg == .zero{
            route.updateCoordinateRegion()
            reg = route.coordinateRegion
        }
        return reg
    }
    
    var fileName: String{
        "route_\(id).jpg"
    }
    
    var previewURL: URL{
        BasePaths.previewDirURL.appendingPathComponent(fileName)
    }
    
    override init(){
        route = Route()
        super.init()
    }
    
    init(route: Route){
        self.route = route
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        route = try values.decodeIfPresent(Route.self, forKey: .route) ?? Route()
        endLocation = try values.decodeIfPresent(LocationData.self, forKey: .endLocation)
        try super.init(from: decoder)
        coordinate = route.startCoordinate ?? .zero
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try super .encode(to: encoder)
        try container.encode(route, forKey: .route)
        try container.encodeIfPresent(endLocation, forKey: .endLocation)
    }
    
    func getPreviewFile() -> Data?{
        FileManager.default.readFile(url: previewURL)
    }
    
    func routeChanged(){
        if FileManager.default.fileExists(url: previewURL){
            FileManager.default.deleteFile(url: previewURL)
        }
    }
    
    @discardableResult
    func deleteFiles() -> Bool{
        if FileManager.default.fileExists(dirPath: BasePaths.previewDirURL.path, fileName: fileName){
            if !FileManager.default.deleteFile(url: BasePaths.previewDirURL.appendingPathComponent(fileName)){
                Log.error("Track could not delete preview: \(fileName)")
                return false
            }
        }
        return true
    }
    
    func getPreview() -> OSImage?{
        if let data = getPreviewFile(){
            return OSImage(data: data)
        } else{
            return RouteImageCreator.createPreview(item: self)
        }
    }
    
    override func prepareToDelete(){
        deleteFiles()
    }
    
}

typealias RouteItemList = LocationList<RouteItem>

extension RouteItemList{
    
    mutating func sortByDate(ascending: Bool){
        if ascending{
            self.sort(by: { $0.creationDate < $1.creationDate})
        }
        else{
            self.sort(by: { $0.creationDate > $1.creationDate})
        }
    }
    
}
