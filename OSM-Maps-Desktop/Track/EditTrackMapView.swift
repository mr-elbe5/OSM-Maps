/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

import CoreLocation

protocol EditTrackMapDelegate{
    func trackpointChangedInMap(_ trackpoint: Trackpoint)
}

class EditTrackMapView : NSClipView{
    
    var item: TrackItem
    
    var boundingTrackRect: CGRect = .zero
    var zoom = World.maxZoom
    var downScale: CGFloat{
        World.downScale(to: zoom)
    }
    var scaledWorldViewRect: CGRect = .zero
    var worldViewRect: CGRect = .zero
    
    var drawTrackPoints = Array<DrawTrackpoint>()
    
    var delegate: EditTrackMapDelegate? = nil
    
    private var drawRetries: Int = 0
    
    init(track: TrackItem){
        self.item = track
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
        if !item.track.trackpoints.isEmpty{
            boundingTrackRect = item.track.trackpoints.boundingMapRect!
            //Log.info("boundingTrackRect = \(boundingTrackRect)")
            zoom = World.getZoomToFit(worldRect: boundingTrackRect, scaledSize: newSize)
            //Log.info("zoom = \(zoom)")
            //Log.info("downScale = \(downScale)")
            let centerCoordinate = boundingTrackRect.centerCoordinate
            //Log.info("centerCoordinate = \(centerCoordinate)")
            let centerPoint = CGPoint(x: World.scaledX(centerCoordinate.longitude, downScale: downScale), y: World.scaledY(centerCoordinate.latitude, downScale: downScale))
            //Log.info("centerPoint = \(centerPoint)")
            scaledWorldViewRect = CGRect(x: centerPoint.x - newSize.width/2, y: centerPoint.y - newSize.height/2, width: newSize.width, height: newSize.height)
            //Log.info("scaledWorld = \(World.scaledWorld(zoom: zoom))")
            worldViewRect = World.worldRect(scaledRect: scaledWorldViewRect, downScale: downScale)
            //Log.info("worldViewRect = \(worldViewRect)")
            setDrawTrackPoints()
            setMarkers()
        }
        super.setFrameSize(newSize)
    }
    
    func setDrawTrackPoints(){
        drawTrackPoints.removeAll()
        for idx in 0..<item.track.trackpoints.count{
            let trackpoint = item.track.trackpoints[idx]
            let mapPoint = CGPoint(trackpoint.coordinate)
            let drawPoint = CGPoint(x: (mapPoint.x - worldViewRect.minX)*downScale, y: (mapPoint.y - worldViewRect.minY)*downScale)
            drawTrackPoints.append(DrawTrackpoint(trackpoint: trackpoint, drawpoint: drawPoint, zoom: zoom))
        }
    }
    
    func setMarkers() {
        removeAllSubviews()
        if !item.track.trackpoints.isEmpty{
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
            if drawTiles(){
                drawTrack(ctx)
            }
            else if drawRetries < 3{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.drawRetries += 1
                    self.needsDisplay = true
                }
            }
        }
        super.draw(dirtyRect)
    }
    
    func drawTiles() -> Bool{
        let drawTileList = DrawTileList.getDrawTiles(size: bounds.size, zoom: zoom, downScale: downScale, scaledWorldViewRect: scaledWorldViewRect)
        if drawTileList.assertDrawTileImages(){
            drawTileList.draw()
            return true
        }
        return false
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

extension EditTrackMapView: TrackpointMarkerDelegate{
    
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
