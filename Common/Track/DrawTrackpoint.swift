/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class DrawTrackpoint{
    
    var trackpoint: MapPoint
    var drawpoint: CGPoint
    
    var offset: CGPoint = .zero
    var zoom: Int
    
    init(trackpoint: MapPoint, drawpoint: CGPoint, zoom: Int){
        self.trackpoint = trackpoint
        self.drawpoint = drawpoint
        self.zoom = zoom
    }
    
    func updateTrackpoint(offset: CGPoint){
        let downScale = World.downScale(to: zoom)
        let mapPoint = CGPoint(x: World.worldX(trackpoint.coordinate.longitude) + offset.x/downScale, y: World.worldY(trackpoint.coordinate.latitude) + offset.y/downScale)
        trackpoint.coordinate = World.coordinate(worldX: mapPoint.x, worldY: mapPoint.y)
    }
}

