/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

enum LocationDistance: String, CaseIterable, Identifiable{
    case gps = "gpsAccuracy"
    case tight = "10"
    case medium = "20"
    case wide = "50"
    case extraWide = "100"
    
    var id: Self { self }
    
    var distance: Double {
        if self == .gps{
            return LocationStatus.shared.location.horizontalAccuracy
        }
        return Double(rawValue) ?? .infinity
    }
}

typealias LocationDistanceList = Array<LocationDistance>

extension LocationDistanceList{
    
    static var shared: LocationDistanceList = LocationDistance.allCases
    
    var values: Array<Double>{
        var list = Array<Double>()
        for i in 0..<count{
            list.append(self[i].distance)
        }
        return list
    }
    
    func indexOf(distance: LocationDistance) -> Int{
        for i in 0..<count{
            if self[i] == distance{
                return i
            }
        }
        return 0
    }
    
}


