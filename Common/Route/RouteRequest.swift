/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class RouteRequest {
    
    static func requestRoute(route: Route, completion: @escaping (Bool) -> Void) -> Void {
        var coordinates = [CLLocationCoordinate2D]()
        var navPoints = MapPointList()
        for pnt in route.navigationPoints{
            if pnt != .zero{
                coordinates.append(pnt.coordinate)
                navPoints.append(pnt)
            }
        }
        var string = "https://routing.openstreetmap.de/routed-\(route.type.rawValue)/route/v1/driving/"
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
                    completion(false)
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data {
                    do{
                        //Log.info(String(data: data, encoding: .utf8)!)
                        let response: OSRMRouteData = try JSONDecoder().decode(OSRMRouteData.self, from: data)
                        let success = updateRoute(route: route, from: response)
                        completion(success)
                    }
                    catch (let err){
                        Log.error("OSRM decode error: \(err)")
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            }).resume()
        }
    }
    
    private static func updateRoute(route: Route, from osrmRouteData: OSRMRouteData) -> Bool {
        //Log.info("found routes: \(osrmRouteData.routes.count)")
        if let osmroute = osrmRouteData.routes.first {
            route.routepoints.removeAll()
            route.waypoints.removeAll()
            route.distance = Int(osmroute.distance)
            route.duration = osmroute.duration
            for leg in osmroute.legs {
                for step in leg.steps {
                    var distance = 0
                    var duration = 0
                    for coordinate in step.geometry.coordinates2D {
                        route.routepoints.append(MapPoint(coordinate: coordinate))
                    }
                    if let maneuver = step.maneuver, let coordinate = maneuver.coordinates2D{
                        distance += Int(step.distance)
                        duration += Int(step.duration)
                        let type = getType(maneuver.type, maneuver.modifier)
                        if type.isEmpty{
                            continue
                        }
                        let waypoint = Waypoint(coordinate: coordinate)
                        waypoint.name = step.name
                        waypoint.distance = distance
                        distance = 0
                        waypoint.duration = duration
                        duration = 0
                        waypoint.type = type
                        route.waypoints.append(waypoint)
                    }
                }
            }
            return true
        }
        return false
    }
    
    private static func getType(_ type: String, _ modifier: String) -> String {
        switch type {
        case "depart":
            return "depart"
        case "arrive":
            return "arrive"
        case "use lane":
            return "straight"
        case "roundabout", "rotary":
            return "roundabout"
        default:
            switch modifier {
            case "left", "slight left", "sharp left":
                return "left"
            case "right", "slight right", "sharp right":
                return "right"
            case "uturn":
                return "uturn"
            case "straight":
                return "straight"
            default:
                return ""
            }
        }
    }
    
}
