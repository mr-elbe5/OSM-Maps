/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

extension CLPlacemark{
    
    static func getPlacemark(for coordinate: CLLocationCoordinate2D, result: @escaping(CLPlacemark?) -> Void){
        getPlacemark(for: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), result: result)
    }
    
    static func getPlacemark(for location: CLLocation, result: @escaping(CLPlacemark?) -> Void){
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            if let error = error{
                Log.error(error: error)
                result(nil)
                return
            }
            if let placemark =  placemarks?[0]{
                //Log.debug("got placemark")
                result(placemark)
            }
            else{
                //Log.debug("no placemark")
                result(nil)
            }
        })
    }
    
    static func getPlacemarkName(for coordinate: CLLocationCoordinate2D, result: @escaping(String) -> Void){
        getPlacemarkName(for: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), result: result)
    }
    
    static func getPlacemarkName(for location: CLLocation, result: @escaping(String) -> Void){
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            if let error = error{
                Log.error(error: error)
                result("")
                return
            }
            if let placemark =  placemarks?[0]{
                //Log.debug("got placemark")
                result(placemark.asString)
            }
            else{
                //Log.debug("no placemark")
                result("")
            }
        })
    }
    
    var nameString: String?{
        if let name = name{
            if name.isEmpty || name == postalCode{
                return nil
            }
            else{
                return name
            }
        }
        return nil
    }
    
    var street: String?{
        let address = "\(thoroughfare ?? "") \(subThoroughfare ?? "")".trim()
        return address.isEmpty ? nil : address
    }
    
    var city: String?{
        let address = "\(postalCode ?? "") \(locality ?? "")"
        return address.isEmpty ? nil : address
    }
    
    var asString: String{
        if let name = name, !name.isEmpty{
            return name
        }
        if let street = street{
            if let city = city{
                return "\(street)\n\(city)"
            }
            return street
        }
        if let city = city{
            return city
        }
        return ""
    }
    
}
