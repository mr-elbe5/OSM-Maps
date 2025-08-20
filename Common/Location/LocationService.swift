/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

protocol LocationServiceDelegate {
    func locationChanged(to location: CLLocation)
    func directionChanged(to direction: CLLocationDirection)
}

class LocationService: NSObject{
    
    // north
    static var startDirection : CLLocationDirection = 0
    
    static var shared: LocationService = LocationService()
    
    var delegate: LocationServiceDelegate?
    
    var running = false
    
    var authorizedForTracking : Bool{
        clManager.authorizationStatus == .authorizedAlways
    }
    
    private let clManager = CLLocationManager()

    override init() {
        super.init()
        clManager.activityType = .other
        clManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        clManager.distanceFilter = Preferences.shared.distanceFilter.distance
        clManager.headingFilter = 5.0
        clManager.delegate = self
        clManager.allowsBackgroundLocationUpdates = true
    }
    
    deinit{
        stop()
    }
    
    func start(){
        Log.debug("starting location manager")
        clManager.requestWhenInUseAuthorization()
        clManager.startUpdatingLocation()
        if Preferences.shared.showDirection{
            clManager.startUpdatingHeading()
        }
        running = true
    }
    
    func stop(){
        Log.debug("stopping location manager")
        clManager.stopUpdatingLocation()
        if Preferences.shared.showDirection{
            clManager.stopUpdatingHeading()
        }
        running = false
    }
    
    func updateDistanceFilter(){
        clManager.distanceFilter = Preferences.shared.distanceFilter.distance
    }
    
    func updateShowDirection(){
        if Preferences.shared.showDirection{
            clManager.startUpdatingHeading()
        }else{
            clManager.stopUpdatingHeading()
        }
    }
    
    func requestAlwaysAuthorization(){
        clManager.requestAlwaysAuthorization()
    }
    
}

extension LocationService: CLLocationManagerDelegate{
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied :
            Log.error("Location access denied")
        case .restricted:
            Log.error("Location access restricted")
        case .notDetermined:
            Log.error("Location access not Determined")
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse :
            Log.debug("Location access authorized when in use")
            manager.allowsBackgroundLocationUpdates = true
            manager.startUpdatingLocation()
        default:
            break
        }
    }
     
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last, loc.horizontalAccuracy != -1{
            LocationStatus.shared.location = loc
            delegate?.locationChanged(to: loc)
            //Log.debug("acc = \(loc.horizontalAccuracy)")
        }
    }
  
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if Preferences.shared.showDirection{
            let direction = newHeading.trueHeading
            LocationStatus.shared.direction = direction
            delegate?.directionChanged(to: direction)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        Log.error("Error: \(error)")    
    }
    
}
