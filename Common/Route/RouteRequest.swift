/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class RouteRequest {
    
    static func getRoute(coordinates: [CLLocationCoordinate2D], type: RouteType, completion: @escaping (_ result: Route?) -> Void) -> Void {
        var string = "https://routing.openstreetmap.de/routed-\(type.rawValue)/route/v1/driving/"
        for i in 0..<coordinates.count {
            let coordinate = coordinates[i]
            if i > 0 {
                string += ";"
            }
            string += "\(coordinate.longitude),\(coordinate.latitude)"
        }
        string += "?geometries=geojson&alternatives=false&generate_hints=false&steps=true"
        if let url = URL(string: string){
            Log.info(string)
            let session = URLSession.shared
            session.dataTask(with: url, completionHandler: { data, response, err -> Void in
                if let err = err {
                    Log.error("OSRM error: \(err)")
                    completion(nil)
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data {
                    do{
                        //Log.info(String(data: data, encoding: .utf8)!)
                        let response: OSRMRouteData = try JSONDecoder().decode(OSRMRouteData.self, from: data)
                        let route = getRoute(from: response)
                        completion(route)
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
    
    private static func getRoute(from osrmRouteData: OSRMRouteData) -> Route? {
        //Log.info("found routes: \(osrmRouteData.routes.count)")
        let route = Route()
        if let osmroute = osrmRouteData.routes.first {
            route.distance = Int(osmroute.distance)
            route.duration = osmroute.duration
            for leg in osmroute.legs {
                for step in leg.steps {
                    for coordinate in step.geometry.coordinates2D {
                        route.routepoints.append(MapPoint(coordinate: coordinate))
                    }
                    if let maneuver = step.maneuver, let coordinate = maneuver.coordinates2D{
                        let waypoint = Waypoint(coordinate: coordinate)
                        waypoint.name = step.name
                        waypoint.distance = Int(step.distance)
                        waypoint.duration = Int(step.duration)
                        waypoint.type = maneuver.type
                        waypoint.direction = maneuver.modifier
                        route.waypoints.append(waypoint)
                    }
                }
            }
            return route
        }
        return nil
    }
    
}
