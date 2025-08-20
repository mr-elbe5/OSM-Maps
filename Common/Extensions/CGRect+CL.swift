/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation

extension CGRect{
    
    var centerInWorld: CGPoint{
        var cx = origin.x + size.width/2
        if cx > World.worldSize.width{
            cx -= World.worldSize.width
        }
        return CGPoint(x: cx, y: origin.y + size.height/2)
    }
    
    var topLeftCoordinate : CLLocationCoordinate2D{
        origin.coordinate
    }
    
    var bottomRightCoordinate : CLLocationCoordinate2D{
        if spans180Medidian, let rect = medianRemainderRect{
            return rect.bottomRightCoordinate
        }
        return CGPoint(x: origin.x + size.width, y: origin.y + size.height).coordinate
    }
    
    var centerCoordinate : CLLocationCoordinate2D{
        center.coordinate
    }
    
    var spans180Medidian : Bool{
        origin.x + size.width > World.worldSize.width
    }
    
    var medianRemainderRect : CGRect?{
        if !spans180Medidian{
            return nil
        }
        return CGRect(origin: CGPoint(x: 0, y: origin.y), size: CGSize(width: origin.x + size.width - World.worldSize.width, height: size.height))
    }
    
    var normalizedRect : CGRect{
        if origin.x > World.worldSize.width{
            return CGRect(origin: CGPoint(x: origin.x - World.worldSize.width, y: origin.y), size: size)
        }
        return self
    }
    
}

