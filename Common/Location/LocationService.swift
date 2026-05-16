/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import OSLog

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
        clManager.distanceFilter = Settings.shared.distanceFilter.distance
        clManager.headingFilter = 5.0
        clManager.delegate = self
        clManager.allowsBackgroundLocationUpdates = true
    }
    
    deinit{
        stop()
    }
    
    func start(){
        Logger.debug("starting location manager")
        clManager.requestWhenInUseAuthorization()
        clManager.startUpdatingLocation()
        if Settings.shared.showDirection{
            clManager.startUpdatingHeading()
        }
        running = true
    }
    
    func stop(){
        Logger.debug("stopping location manager")
        clManager.stopUpdatingLocation()
        if Settings.shared.showDirection{
            clManager.stopUpdatingHeading()
        }
        running = false
    }
    
    func updateDistanceFilter(){
        clManager.distanceFilter = Settings.shared.distanceFilter.distance
    }
    
    func updateShowDirection(){
        if Settings.shared.showDirection{
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
            Logger.error("Location access denied")
        case .restricted:
            Logger.error("Location access restricted")
        case .notDetermined:
            Logger.error("Location access not Determined")
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse :
            Logger.debug("Location access authorized when in use")
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
            //Logger.debug("acc = \(loc.horizontalAccuracy)")
        }
    }
  
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if Settings.shared.showDirection{
            let direction = newHeading.trueHeading
            LocationStatus.shared.direction = direction
            delegate?.directionChanged(to: direction)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        Logger.error("Error: \(error)")    
    }
    
}
