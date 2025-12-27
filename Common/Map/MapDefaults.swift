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
    
    static var mapPlaceIcon = OSImage(named: "mappin.green")!
    static var mapMediaIcon = OSImage(named: "mappin.red")!
    static var mapTrackIcon = OSImage(named: "mappin.blue")!
    
    static var mapPlaceGroupIcon = OSImage(named: "mappin.group.green")!
    static var mapMediaGroupIcon = OSImage(named: "mappin.group.red")!
    static var mapTrackGroupIcon = OSImage(named: "mappin.group.blue")!
    static var mapMixedGroupIcon = OSImage(named: "mappin.group.purple")!
    
    static var routeStartIcon = OSImage(named: "marker-green")!
    static var routeEndIcon = OSImage(named: "marker-red")!
    static var routeMiddleIcon = OSImage(named: "marker-yellow")!
    static var routeMarkerIcon = OSImage(systemName: "info.circle")!.withTintColor(.darkGray).withRenderingMode(.alwaysOriginal)
    
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
