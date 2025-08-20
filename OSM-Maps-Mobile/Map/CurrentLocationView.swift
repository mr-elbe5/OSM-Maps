/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

class CurrentLocationView : UIView{
    
    static var currentLocationColor = UIColor.systemBlue
    static var currentDirectionColor = UIColor.systemRed

    static let frameRect = CGRect(x: 0, y: 0, width: 40, height: 40)
    
    let locationRadius: CGFloat = frameRect.width/2
    
    var location = CLLocation()
    var scale : CGFloat = 1.0
    var planetPoint : CGPoint = .zero
    var direction : CLLocationDirection = 0
    
    func updateLocationPoint(location: CLLocation, offset: CGPoint, scale: CGFloat){
        self.location = location
        self.planetPoint = CGPoint(location.coordinate)
        updatePosition(offset: offset, scale: scale)
    }
    
    func updatePosition(offset: CGPoint, scale: CGFloat){
        let mapOffset = CGPoint(x: offset.x/scale, y: offset.y/scale).normalizedPoint
        let drawCenter = CGPoint(x: (planetPoint.x - mapOffset.x)*scale , y: (planetPoint.y - mapOffset.y)*scale)
        self.frame = CGRect(x: drawCenter.x - locationRadius , y: drawCenter.y - locationRadius, width: 2*locationRadius, height: 2*locationRadius)
        self.scale = scale
        setNeedsDisplay()
    }
    
    func updateDirection(direction: CLLocationDirection){
        self.direction = direction
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let drawCenter = CGPoint(x: locationRadius, y: locationRadius)
        let ctx = UIGraphicsGetCurrentContext()!
        let angle: CGFloat = direction*CGFloat.pi/180
        let angle1: CGFloat = (direction-90)*CGFloat.pi/180
        let angle2: CGFloat = (direction+90)*CGFloat.pi/180
        
        ctx.beginPath()
        ctx.setFillColor(CurrentLocationView.currentDirectionColor.cgColor)
        ctx.setLineWidth(3.0)
        ctx.move(to: CGPoint(x: drawCenter.x + locationRadius/2 * sin(angle1), y: drawCenter.y - locationRadius/2 * cos(angle1)))
        ctx.addLine(to: CGPoint(x: drawCenter.x + locationRadius/2 * sin(angle2), y: drawCenter.y - locationRadius/2 * cos(angle2)))
        ctx.addLine(to: CGPoint(x: drawCenter.x + locationRadius * sin(angle), y: drawCenter.y - locationRadius * cos(angle)))
        ctx.closePath()
        ctx.drawPath(using: .fill)
        
        ctx.beginPath()
        ctx.setLineWidth(2.0)
        ctx.addEllipse(in: CurrentLocationView.frameRect.scaleCenteredBy(0.5))
        ctx.setStrokeColor(CurrentLocationView.currentLocationColor.cgColor)
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.drawPath(using: .fillStroke)
        
        ctx.beginPath()
        ctx.addEllipse(in: CurrentLocationView.frameRect.scaleCenteredBy(0.25))
        ctx.setFillColor(CurrentLocationView.currentLocationColor.cgColor)
        ctx.drawPath(using: .fill)
        
    }
    
}
