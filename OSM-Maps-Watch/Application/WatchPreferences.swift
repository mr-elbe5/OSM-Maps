/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

@Observable class WatchPreferences: Identifiable, Codable{
    
    static var storeKey = "preferences"
    
    static var shared = WatchPreferences()
    
    static func load(){
        if let prefs : WatchPreferences = StatusManager.shared.getCodable(key: WatchPreferences.storeKey){
            WatchPreferences.shared = prefs
        }
        else{
            Log.error("no saved data available for preferences")
            WatchPreferences.shared = WatchPreferences()
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case mapSource
        case followLocation
        case showCurrentLocation
        case showDirection
        case countTrackpoints
        case distanceFilter
        case trackpointInterval
        case showHeartRate
    }
    
    var mapSource : MapSource = .osm
    var followLocation : Bool = false
    var showCurrentLocation : Bool = true
    var showDirection : Bool = true
    var countTrackpoints : Bool = true
    var distanceFilter: LocationDistance = MapDefaults.defaultDistanceFilter{
        didSet{
            LocationService.shared.updateDistanceFilter()
        }
    }
    var trackpointInterval: TrackpointInterval = MapDefaults.defaultTrackpointMinInterval
    var showHeartRate : Bool = true
    
    init(){
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let mapSourceString = try values.decodeIfPresent(String.self, forKey: .mapSource){
            mapSource = MapSource(rawValue: mapSourceString) ?? .osm
        }
        followLocation = try values.decodeIfPresent(Bool.self, forKey: .followLocation) ?? true
        showCurrentLocation = try values.decodeIfPresent(Bool.self, forKey: .showCurrentLocation) ?? true
        if let dist = try values.decodeIfPresent(String.self, forKey: .distanceFilter){
            distanceFilter = LocationDistance(rawValue: dist) ?? .tight
        }
        showDirection = try values.decodeIfPresent(Bool.self, forKey: .showDirection) ?? true
        countTrackpoints = try values.decodeIfPresent(Bool.self, forKey: .countTrackpoints) ?? true
        if let interval = try values.decodeIfPresent(String.self, forKey: .trackpointInterval){
            trackpointInterval = TrackpointInterval(rawValue: interval) ?? .short
        }
        showHeartRate = try values.decodeIfPresent(Bool.self, forKey: .showHeartRate) ?? true
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mapSource.rawValue, forKey: .mapSource)
        try container.encode(followLocation, forKey: .followLocation)
        try container.encode(showCurrentLocation, forKey: .showCurrentLocation)
        try container.encode(showDirection, forKey: .showDirection)
        try container.encode(distanceFilter.rawValue, forKey: .distanceFilter)
        try container.encode(showHeartRate, forKey: .showHeartRate)
    }
    
    func save(){
        StatusManager.shared.saveCodable(key: WatchPreferences.storeKey, value: self)
        Log.debug("Preferences saved")
    }
    
}

typealias Preferences = WatchPreferences

