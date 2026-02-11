/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

@Observable class TrackStatus: NSObject{
    
    static var shared = TrackStatus()
    
    var isTracking: Bool = false
    var isRecording: Bool = false
    var durationString: String = ""
    var coveredDistance: Int = 0
    var coveredAltitude: Int = 0
    var trackpointCount: Int = 0
    
}

extension TrackStatus: TrackRecorderDelegate{
    
    func trackStarted() {
        trackRecordingChanged()
    }
    
    func trackRecordingChanged(){
        isTracking = TrackRecorder.shared.isTracking
        isRecording = TrackRecorder.shared.isRecording
        durationString = TrackRecorder.shared.durationString
        coveredDistance = Int(TrackRecorder.shared.coveredDistance)
        trackpointCount = TrackRecorder.shared.trackpointCount
    }
    
    func savingTrackFailed() {
        
    }
    
    func addTrackpoint(_ trackpoint: MapPoint) {
    }
    
    func saveTrack(_ track: Track, result: @escaping (Bool) -> Void){
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(track){
            if let json = String(data:data, encoding: .utf8){
                PhoneConnector.shared.saveTrack(json: json){ success in
                    if success{
                        self.trackRecordingChanged()
                    }
                    result(success)
                    return
                }
            }
        }
        result(false)
    }
    
}


