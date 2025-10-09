/*
 OSM Maps (Mac)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class AppStatus: Identifiable, Codable{
    
    static var storeKey = "appStatus"
    
    static var shared = AppStatus()
    
    static var latestVersion: Int = 16
    
    static func load(){
        if let status : AppStatus = StatusManager.shared.getCodable(key: AppStatus.storeKey){
            AppStatus.shared = status
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case currentVersion
    }
    
    var currentVersion: Int = 0
    
    init(){
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        currentVersion = try values.decodeIfPresent(Int.self, forKey: .currentVersion) ?? 0
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(currentVersion, forKey: .currentVersion)
    }
    
    func updateVersion(){
        if currentVersion == AppStatus.latestVersion{
            Log.info("Version is up to date")
            return
        }
        Log.info("current version is \(currentVersion)")
        if currentVersion < 15{
            BasePaths.assertNewFileLocations()
        }
        currentVersion = Self.latestVersion
        save()
        Log.info("updated to version \(currentVersion)")
    }
    
    func save(){
        StatusManager.shared.saveCodable(key: AppStatus.storeKey, value: self)
    }
    
}

