/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation

typealias TrackpointList = SelectableList<Trackpoint>

extension TrackpointList{
    
    var boundingCoordinates: (topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D)?{
        get{
            if isEmpty{
                return nil
            }
            var coord = self[0].coordinate
            var top = coord.latitude
            var bottom = coord.latitude
            var left = coord.longitude
            var right = coord.longitude
            for i in 1..<count{
                coord = self[i].coordinate
                top = Swift.max(top, coord.latitude)
                bottom = Swift.min(bottom, coord.latitude)
                left = Swift.min(left, coord.longitude)
                right = Swift.max(right, coord.longitude)
            }
            return (topLeft: CLLocationCoordinate2D(latitude: top,longitude: left),
                    bottomRight: CLLocationCoordinate2D(latitude: bottom,longitude: right))
        }
    }
    
    var boundingMapRect: CGRect?{
        if let boundingCoordinates = boundingCoordinates{
            let topLeftPoint: CGPoint = World.worldPoint(coordinate: boundingCoordinates.topLeft)
            let bottomRightPoint: CGPoint = World.worldPoint(coordinate: boundingCoordinates.bottomRight)
            
            return CGRect(x: topLeftPoint.x, y: topLeftPoint.y, width: bottomRightPoint.x - topLeftPoint.x, height: bottomRightPoint.y - topLeftPoint.y)
        }
        return nil
    }
    
}


