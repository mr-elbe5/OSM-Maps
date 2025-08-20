/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

enum TrackpointInterval: String, CaseIterable, Identifiable{
    case extrashort = "5"
    case short = "10"
    case medium = "20"
    case long = "60"
    case extralong = "300"
    
    var id: Self { self }
    
    var interval: Double {
        Double(rawValue) ?? .zero
    }
}

typealias TrackpointIntervalList = Array<TrackpointInterval>

extension TrackpointIntervalList{
    
    static var shared: TrackpointIntervalList = TrackpointInterval.allCases
    
    var values: Array<Double>{
        var list = Array<Double>()
        for i in 0..<count{
            list.append(self[i].interval)
        }
        return list
    }
    
    func indexOf(interval: TrackpointInterval) -> Int{
        for i in 0..<count{
            if self[i] == interval{
                return i
            }
        }
        return 0
    }
    
}

