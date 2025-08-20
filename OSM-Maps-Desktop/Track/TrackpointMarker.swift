/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

import CoreLocation

protocol TrackpointMarkerDelegate{
    func pointTapped(_ marker: TrackpointMarker, commandPressed: Bool)
    func markerMoved()
}

class TrackpointMarker: NSControl{
    
    var point: DrawTrackpoint
    
    var offset: CGPoint = .zero
    
    var delegate: TrackpointMarkerDelegate? = nil
    
    init(point: DrawTrackpoint){
        self.point = point
        super.init(frame: NSRect(x: point.drawpoint.x - 5, y: point.drawpoint.y - 5, width: 10, height: 10))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let ctx = NSGraphicsContext.current!.cgContext
        ctx.setFillColor(point.trackpoint.selected ? NSColor.systemRed.cgColor : NSColor.systemBlue.cgColor)
        ctx.fillEllipse(in: bounds)
    }
    
    override func mouseDown(with event: NSEvent) {
        if event.type == .leftMouseDown{
            offset = .zero
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        if event.type == .leftMouseUp{
            if offset == .zero{
                delegate?.pointTapped(self, commandPressed: event.modifierFlags.contains(.command))
            }
            else{
                point.updateTrackpoint(offset: offset)
                offset = .zero
            }
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        if event.type == .leftMouseDragged{
            offset = CGPoint(x: offset.x + event.deltaX, y: offset.y + event.deltaY)
            point.drawpoint = CGPoint(x: point.drawpoint.x + event.deltaX, y: point.drawpoint.y + event.deltaY)
            frame.origin.x += event.deltaX
            frame.origin.y += event.deltaY
            delegate?.markerMoved()
        }
    }
    
}



