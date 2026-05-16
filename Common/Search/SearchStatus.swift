/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import OSLog

class SearchStatus: Identifiable, Codable{
    
    static var storeKey = "searchStatus"
    
    static var shared = SearchStatus()
    
    static func load(){
        if let status : SearchStatus = StatusManager.shared.getCodable(key: SearchStatus.storeKey){
            SearchStatus.shared = status
        }
        else{
            Logger.error("no saved data available for search status")
            SearchStatus.shared = SearchStatus()
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case searchString
        case searchTarget
        case searchRegion
        case searchRadius
    }
    
    var searchString : String = ""
    var searchTarget : SearchQuery.SearchTarget = .any
    var searchRegion : SearchQuery.SearchRegion = .unlimited
    var searchRadius : Double = MapDefaults.defaultSearchRadius
    
    init(){
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        searchString = try values.decodeIfPresent(String.self, forKey: .searchString) ?? ""
        var s = try values.decodeIfPresent(Int.self, forKey: .searchTarget) ?? 0
        searchTarget = SearchQuery.SearchTarget(rawValue: s) ?? .any
        s = try values.decodeIfPresent(Int.self, forKey: .searchRegion) ?? 0
        searchRegion = SearchQuery.SearchRegion(rawValue: s) ?? .unlimited
        searchRadius = try values.decodeIfPresent(Double.self, forKey: .searchRadius) ?? MapDefaults.defaultSearchRadius
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(searchString, forKey: .searchString)
        try container.encode(searchTarget.rawValue, forKey: .searchTarget)
        try container.encode(searchRegion.rawValue, forKey: .searchRegion)
        try container.encode(searchRadius, forKey: .searchRadius)
    }
    
    func save(){
        StatusManager.shared.saveCodable(key: SearchStatus.storeKey, value: self)
    }
    
}

