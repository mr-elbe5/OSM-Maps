/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

@Observable class WatchSettings: CommonSettings{
    
    enum CodingKeys: String, CodingKey {
        case followLocation
        case followInBackground
        case showCurrentLocation
        case showDirection
        case countTrackpoints
        case distanceFilter
        case trackpointInterval
        case showHeartRate
    }
    
    var followLocation : Bool = true
    var followInBackground : Bool = true
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
    
    override init(){
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        followLocation = try values.decodeIfPresent(Bool.self, forKey: .followLocation) ?? true
        followInBackground = try values.decodeIfPresent(Bool.self, forKey: .followInBackground) ?? true
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
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try super .encode(to: encoder)
        try container.encode(followLocation, forKey: .followLocation)
        try container.encode(followInBackground, forKey: .followInBackground)
        try container.encode(showCurrentLocation, forKey: .showCurrentLocation)
        try container.encode(showDirection, forKey: .showDirection)
        try container.encode(distanceFilter.rawValue, forKey: .distanceFilter)
        try container.encode(showHeartRate, forKey: .showHeartRate)
    }
    
}

typealias Settings = WatchSettings

