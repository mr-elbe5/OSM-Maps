/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

enum MapSource: String, CaseIterable, Identifiable{
    case osm
    case elbe5
    case elbe5Topo
    
    var templateUrl: String{
        switch self {
        case .osm:
            return "https://tile.openstreetmap.org/{z}/{x}/{y}.png"
        case .elbe5:
            return "https://tiles.elbe5.de/carto/{z}/{x}/{y}.png"
        case .elbe5Topo:
            return "https://tiles.elbe5.de/topo/{z}/{x}/{y}.png"
        }
    }
    
    var id: Self { self }
}

typealias MapSourceList = Array<MapSource>

extension MapSourceList{
    
    static var shared: MapSourceList = MapSource.allCases
    
    var names: Array<String>{
        var list = Array<String>()
        for i in 0..<count{
            list.append(self[i].rawValue.localize())
        }
        return list
    }
    
    func indexOf(source: MapSource) -> Int{
        for i in 0..<count{
            if self[i] == source{
                return i
            }
        }
        return 0
    }
    
}

