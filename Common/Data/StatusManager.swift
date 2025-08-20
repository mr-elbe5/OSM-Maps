/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

class StatusManager {
        
    static let shared = StatusManager()
    
    private func url(key: String) -> URL {
        return BasePaths.statusDirURL.appendingPathComponent(key + ".txt")
    }
    
    func getString(key: String) -> String? {
        return FileManager.default.readTextFile(url: url(key: key))
    }
    
    func getCodable<T : Codable>(key: String) -> T? {
        return FileManager.default.readJsonFile(storeKey: key, from: BasePaths.statusDirURL)
    }
    
    @discardableResult
    func saveString(key: String, value: String) -> Bool{
        return FileManager.default.saveFile(text: value, url: url(key: key))
    }
    
    @discardableResult
    func saveCodable(key: String, value: Codable) -> Bool{
        return FileManager.default.saveJsonFile(data: value, storeKey: key, to: BasePaths.statusDirURL)
    }
    
}
