/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

protocol TrackRecorderDelegate{
    func trackStarted()
    func trackRecordingChanged()
    func addTrackpoint(_ trackpoint: Trackpoint)
    func saveTrack(_ track: Track, result: @escaping(Bool) -> Void)
}

class TrackRecorder: NSObject{
    
    static var shared = TrackRecorder()
    
    var track: Track? = nil
    
    var isRecording: Bool = false
    
    var interrupted = false
    
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
    
    func startTrack(){
        track = Track()
        isRecording = true
        delegate?.trackStarted()
    }
    
    func saveTrack(){
        stopRecording()
        if let track = track{
            delegate?.saveTrack(track){success in
                self.track = nil
            }
        }
        delegate?.trackRecordingChanged()
    }
    
    func locationChanged(to location: CLLocation){
        if let trackpoint = addTrackpoint(from: location){
            delegate?.addTrackpoint(trackpoint)
        }
    }
    
    func addTrackpoint(from location: CLLocation) -> Trackpoint?{
        if let track = track{
            let tp = Trackpoint(location: location)
            if track.trackpoints.isEmpty{
                track.trackpoints.append(tp)
                lastCoordinate = location.coordinate
                lastAltitude = location.altitude
                uphill = 0
                downhill = 0
                Log.debug("starting track at \(tp.coordinate.debugString)")
                track.upDistance = 0
                return tp
            }
            let previousTrackpoint = track.trackpoints.last!
            // check time interval
            let timeDiff = previousTrackpoint.timestamp.distance(to: tp.timestamp)
            //Log.debug("timeDiff = \(timeDiff)")
            if timeDiff < Preferences.shared.trackpointInterval.interval{
                //Log.debug("skipping by time")
                return nil
            }
            // check distance
            let horizontalDiff = lastCoordinate.distance(to: tp.coordinate)
            //Log.debug("horizontalDiff = \(horizontalDiff)")
            //Log.debug("horizontalAccuracy = \(location.horizontalAccuracy)")
            if Preferences.shared.distanceFilter == .gps{
                if location.horizontalAccuracy >= 0, horizontalDiff < location.horizontalAccuracy{
                    //Log.debug("skipping location (missing accuracy)")
                    return nil
                }
            }
            else{
                if location.horizontalAccuracy >= 0, horizontalDiff < Preferences.shared.distanceFilter.distance{
                    //Log.debug("skipping location (missing accuracy)")
                    return nil
                }
            }
            lastCoordinate = location.coordinate
            //Log.debug("adding trackpoint at \(tp.coordinate.debugString)")
            track.trackpoints.append(tp)
            track.distance += horizontalDiff
            //checking uphill
            let verticalDiff = tp.altitude - lastAltitude
            //Log.debug("verticalDiff = \(verticalDiff)")
            //Log.debug("verticalAccuracy = \(location.verticalAccuracy)")
            if location.verticalAccuracy >= 0, verticalDiff >= location.verticalAccuracy{
                if verticalDiff > 0{
                    uphill += verticalDiff
                }
                else{
                    downhill += abs(verticalDiff)
                }
                lastAltitude = tp.altitude
            }
            else{
                //Log.debug("skipping altitude (missing accuracy)")
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
