/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class VisibleTrack: NSObject{
    
    static var shared = VisibleTrack()
    
    var trackpoints = MapPointList()
    var startMapPoint: CGPoint?
    var points = [CGPoint]()
    var boundingRect: CGRect = .zero
    
    var isPresent: Bool{
        !trackpoints.isEmpty
    }
    
    var startCoordinate: CLLocationCoordinate2D?{
        trackpoints.first?.coordinate
    }
    
    func setTrack(_ track: Track){
        reset()
        trackpoints.append(contentsOf: track.trackpoints)
        trackpoints.forEach{
            addMapPoint(trackpoint: $0)
        }
    }
    
    func reset(){
        trackpoints.removeAll()
        startMapPoint = nil
        points.removeAll()
        boundingRect = .zero
    }
    
    func addTrackpoint(_ trackpoint: MapPoint){
        trackpoints.append(trackpoint)
        addMapPoint(trackpoint: trackpoint)
    }
    
    func addMapPoint(trackpoint: MapPoint) {
        let scaledMapPoint = World.scaledPoint(trackpoint.coordinate, downScale: MapStatus.shared.scale)
        if let startPoint = startMapPoint{
            let pnt = CGPoint(x: scaledMapPoint.x - startPoint.x, y: scaledMapPoint.y - startPoint.y)
            points.append(pnt)
            updateRect()
        }
        else{
            startMapPoint = scaledMapPoint
            boundingRect = .zero
        }
    }
    
    private func updateRect(){
        var minX: CGFloat = .infinity
        var minY: CGFloat = .infinity
        var maxX: CGFloat = 0
        var maxY: CGFloat = 0
        for pnt in points{
            minX = min(minX, pnt.x)
            minY = min(minY, pnt.y)
            maxX = max(maxX, pnt.x)
            maxY = max(maxY, pnt.y)
        }
        boundingRect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
}
    
