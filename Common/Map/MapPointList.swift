/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

typealias MapPointList = [MapPoint]

extension MapPointList{
    
    var allSelected: Bool{
        get{
            allSatisfy({
                $0.selected
            })
        }
    }
    
    var allUnselected: Bool{
        get{
            allSatisfy({
                !$0.selected
            })
        }
    }
    
    var anySelected: Bool{
        get{
            !allUnselected
        }
    }
    
    mutating func selectAll(){
        for item in self{
            item.selected = true
        }
    }
    
    mutating func deselectAll(){
        for item in self{
            item.selected = false
        }
    }
    
    mutating func toggleSelection(){
        var selected = false
        for item in self{
            if item.selected{
                selected = true
                break
            }
        }
        for item in self{
            item.selected = !selected
        }
    }
    
    var boundingCoordinates: (topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D)?{
        get{
            if isEmpty{
                return nil
            }
            var top = self[0].latitude
            var bottom = self[0].latitude
            var left = self[0].longitude
            var right = self[0].longitude
            for i in 1..<count{
                top = Swift.max(top, self[i].latitude)
                bottom = Swift.min(bottom, self[i].latitude)
                left = Swift.min(left, self[i].longitude)
                right = Swift.max(right, self[i].longitude)
            }
            return (topLeft: CLLocationCoordinate2D(latitude: top,longitude: left),
                    bottomRight: CLLocationCoordinate2D(latitude: bottom,longitude: right))
        }
    }
    
    var coordinateRegion: CoordinateRegion{
        let boundingCoordinates = boundingCoordinates
        return CoordinateRegion(topLeft: boundingCoordinates!.topLeft, bottomRight: boundingCoordinates!.bottomRight)
    }
    
    var boundingMapRect: CGRect?{
        if let boundingCoordinates = boundingCoordinates{
            let topLeftPoint: CGPoint = World.worldPoint(coordinate: boundingCoordinates.topLeft)
            let bottomRightPoint: CGPoint = World.worldPoint(coordinate: boundingCoordinates.bottomRight)
            
            return CGRect(x: topLeftPoint.x, y: topLeftPoint.y, width: bottomRightPoint.x - topLeftPoint.x, height: bottomRightPoint.y - topLeftPoint.y)
        }
        return nil
    }
    
    func findNearestPoint(to coordinate: CLLocationCoordinate2D) -> (MapPoint, Double)? {
        var nearestPoint: MapPoint?
        var minDistance: Double?
        for point in self {
            let distance = point.coordinate.distance(to: coordinate)
            if minDistance == nil || distance < minDistance! {
                nearestPoint = point
                minDistance = distance
            }
        }
        if let tp = nearestPoint, let dist = minDistance {
            return (tp, dist)
        }
        return nil
    }
    
    func findClosestPoint(to date: Date) -> (MapPoint, TimeInterval)?{
        var closestPoint: MapPoint?
        var minTimeDiff: TimeInterval?
        for point in self {
            if let timestamp = point.timestamp {
                let diff = timestamp.distance(to: date)
                if minTimeDiff == nil || diff < minTimeDiff! {
                    closestPoint = point
                    minTimeDiff = diff
                }
            }
            
        }
        if let point = closestPoint, let diff = minTimeDiff {
            return (point, diff)
        }
        return nil
    }
    
}
