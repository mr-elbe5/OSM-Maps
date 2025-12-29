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

class RouteImageCreator{
    
#if os(macOS)
    
    @discardableResult
    static func createPreview(item: RouteItem) -> OSImage?{
        if let preview = createImage(route: item.route, size: CGSize(width: RouteItem.previewSize, height: RouteItem.previewSize)){
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
    
    static func createImage(route: Route, size: NSSize) -> NSImage?{
        if route.routePoints.isEmpty{
            return nil
        }
        let boundingRouteRect = route.routePoints.boundingMapRect!
        let zoom = World.getZoomToFit(worldRect: boundingRouteRect, scaledSize: size)
        let downScale = World.downScale(to: zoom)
        let centerCoordinate = boundingRouteRect.centerCoordinate
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
            drawRoute(route: route, ctx: ctx, size: size, zoom: zoom, downScale: downScale, worldViewRect: worldViewRect)
            return true
        }
        return img
    }
    
    static func drawRoute(route: Route, ctx: CGContext, size: NSSize, zoom: Int, downScale: CGFloat, worldViewRect: CGRect) {
        if !route.routePoints.isEmpty{
            var drawPoints = Array<CGPoint>()
            for idx in 0..<route.routePoints.count{
                let routePoint = route.routePoints[idx]
                let mapPoint = CGPoint(routePoint.coordinate)
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
            ctx.setLineWidth(2.0)
            ctx.drawPath(using: .stroke)
        }
    }
    
#elseif os(iOS)
    
    @discardableResult
    static func createPreview(item: RouteItem) -> OSImage?{
        if let preview = createImage(route: item.route, size: CGSize(width: RouteItem.previewSize, height: RouteItem.previewSize)){
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
    
    static func createImage(route: Route, size: CGSize, withPoints: Bool = false) -> UIImage?{
        if route.routePoints.isEmpty{
            return nil
        }
        let boundingRouteRect = route.routePoints.boundingMapRect!
        let zoom = World.getZoomToFit(worldRect: boundingRouteRect, scaledSize: size)
        let downScale = World.downScale(to: zoom)
        let centerCoordinate = boundingRouteRect.centerCoordinate
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
            drawRoute(route: route, ctx: ctx.cgContext, size: size, zoom: zoom, downScale: downScale, worldViewRect: worldViewRect, withPoints: withPoints)
        }
        return img
    }
    
    static func drawRoute(route: Route, ctx: CGContext, size: CGSize, zoom: Int, downScale: CGFloat, worldViewRect: CGRect, withPoints: Bool = false) {
        if !route.routePoints.isEmpty{
            var drawPoints = Array<CGPoint>()
            for idx in 0..<route.routePoints.count{
                let routePoint = route.routePoints[idx]
                let mapPoint = CGPoint(routePoint.coordinate)
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
            ctx.setLineWidth(2.0)
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

