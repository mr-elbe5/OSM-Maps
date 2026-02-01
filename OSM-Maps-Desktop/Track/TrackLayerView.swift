/*
 OSM Maps (Mac)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

class TrackLayerView: LayerView {
    
    override func draw(_ dirtyRect: NSRect) {
        if VisibleTrack.shared.isPresent{
            var drawPoints = Array<CGPoint>()
            for idx in 0..<VisibleTrack.shared.trackpoints.count{
                let trackpoint = VisibleTrack.shared.trackpoints[idx]
                let mapPoint = CGPoint(trackpoint.coordinate)
                let drawPoint = CGPoint(x: (mapPoint.x)*scale , y: (mapPoint.y)*scale)
                drawPoints.append(drawPoint)
            }
            let ctx = NSGraphicsContext.current!.cgContext
            ctx.beginPath()
            ctx.move(to: drawPoints[0])
            for idx in 1..<drawPoints.count{
                ctx.addLine(to: drawPoints[idx])
            }
            ctx.setStrokeColor(NSColor.systemOrange.cgColor)
            ctx.setLineWidth(3.0)
            ctx.drawPath(using: .stroke)
            ctx.setFillColor(NSColor.black.cgColor)
        }
    }
    
}




