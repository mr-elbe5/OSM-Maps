/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation

class RouteMarkerView : NSImageView{
    
    static var centerBaseFrame = CGRect(x: -12,y: -12, width: 24, height: 24)
    static var upperBaseFrame = CGRect(x: -12,y: -24, width: 24, height: 24)
    
    var coordinate: CLLocationCoordinate2D
    var baseFrame: CGRect = RouteMarkerView.centerBaseFrame
    
    init(coordinate: CLLocationCoordinate2D, image: NSImage) {
        self.coordinate = coordinate
        super.init(frame: .zero)
        self.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePosition(mapOffset: CGPoint, scale: Double){
        let mapPoint = CGPoint(coordinate)
        frame = baseFrame.offsetBy(dx: (mapPoint.x - mapOffset.x)*scale, dy: (mapPoint.y - mapOffset.y)*scale)
        needsDisplay = true
    }
    
}


