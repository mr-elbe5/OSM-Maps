/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

extension Decodable{
    
    static func deserialize<T: Decodable>(encoded : String) -> T?{
        if let data = Data(base64Encoded: encoded){
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do{
                let result:T = try decoder.decode(T.self, from : data)
                return result
            }
            catch (let err){
                Log.error(error: err)
            }
        }
        return nil
    }
    
    static func fromJSON<T: Decodable>(encoded : String) -> T?{
        if let data =  encoded.data(using: .utf8){
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do{
                let result:T = try decoder.decode(T.self, from : data)
                return result
            }
            catch (let err){
                Log.error(error: err)
            }
        }
        return nil
    }
    
}

extension Encodable{
    
    func serialize() -> String{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        if let json = try? encoder.encode(self).base64EncodedString(){
            return json
        }
        return ""
    }
    
    func toJSON() -> String{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(self){
            if let s = String(data:data, encoding: .utf8){
                return s
            }
        }
        return ""
    }
    
}
