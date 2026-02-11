/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
import CoreLocation

class TrackImageCreator{
    
#if os(macOS)
    
    @discardableResult
    static func createPreview(item: TrackItem) -> OSImage?{
        if let preview = createImage(track: item.track, size: CGSize(width: TrackItem.previewSize, height: TrackItem.previewSize)){
            if let tiff = preview.tiffRepresentation, let tiffData = NSBitmapImageRep(data: tiff) {
                if let data = tiffData.representation(using: .jpeg, properties: [:]) {
                    _ = FileManager.default.assertDirectoryFor(url: item.previewURL)
                    if !FileManager.default.saveFile(data: data, url: item.previewURL){
                        Log.error("preview could not be saved at \(item.previewURL)")
                        return nil
                    }
                    return preview
                }
            }
            return preview
        }
        return nil
    }
    
    static func createImage(track: Track, size: NSSize) -> NSImage?{
        if track.trackpoints.isEmpty{
            return nil
        }
        let boundingTrackRect = track.trackpoints.boundingMapRect!
        let zoom = World.getZoomToFit(worldRect: boundingTrackRect, scaledSize: size)
        let downScale = World.downScale(to: zoom)
        let centerCoordinate = boundingTrackRect.centerCoordinate
        let centerPoint = World.scaledPoint(centerCoordinate, downScale: downScale)
        let scaledWorldViewRect = CGRect(x: centerPoint.x - size.width/2, y: centerPoint.y - size.height/2, width: size.width, height: size.height)
        let worldViewRect = World.worldRect(scaledRect: scaledWorldViewRect, downScale: downScale)
        if worldViewRect.isEmpty{
            return nil
        }
        let drawTileList = DrawTileList.getDrawTiles(size: size, zoom: zoom, downScale: downScale, scaledWorldViewRect: scaledWorldViewRect)
        if !drawTileList.assertDrawTileImages(){
            return nil
        }
        let img = NSImage(size: size, flipped: true){ rect in
            let ctx = NSGraphicsContext.current!.cgContext
            drawTileList.draw()
            drawTrack(track: track, ctx: ctx, size: size, zoom: zoom, downScale: downScale, worldViewRect: worldViewRect)
            return true
        }
        return img
    }
    
    private static func drawTrack(track: Track, ctx: CGContext, size: NSSize, zoom: Int, downScale: CGFloat, worldViewRect: CGRect) {
        if !track.trackpoints.isEmpty{
            var drawPoints = Array<CGPoint>()
            for idx in 0..<track.trackpoints.count{
                let trackpoint = track.trackpoints[idx]
                let mapPoint = CGPoint(trackpoint.coordinate)
                let drawPoint = CGPoint(x: (mapPoint.x - worldViewRect.minX)*downScale, y: (mapPoint.y - worldViewRect.minY)*downScale)
                //Log.debug("drawPoint = \(drawPoint)")
                drawPoints.append(drawPoint)
            }
            ctx.beginPath()
            ctx.move(to: drawPoints[0])
            for idx in 1..<drawPoints.count{
                ctx.addLine(to: drawPoints[idx])
            }
            ctx.setStrokeColor(NSColor.systemOrange.cgColor)
            ctx.setLineWidth(3.0)
            ctx.drawPath(using: .stroke)
        }
    }
    
#elseif os(iOS)
    
    @discardableResult
    static func createPreview(item: TrackItem) -> OSImage?{
        if let preview = createImage(track: item.track, size: CGSize(width: TrackItem.previewSize, height: TrackItem.previewSize)){
            if let data = preview.jpegData(compressionQuality: 0.85){
                _ = FileManager.default.assertDirectoryFor(url: item.previewURL)
                if !FileManager.default.saveFile(data: data, url: item.previewURL){
                    Log.error("preview could not be saved at \(item.previewURL)")
                    return nil
                }
            }
            return preview
        }
        return nil
    }
    
    static func createImage(track: Track, size: CGSize, withPoints: Bool = false) -> UIImage?{
        if track.trackpoints.isEmpty{
            return nil
        }
        let boundingTrackRect = track.trackpoints.boundingMapRect!
        let zoom = World.getZoomToFit(worldRect: boundingTrackRect, scaledSize: size)
        let downScale = World.downScale(to: zoom)
        let centerCoordinate = boundingTrackRect.centerCoordinate
        let centerPoint = World.scaledPoint(centerCoordinate, downScale: downScale)
        let scaledWorldViewRect = CGRect(x: centerPoint.x - size.width/2, y: centerPoint.y - size.height/2, width: size.width, height: size.height)
        let worldViewRect = World.worldRect(scaledRect: scaledWorldViewRect, downScale: downScale)
        if worldViewRect.isEmpty{
            return nil
        }
        let drawTileList = DrawTileList.getDrawTiles(size: size, zoom: zoom, downScale: downScale, scaledWorldViewRect: scaledWorldViewRect)
        if !drawTileList.assertDrawTileImages(){
            return nil
        }
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image(){ ctx in
            drawTileList.draw()
            drawTrack(track: track, ctx: ctx.cgContext, size: size, zoom: zoom, downScale: downScale, worldViewRect: worldViewRect, withPoints: withPoints)
        }
        return img
    }
    
    private static func drawTrack(track: Track, ctx: CGContext, size: CGSize, zoom: Int, downScale: CGFloat, worldViewRect: CGRect, withPoints: Bool = false) {
        if !track.trackpoints.isEmpty{
            var drawPoints = Array<CGPoint>()
            for idx in 0..<track.trackpoints.count{
                let trackpoint = track.trackpoints[idx]
                let mapPoint = CGPoint(trackpoint.coordinate)
                let drawPoint = CGPoint(x: (mapPoint.x - worldViewRect.minX)*downScale, y: (mapPoint.y - worldViewRect.minY)*downScale)
                //Log.debug("drawPoint = \(drawPoint)")
                drawPoints.append(drawPoint)
            }
            ctx.beginPath()
            ctx.move(to: drawPoints[0])
            for idx in 1..<drawPoints.count{
                ctx.addLine(to: drawPoints[idx])
            }
            ctx.setStrokeColor(UIColor.systemOrange.cgColor)
            ctx.setLineWidth(3.0)
            ctx.drawPath(using: .stroke)
            if withPoints{
                ctx.setFillColor(UIColor.systemBlue.cgColor)
                for idx in 0..<drawPoints.count{
                    let rect = CGRect(x: drawPoints[idx].x - 3, y: drawPoints[idx].y - 3, width: 6, height: 6)
                    ctx.addEllipse(in: rect)
                }
                ctx.drawPath(using: .fill)
            }
        }
    }
    
#endif
    
}

