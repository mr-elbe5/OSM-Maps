/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import OSLog

protocol TrackRecorderDelegate{
    func trackStarted()
    func trackRecordingChanged()
    func addTrackpoint(_ trackpoint: Mappoint)
    func saveTrack(_ track: Track, result: @escaping(Bool) -> Void)
}

class TrackRecorder: NSObject{
    
    static var shared = TrackRecorder()
    
    var track: Track? = nil
    
    var isRecording: Bool = false
    
    var interrupted = false
    
    var timeZone: TimeZone = .current
    
    var delegate: TrackRecorderDelegate?
    
    private var lastCoordinate = CLLocationCoordinate2D()
    private var lastAltitude: Double = 0.0
    private var uphill = 0.0
    private var downhill = 0.0
    
    var isTracking: Bool{
        track != nil
    }
    
    var durationString: String{
        guard let track else { return "" }
        return track.durationString
    }
    
    var coveredDistance: Int{
        guard let track else { return 0 }
        return Int(track.distance)
    }
    
    var coveredAltitude: Int{
        guard let track else { return 0 }
        return Int(track.upDistance)
    }
    
    var trackpointCount: Int{
        guard let track else { return 0 }
        return track.trackpoints.count
    }
    
    override init(){
        super.init()
        print("start time zone is \(timeZone.identifier)")
    }
    
    func startTrack(){
        track = Track()
        isRecording = true
        delegate?.trackStarted()
    }
    
    func saveTrack(result: @escaping (Bool) -> Void){
        stopRecording()
        if let track = track{
            delegate?.saveTrack(track){success in
                if success{
                    self.track = nil
                }
                result(success)
            }
        }
    }
    
    func locationChanged(to location: CLLocation){
        if let trackpoint = addTrackpoint(from: location){
            delegate?.addTrackpoint(trackpoint)
        }
    }
    
    func addTrackpoint(from location: CLLocation) -> Mappoint?{
        if let track = track{
            let tp = Trackpoint(location: location)
            if track.trackpoints.isEmpty{
                track.addTrackpoint(tp)
                lastCoordinate = location.coordinate
                lastAltitude = location.altitude
                uphill = 0
                downhill = 0
                Logger.debug("starting track at \(tp.coordinate.debugString)")
                track.upDistance = 0
                return tp
            }
            let previousTrackpoint = track.trackpoints.last!
            // check time interval
            if let prevTimestamp = previousTrackpoint.timestamp, let timestamp = tp.timestamp{
                let timeDiff = prevTimestamp.distance(to: timestamp)
                //Logger.debug("timeDiff = \(timeDiff)")
                if timeDiff < Settings.shared.trackpointInterval.interval{
                    //Logger.debug("skipping by time")
                    return nil
                }
            }
            // check distance
            let horizontalDiff = lastCoordinate.distance(to: tp.coordinate)
            //Logger.debug("horizontalDiff = \(horizontalDiff)")
            //Logger.debug("horizontalAccuracy = \(location.horizontalAccuracy)")
            if Settings.shared.distanceFilter == .gps{
                if location.horizontalAccuracy >= 0, horizontalDiff < location.horizontalAccuracy{
                    //Logger.debug("skipping location (missing accuracy)")
                    return nil
                }
            }
            else{
                if location.horizontalAccuracy >= 0, horizontalDiff < Settings.shared.distanceFilter.distance{
                    //Logger.debug("skipping location (missing accuracy)")
                    return nil
                }
            }
            lastCoordinate = location.coordinate
            //Logger.debug("adding trackpoint at \(tp.coordinate.debugString)")
            track.addTrackpoint(tp)
            track.distance += horizontalDiff
            //checking uphill
            if let tpAlt = tp.altitude{
                let verticalDiff = tpAlt - lastAltitude
                //Logger.debug("verticalDiff = \(verticalDiff)")
                //Logger.debug("verticalAccuracy = \(location.verticalAccuracy)")
                if location.verticalAccuracy >= 0, verticalDiff >= location.verticalAccuracy{
                    if verticalDiff > 0{
                        uphill += verticalDiff
                    }
                    else{
                        downhill += abs(verticalDiff)
                    }
                    lastAltitude = tpAlt
                }
                else{
                    //Logger.debug("skipping altitude (missing accuracy)")
                }
            }
            
            delegate?.trackRecordingChanged()
            return tp
        }
        return nil
    }
    
    func toggleRecording(){
        isRecording = !isRecording
        delegate?.trackRecordingChanged()
    }
    
    func cancelTracking(){
        track = nil
        isRecording = false
        delegate?.trackRecordingChanged()
    }
    
    func stopRecording(){
        isRecording = false
        delegate?.trackRecordingChanged()
    }
    
    func resumeRecording(){
        isRecording = true
        delegate?.trackRecordingChanged()
    }
    
}
