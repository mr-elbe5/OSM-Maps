/*
 OSM Maps (Mac)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

class Preferences: Identifiable, Codable{
    
    static var storeKey = "preferences"
    
    static var shared = Preferences()
    
    static func load(){
        if let prefs : Preferences = StatusManager.shared.getCodable(key: Preferences.storeKey){
            Preferences.shared = prefs
        }
        else{
            Log.error("no saved data available for preferences")
            Preferences.shared = Preferences()
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case mapSource
        case showCenterButton
        case showMapPins
        case maxSearchResults
        case sortAscending
        case gridSizeFactorIndex
        case routeType
    }
    
    var mapSource : MapSource = .elbe5
    var showCenterButton: Bool = false
    var showMapPins: Bool = true
    var showTrackpoints : Bool = false
    var gridSizeFactorIndex: Int = 2
    var routeType : RouteType = .car
    
    var maxSearchResults = MapDefaults.defaultMaxSearchResults
    
    var sortAscending: Bool = true
    
    init(){
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let mapSourceString = try? values.decodeIfPresent(String.self, forKey: .mapSource){
            mapSource = MapSource(rawValue: mapSourceString) ?? .osm
        }
        showCenterButton = try values.decodeIfPresent(Bool.self, forKey: .showCenterButton) ?? false
        showMapPins = try values.decodeIfPresent(Bool.self, forKey: .showMapPins) ?? true
        sortAscending = try values.decodeIfPresent(Bool.self, forKey: .sortAscending) ?? true
        gridSizeFactorIndex = try values.decodeIfPresent(Int.self, forKey: .gridSizeFactorIndex) ?? 2
        if let type = try values.decodeIfPresent(String.self, forKey: .routeType){
            routeType = RouteType(rawValue: type) ?? .car
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mapSource.rawValue, forKey: .mapSource)
        try container.encode(showCenterButton, forKey: .showCenterButton)
        try container.encode(showMapPins, forKey: .showMapPins)
        try container.encode(maxSearchResults, forKey: .maxSearchResults)
        try container.encode(sortAscending, forKey: .sortAscending)
        try container.encode(gridSizeFactorIndex, forKey: .gridSizeFactorIndex)
        try container.encode(routeType.rawValue, forKey: .routeType)
    }
    
    func save(){
        StatusManager.shared.saveCodable(key: Preferences.storeKey, value: self)
        Log.debug("Preferences saved")
    }
    
}


