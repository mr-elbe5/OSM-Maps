/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class MapItemGroup {
    
    var items = MapItemList()
    
    var centerCoordinate: CLLocationCoordinate2D? = nil
    
    var centerWorldPoint: CGPoint?{
        if let coordinate = centerCoordinate{
            return CGPoint(coordinate)
        }
        return nil
    }
    
    init(){
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    func addItem(_ item: MapItem){
        items.append(item)
    }
    
    var hasMedia: Bool{
        for item in items{
            if item is ImageItem || item is AudioItem || item is VideoItem{
                return true
            }
        }
        return false
    }
    
    var hasNote: Bool{
        for item in items{
            if item is NoteItem{
                return true
            }
        }
        return false
    }
    
    var hasTrack: Bool{
        for item in items{
            if item is TrackItem{
                return true
            }
        }
        return false
    }
    
    var hasRoute: Bool{
        for item in items{
            if item is RouteItem{
                return true
            }
        }
        return false
    }
    
    func setCenter(){
        var minLon : CGFloat? = nil
        var maxLon : CGFloat? = nil
        var minLat : CGFloat? = nil
        var maxLat : CGFloat? = nil
        
        for loc in items{
            minLon = min(minLon ?? CGFloat.greatestFiniteMagnitude, loc.coordinate.longitude)
            maxLon = max(maxLon ?? -CGFloat.greatestFiniteMagnitude, loc.coordinate.longitude)
            minLat = min(minLat ?? CGFloat.greatestFiniteMagnitude, loc.coordinate.latitude)
            maxLat = max(maxLat ?? -CGFloat.greatestFiniteMagnitude, loc.coordinate.latitude)
        }
        if let minX = minLon,let maxX = maxLon, let minY = minLat, let maxY = maxLat{
            centerCoordinate = CLLocationCoordinate2D(latitude: (minY + maxY)/2, longitude: (minX + maxX)/2)
        }
        else {
            centerCoordinate = nil
        }
    }
    
    func isWithinRadius(item: MapItem, radius: CGFloat) -> Bool{
        if let centerCoordinate = centerCoordinate{
            let dist = centerCoordinate.distance(to: item.coordinate)
            //Log.debug("dist = \(dist) at radius \(radius)")
            return dist <= radius
        }
        return false
    }
    
    func deselectAll(){
        items.deselectAll()
    }
    
    func toggleSelection(){
        items.toggleSelection()
    }
    
}
