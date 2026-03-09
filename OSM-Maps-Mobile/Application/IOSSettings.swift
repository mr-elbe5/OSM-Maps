/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

class IOSSettings: Identifiable, Codable{
    
    static var storeKey = "preferences"
    
    static var shared = IOSSettings()
    
    static func load(){
        if let prefs : IOSSettings = StatusManager.shared.getCodable(key: IOSSettings.storeKey){
            IOSSettings.shared = prefs
        }
        else{
            Log.error("no saved data available for settings")
            IOSSettings.shared = IOSSettings()
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case mapSource
        case showCenterButton
        case followLocation
        case showDirection
        case showMapPins
        case routeType
        case distanceFilter
        case trackpointInterval
        case minHorizontalTrackpointDistance
        case maxSearchResults
    }
    
    var mapSource : MapSource = .osm
    var showCenterButton: Bool = false
    var followLocation : Bool = false
    var showDirection : Bool = true
    var showMapPins : Bool = false
    var routeType : RouteType = .car
    
    var distanceFilter: LocationDistance = MapDefaults.defaultDistanceFilter{
        didSet{
            LocationService.shared.updateDistanceFilter()
        }
    }
    var trackpointInterval: TrackpointInterval = MapDefaults.defaultTrackpointMinInterval
    var maxSearchResults = MapDefaults.defaultMaxSearchResults
    
    init(){
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let mapSourceValue = try values.decodeIfPresent(String.self, forKey: .mapSource){
            mapSource = MapSource(rawValue: mapSourceValue) ?? .osm
        }
        showCenterButton = try values.decodeIfPresent(Bool.self, forKey: .showCenterButton) ?? false
        followLocation = try values.decodeIfPresent(Bool.self, forKey: .followLocation) ?? false
        if let dist = try values.decodeIfPresent(String.self, forKey: .distanceFilter){
            distanceFilter = LocationDistance(rawValue: dist) ?? .tight
        }
        showDirection = try values.decodeIfPresent(Bool.self, forKey: .showDirection) ?? true
        showMapPins = try values.decodeIfPresent(Bool.self, forKey: .showMapPins) ?? true
        if let type = try values.decodeIfPresent(String.self, forKey: .routeType){
            routeType = RouteType(rawValue: type) ?? .car
        }
        if let interval = try values.decodeIfPresent(String.self, forKey: .trackpointInterval){
            trackpointInterval = TrackpointInterval(rawValue: interval) ?? .short
        }
        maxSearchResults = try values.decodeIfPresent(Int.self, forKey: .maxSearchResults) ?? MapDefaults.defaultMaxSearchResults
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mapSource.rawValue, forKey: .mapSource)
        try container.encode(showCenterButton, forKey: .showCenterButton)
        try container.encode(followLocation, forKey: .followLocation)
        try container.encode(showDirection, forKey: .showDirection)
        try container.encode(showMapPins, forKey: .showMapPins)
        try container.encode(routeType.rawValue, forKey: .routeType)
        try container.encode(distanceFilter.rawValue, forKey: .distanceFilter)
        try container.encode(maxSearchResults, forKey: .maxSearchResults)
    }
    
    func save(){
        StatusManager.shared.saveCodable(key: IOSSettings.storeKey, value: self)
        Log.debug("Settings saved")
    }
    
}

typealias Settings = IOSSettings

