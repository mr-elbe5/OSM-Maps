/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

extension KeyedDecodingContainer{
    
    func decodeIfPresent<T>(_ type:T.Type, forKeys keys: Array<K>) throws -> T?  where T : Decodable{
        for key in keys{
            if let obj = try self.decodeIfPresent(type, forKey: key){
                return obj
            }
        }
        return nil
    }
    
}
