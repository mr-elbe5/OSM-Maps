//
//  UTCDiff.swift
//  OSM Maps
//
//  Created by Michael Rönnau on 01.03.26.
//

import Foundation

import CoreLocation

class UTCOffset{
    
    static var current = UTCOffset()
    
    private var offset: Int
    private var daylightZoneOffset: Int
    
    var value: Int{
        return offset
    }
    
    var daylightValue: Int{
        return offset + daylightZoneOffset
    }
    
    init(){
        offset = Int(TimeZone.current.secondsFromGMT()/3600)
        daylightZoneOffset = Int(TimeZone.current.daylightSavingTimeOffset()/3600)
    }
    
    init(timeZone: TimeZone){
        offset = Int(timeZone.secondsFromGMT()/3600)
        daylightZoneOffset = Int(timeZone.daylightSavingTimeOffset()/3600)
    }
    
    init(timeZone: TimeZone, for date: Date){
        offset = Int(timeZone.secondsFromGMT(for: date)/3600)
        daylightZoneOffset = Int(timeZone.daylightSavingTimeOffset()/3600)
    }
    
    static func getUTCDiff(coordinate: CLLocationCoordinate2D, completion: @escaping (UTCOffset) -> Void){
        getTimeZoneAsync(coordinate: coordinate){ timeZone in
            completion(UTCOffset(timeZone: timeZone))
        }
    }
    
    static func getUTCDiff(coordinate: CLLocationCoordinate2D, for date: Date, completion: @escaping (UTCOffset) -> Void){
        getTimeZoneAsync(coordinate: coordinate){ timeZone in
            completion(UTCOffset(timeZone: timeZone,for: date))
        }
    }
    
    private static func getTimeZoneAsync(coordinate: CLLocationCoordinate2D, result: @escaping (TimeZone) -> Void){
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)){ (placemarks, error) in
            if error != nil{
                Log.debug("placemark error getting timezone - using current")
                result(.current)
                return
            }
            if let placemark =  placemarks?[0], let timeZone = placemark.timeZone{
                result(timeZone)
            }
            else{
                Log.debug("no placemark found for timezone - using current")
                result(.current)
            }
        }
    }
    
}
