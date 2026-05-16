/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import OSLog

class Nominatim {
    
    static func getLocation(query: String, completion: @escaping (_ result: Array<NominatimLocation>) -> Void)  {
        //Logger.debug(query)
        if let queryURL = URL(string: query){
            let session = URLSession.shared
            session.dataTask(with: queryURL, completionHandler: { data, response, err -> Void in
                var result = Array<NominatimLocation>()
                if (err != nil) {
                    completion(result)
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    do {
                        guard let data = data else { return }
                        let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                        if let resultArray = jsonResult as? Array<Any>, !resultArray.isEmpty {
                            for singleResult in resultArray{
                                if let dict = singleResult as? Dictionary<String, Any>, let displayName = dict["display_name"] as? String, let boundingBox = dict["boundingbox"] as? Array<String>{
                                    if let lat = Double(dict["lat"] as! String), let lon = Double(dict["lon"] as! String){
                                        let loc = NominatimLocation(lat: lat, lon: lon, name: displayName, importance: dict["importance"] as? Double ?? 0.0, boundingBox: boundingBox)
                                        result.append(loc)
                                    }
                                }
                            }
                            completion(result)
                        }
                    } catch let err {
                        Logger.error("Nominatim error: \(err)")
                        completion(result)
                    }
                } else {
                    completion(result)
                }
            }).resume()
        }
        
    }
}

class NominatimLocation: Identifiable, Hashable {
    
    static func == (lhs: NominatimLocation, rhs: NominatimLocation) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: UUID
    var latitude: Double
    var longitude: Double
    var name: String
    var importance: Double = 0.0
    var boundingBox: Array<String>? = nil
    
    init(lat: Double, lon: Double, name: String, importance: Double, boundingBox: Array<String>) {
        id = UUID()
        self.latitude = lat
        self.longitude = lon
        self.name = name
        self.importance = importance
        self.boundingBox = boundingBox
    }
    
    var coordidate: CLLocationCoordinate2D{
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var mapRect : CGRect?{
        if let boundingBox = boundingBox, let minLat = Double(boundingBox[0]), let maxLat = Double(boundingBox[1]), let minLon = Double(boundingBox[2]), let maxLon = Double(boundingBox[3]){
            //debug("Nominatim: mapRect")
            let topLeft = CGPoint(CLLocationCoordinate2D(latitude: maxLat, longitude: minLon))
            //debug("topLeft = \(topLeft.string)")
            let bottomRight = CGPoint(CLLocationCoordinate2D(latitude: minLat, longitude: maxLon))
            //debug("bottomRight = \(bottomRight.string)")
            return CGRect(origin: topLeft, size: CGSize(width: bottomRight.x - topLeft.x, height: bottomRight.y - topLeft.y))
        }
        return nil
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
