/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class RouteRequest {
    
    static func getRouteData(from fromCoordinate: CLLocationCoordinate2D, to toCoordinate: CLLocationCoordinate2D, type: RouteType, completion: @escaping (_ result: OSRMRouteData?) -> Void) -> Void {
        if let url = URL(string: "https://routing.openstreetmap.de/routed-\(type.rawValue)/route/v1/driving/\(fromCoordinate.latitude),\(fromCoordinate.longitude);\(toCoordinate.latitude),\(toCoordinate.longitude)?overview=false&alternatives=false&generate_hints=false&steps=true"){
            let session = URLSession.shared
            session.dataTask(with: url, completionHandler: { data, response, err -> Void in
                if let err = err {
                    Log.error("OSRM error: \(err)")
                    completion(nil)
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data {
                    do{
                        let response: OSRMRouteData = try JSONDecoder().decode(OSRMRouteData.self, from: data)
                        completion(response)
                    }
                    catch (let err){
                        Log.error("OSRM decode error: \(err)")
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            }).resume()
        }
    }
    
    
}
