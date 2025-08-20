/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class MapDefaults{
    
    static var osmLink = "https://www.openstreetmap.org/copyright"
    
    static var elbe5ElevationUrl = "https://gdalserver.elbe5.de/elevation?latitude={lat}&longitude={lon}"
    
    static var mapPlaceIcon = OSImage(named: "marker_place")!
    static var mapImageIcon = OSImage(named: "marker_photo")!
    static var mapTrackIcon = OSImage(named: "marker_track")!
    
    static var mapPlaceGroupIcon = OSImage(named: "marker_places")!
    static var mapImageGroupIcon = OSImage(named: "marker_photos")!
    static var mapTrackGroupIcon = OSImage(named: "marker_tracks")!
    static var mapMixedGroupIcon = OSImage(named: "marker_mixed")!
    
    static var mapItemImageOffset: CGFloat = 16
    
    static var defaultTrackpointMinInterval: TrackpointInterval = .short
    static var defaultMaxHorizontalUncertainty: Double = 10.0
    
    static var defaultDistanceFilter: LocationDistance = .gps
    static var maxTrackpointInLineDeviation: Double = 3.0
    
    static var defaultMaxSearchResults: Int = 5
    
    static var previewSize: CGFloat = 100
    
    static var startLocation = CLLocation(latitude: 47.42, longitude: 10.98)
    static var startZoom: Int = 14
    
    static let defaultSearchRadius : Double = 100
    
}
