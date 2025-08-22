/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import CloudKit

class Track: Codable{
    
    static var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .short
        formatter.maximumUnitCount = 2
        formatter.collapsesLargestUnit = false
        formatter.zeroFormattingBehavior = .default
        return formatter
    }()
        
    private enum CodingKeys: String, CodingKey {
        case name
        case trackpoints
        case startTime
        case endTime
        case distance
        case upDistance
        case downDistance
        case coordinateRegion
        case centerCoordinateLatitude
        case centerCoordinateLongitude
    }
    
    var name : String
    var trackpoints: TrackpointList
    var pauseTime : Date? = nil
    var pauseLength : TimeInterval = 0
    var distance : CGFloat
    var upDistance : CGFloat
    var downDistance : CGFloat
    var coordinateRegion : CoordinateRegion? = nil
    var centerCoordinate : CLLocationCoordinate2D? = nil
    
    var worldRect: CGRect?{
        coordinateRegion?.worldRect
    }
    
    var startTime : Date{
        trackpoints.first?.timestamp ?? Date()
    }
    var endTime :Date{
        trackpoints.last?.timestamp ?? Date()
    }
    
    var durationString: String{
        return Self.durationFormatter.string(from: duration) ?? "00:00"
    }
    
    var duration : TimeInterval{
        if let pauseTime = pauseTime{
            return startTime.distance(to: pauseTime) - pauseLength
        }
        return startTime.distance(to: endTime) - pauseLength
    }
    
    var durationUntilNow : TimeInterval{
        if let pauseTime = pauseTime{
            return startTime.distance(to: pauseTime) - pauseLength
        }
        return startTime.distance(to: Date.localDate) - pauseLength
    }
    
    var startCoordinate: CLLocationCoordinate2D?{
        trackpoints.first?.coordinate
    }
    
    var endCoordinate: CLLocationCoordinate2D?{
        trackpoints.last?.coordinate
    }
    
    init(){
        name = "Tour"
        trackpoints = TrackpointList()
        distance = 0
        upDistance = 0
        downDistance = 0
    }
    
    init(gpx: GPXData){
        name = "Tour"
        trackpoints = TrackpointList()
        distance = 0
        upDistance = 0
        downDistance = 0
        for segment in gpx.segments{
            for point in segment.points{
                let trackpoint = Trackpoint(coordinate: point.coordinate, altitude: point.altitude, timestamp: point.timestamp ?? Date())
                addTrackpoint(trackpoint)
                name = gpx.name
            }
        }
        updateFromTrackpoints()
    }
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        trackpoints = try values.decodeIfPresent(TrackpointList.self, forKey: .trackpoints) ?? TrackpointList()
        distance = try values.decodeIfPresent(CGFloat.self, forKey: .distance) ?? 0
        upDistance = try values.decodeIfPresent(CGFloat.self, forKey: .upDistance) ?? 0
        downDistance = try values.decodeIfPresent(CGFloat.self, forKey: .downDistance) ?? 0
        coordinateRegion = try values.decodeIfPresent(CoordinateRegion.self, forKey: .coordinateRegion)
        if let lat = try values.decodeIfPresent(CLLocationDegrees.self, forKey: .centerCoordinateLatitude), lat != 0,
           let lon = try values.decodeIfPresent(CLLocationDegrees.self, forKey: .centerCoordinateLongitude){
            if lat != 0 || lon != 0{
                centerCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
        }
        if coordinateRegion == .zero{
            updateCoordinateRegion()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(trackpoints, forKey: .trackpoints)
        try container.encode(distance, forKey: .distance)
        try container.encode(upDistance, forKey: .upDistance)
        try container.encode(downDistance, forKey: .downDistance)
    }
    
    func update(from track: Track){
        trackpoints.removeAll()
        trackpoints.append(contentsOf: track.trackpoints)
        updateFromTrackpoints()
    }
    
    func setNameByDate(){
        name = "tourOf".localize(s: startTime.dateTimeString())
    }
    
    func pauseTracking(){
        pauseTime = Date.localDate
    }
    
    func resumeTracking(){
        if let pauseTime = pauseTime{
            pauseLength += pauseTime.distance(to: Date.localDate)
            self.pauseTime = nil
        }
    }
    
    func trackpointIndex(of tp: Trackpoint) -> Int {
        if let index = trackpoints.firstIndex(where: { $0.id == tp.id }) {
            return index
        }
        return -1
    }
    
    func  getSingleSelectedTrackpointIndex() -> Int?{
        var idx: Int?
        for i in 0..<trackpoints.count{
            let tp = trackpoints[i]
            if tp.selected{
                if idx == nil {
                    idx = i
                }
                else{
                    idx = nil
                    break
                }
            }
        }
        return idx
    }
    
    func  selectSingleTrackpoint(at idx: Int){
        trackpoints.deselectAll()
        trackpoints[idx].selected = true
    }
    
    func addTrackpoint(_ tp: Trackpoint){
        trackpoints.append(tp)
        updateFromTrackpoints()
    }
    
    func insertTrackpoint(_ tp: Trackpoint, at index: Int){
        if index < 0 || index >= trackpoints.count - 1{
            return
        }
        trackpoints.insert(tp, at: index)
        updateFromTrackpoints()
    }
    
    func setTrackpoints(_ trackpoints: TrackpointList){
        if !trackpoints.isEmpty{
            self.trackpoints = trackpoints
            updateFromTrackpoints()
        }
    }
    
    func updateFromTrackpoints(){
        if !trackpoints.isEmpty{
            distance = 0
            upDistance = 0
            downDistance = 0
            var last : Trackpoint? = nil
            for tp in trackpoints{
                if let last = last{
                    distance += last.coordinate.distance(to: tp.coordinate)
                    let verticalDiff = tp.altitude - last.altitude
                    if verticalDiff > 0{
                        upDistance += verticalDiff
                    }
                    else{
                        downDistance += abs(verticalDiff)
                    }
                }
                last = tp
            }
            updateCoordinateRegion()
        }
    }
    
    func setMinimalTrackpointDistances(minDistance: CGFloat){
        if !trackpoints.isEmpty{
            var removables = Array<Trackpoint>()
            var last : Trackpoint = trackpoints.first!
            for idx in 1..<trackpoints.count - 1{
                let tp = trackpoints[idx]
                let distance = last.coordinate.distance(to: tp.coordinate)
                if distance < minDistance{
                    removables.append(tp)
                }
                else{
                    last = tp
                }
            }
            trackpoints.removeAll(where: { tp1 in
                removables.contains(where: { tp2 in
                    tp1.id == tp2.id
                })
            })
        }
        updateFromTrackpoints()
    }
    
    func updateCoordinateRegion(){
        let cr = CoordinateRegion()
        if let start = trackpoints.first{
            cr.minLatitude = start.coordinate.latitude
            cr.maxLatitude = start.coordinate.latitude
            cr.minLongitude = start.coordinate.longitude
            cr.maxLongitude = start.coordinate.longitude
            for i in 1..<self.trackpoints.count{
                let tp = trackpoints[i]
                if tp.coordinate.latitude < cr.minLatitude{
                    cr.minLatitude = tp.coordinate.latitude
                }
                if tp.coordinate.latitude > cr.maxLatitude{
                    cr.maxLatitude = tp.coordinate.latitude
                }
                if tp.coordinate.longitude < cr.minLongitude{
                    cr.minLongitude = tp.coordinate.longitude
                }
                if tp.coordinate.longitude > cr.maxLongitude{
                    cr.maxLongitude = tp.coordinate.longitude
                }
            }
            coordinateRegion = cr
            centerCoordinate = cr.center
        }
    }
    
    func findClosestTrackpoint(to coordinate: CLLocationCoordinate2D) -> (Trackpoint, Double)? {
        var closestTrackpoint: Trackpoint?
        var minDistance: Double?
        for trackpoint in self.trackpoints {
            let distance = trackpoint.coordinate.distance(to: coordinate)
            if minDistance == nil || distance < minDistance! {
                closestTrackpoint = trackpoint
                minDistance = distance
            }
        }
        if let tp = closestTrackpoint, let dist = minDistance {
            return (tp, dist)
        }
        return nil
    }
    
    func findClosestTrackpoint(at date: Date) -> (Trackpoint, TimeInterval)?{
        var closestTrackpoint: Trackpoint?
        var minDistance: TimeInterval?
        for trackpoint in self.trackpoints {
            let distance = trackpoint.timestamp.distance(to: date)
            if minDistance == nil || distance < minDistance! {
                closestTrackpoint = trackpoint
                minDistance = distance
            }
        }
        if let tp = closestTrackpoint, let dist = minDistance {
            return (tp, dist)
        }
        return nil
    }
    
}

