/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

extension Dictionary{
    
    mutating func addAll<K, V>(from src: [K:V]){
        for (k, v) in src {
            if let key = k as? Key, let val = v as? Value {
                self[key] = val
            }
        }
    }
    
    func getTypedObject<K,T>(key: K, type: T.Type) -> T?{
        if let k = key as? Key{
            if let val = self[k] as? T{
                return val
            }
        }
        return nil
    }
    
    func getTypedValues<T>(type: T.Type) -> Array<T>{
        var arr = Array<T>()
        for value in values{
            if let val = value as? T{
                arr.append(val)
            }
        }
        return arr
    }
    
    mutating func remove<T : Equatable>(key : T){
        for k in keys{
            if key == k as? T{
                self[k] = nil
                return
            }
        }
    }
    
    mutating func remove<T : Equatable>(value : T){
        for k in keys{
            if value == self[k] as? T{
                self[k] = nil
                return
            }
        }
    }
    
}
