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
    var trackpoints: MapPointList
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
        trackpoints = MapPointList()
        distance = 0
        upDistance = 0
        downDistance = 0
    }
    
    init(gpx: GPXData){
        name = "Tour"
        trackpoints = MapPointList()
        distance = 0
        upDistance = 0
        downDistance = 0
        for segment in gpx.segments{
            for point in segment.points{
                addTrackpoint(point)
                name = gpx.name
            }
        }
        updateFromTrackpoints()
    }
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        trackpoints = try values.decodeIfPresent(MapPointList.self, forKey: .trackpoints) ?? MapPointList()
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
        if coordinateRegion == nil{
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
        try container.encode(coordinateRegion, forKey: .coordinateRegion)
        try container.encodeIfPresent(centerCoordinate?.latitude, forKey: .centerCoordinateLatitude)
        try container.encodeIfPresent(centerCoordinate?.longitude, forKey: .centerCoordinateLongitude)
        
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
    
    func trackpointIndex(of tp: MapPoint) -> Int {
        if let index = trackpoints.firstIndex(where: { $0 == tp }) {
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
    
    func addTrackpoint(_ tp: MapPoint){
        trackpoints.append(tp)
        updateFromTrackpoints()
    }
    
    func insertTrackpoint(_ tp: MapPoint, at index: Int){
        if index < 0 || index >= trackpoints.count - 1{
            return
        }
        trackpoints.insert(tp, at: index)
        updateFromTrackpoints()
    }
    
    func setTrackpoints(_ trackpoints: MapPointList){
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
            var last : MapPoint? = nil
            for tp in trackpoints{
                if let last = last{
                    distance += last.coordinate.distance(to: tp.coordinate)
                    if let tpAlt = tp.altitude, let lastAlt = last.altitude{
                        let verticalDiff = tpAlt - lastAlt
                        if verticalDiff > 0{
                            upDistance += verticalDiff
                        }
                        else{
                            downDistance += abs(verticalDiff)
                        }
                    }
                }
                last = tp
            }
            updateCoordinateRegion()
        }
    }
    
    func setMinimalTrackpointDistances(minDistance: CGFloat){
        if !trackpoints.isEmpty{
            var removables = MapPointList()
            var last : MapPoint = trackpoints.first!
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
                    tp1 == tp2
                })
            })
        }
        updateFromTrackpoints()
    }
    
    func updateCoordinateRegion(){
        coordinateRegion = trackpoints.coordinateRegion
        centerCoordinate = coordinateRegion?.center
    }
    
}

