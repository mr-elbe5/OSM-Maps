/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

class TileCache {
    
    private var tileDict = [String: Data]()
    private let dispatchQueue = DispatchQueue(label: "de.elbe5.tileCache", attributes: .concurrent)

    func getData(key: String) -> Data? {
        var data: Data?
        dispatchQueue.sync {
            if tileDict.keys.contains(key) {
                data = tileDict[key]
            }
        }
        return data
    }

    func setData(key: String, data: Data) {
        dispatchQueue.async(flags: .barrier) {
            self.tileDict[key] = data
        }
    }
    
    func clear() {
        dispatchQueue.async(flags: .barrier) {
            self.tileDict.removeAll()
        }
    }
    
}
