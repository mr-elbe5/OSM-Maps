/*
 OSM Maps (Mac)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation

protocol TrackEditViewDelegate{
    func trackpointChangedInMap(_ trackpoint: Mappoint)
}

class NSTrackEditView : NSClipView{
    
    var track: Track
    
    var boundingTrackRect: CGRect = .zero
    var zoom = World.maxZoom
    var downScale: CGFloat{
        World.downScale(to: zoom)
    }
    var scaledWorldViewRect: CGRect = .zero
    var worldViewRect: CGRect = .zero
    
    var drawTrackPoints = Array<DrawTrackpoint>()
    
    var delegate: TrackEditViewDelegate? = nil
    
    init(track: Track){
        self.track = track
        super.init(frame: .zero)
        backgroundColor = .clear
        postsFrameChangedNotifications = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isFlipped: Bool {
        return true
    }
    
    override func setFrameSize(_ newSize: NSSize) {
        if !track.trackpoints.isEmpty{
            boundingTrackRect = track.trackpoints.boundingMapRect!
            zoom = World.getZoomToFit(worldRect: boundingTrackRect, scaledSize: newSize)
            let centerCoordinate = boundingTrackRect.centerCoordinate
            let centerPoint = CGPoint(x: World.scaledX(centerCoordinate.longitude, downScale: downScale), y: World.scaledY(centerCoordinate.latitude, downScale: downScale))
            scaledWorldViewRect = CGRect(x: centerPoint.x - newSize.width/2, y: centerPoint.y - newSize.height/2, width: newSize.width, height: newSize.height)
            worldViewRect = World.worldRect(scaledRect: scaledWorldViewRect, downScale: downScale)
            setDrawTrackPoints()
            setMarkers()
        }
        super.setFrameSize(newSize)
    }
    
    func setDrawTrackPoints(){
        drawTrackPoints.removeAll()
        for idx in 0..<track.trackpoints.count{
            let trackpoint = track.trackpoints[idx]
            let mapPoint = CGPoint(trackpoint.coordinate)
            let drawPoint = CGPoint(x: (mapPoint.x - worldViewRect.minX)*downScale, y: (mapPoint.y - worldViewRect.minY)*downScale)
            drawTrackPoints.append(DrawTrackpoint(trackpoint: trackpoint, drawpoint: drawPoint, zoom: zoom))
        }
    }
    
    func setMarkers() {
        removeAllSubviews()
        if !track.trackpoints.isEmpty{
            for idx in 0..<drawTrackPoints.count{
                let btn = TrackpointMarker(point: drawTrackPoints[idx])
                addSubview(btn)
                btn.delegate = self
            }
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if !worldViewRect.isEmpty{
            let ctx = NSGraphicsContext.current!.cgContext
            drawTiles()
            drawTrack(ctx)
        }
        super.draw(dirtyRect)
    }
    
    func drawTiles() {
        let drawTileList = DrawTileList.getDrawTiles(size: bounds.size, zoom: zoom, downScale: downScale, scaledWorldViewRect: scaledWorldViewRect)
        if drawTileList.assertDrawTileImages(){
            drawTileList.draw()
        }
    }
    
    func drawTrack(_ ctx: CGContext) {
        if !drawTrackPoints.isEmpty{
            ctx.beginPath()
            ctx.move(to: drawTrackPoints[0].drawpoint)
            for idx in 1..<drawTrackPoints.count{
                ctx.addLine(to: drawTrackPoints[idx].drawpoint)
            }
            ctx.setStrokeColor(NSColor.systemOrange.cgColor)
            ctx.setLineWidth(2.0)
            ctx.drawPath(using: .stroke)
        }
    }
    
    func trackpointsChanged(){
        setDrawTrackPoints()
        setMarkers()
        needsDisplay = true
    }
    
}

extension NSTrackEditView: TrackpointMarkerDelegate{
    
    func pointTapped(_ marker: TrackpointMarker, commandPressed: Bool) {
        let trackpoint = marker.point.trackpoint
        if !commandPressed{
            for sv in subviews{
                if let m = sv as? TrackpointMarker, m != marker{
                    m.point.trackpoint.selected = false
                    m.needsDisplay = true
                }
            }
        }
        trackpoint.selected = !trackpoint.selected
        marker.needsDisplay = true
        delegate?.trackpointChangedInMap(trackpoint)
    }
    
    func markerMoved(){
        needsDisplay = true
    }
    
}
