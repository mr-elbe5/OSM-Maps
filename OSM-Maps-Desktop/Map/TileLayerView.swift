/*
 OSM Maps (Mac)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import OSLog

protocol TileLayerDelegate{
    func mouseDragged(dx: CGFloat, dy: CGFloat)
}

class TileLayerView: NSView {
    
    var mapGearImage = NSImage(named: "gear.grey")
    
    var pointToPixelsFactor : CGFloat = 1.0
    
    var delegate: TileLayerDelegate? = nil
    
    override var isFlipped: Bool{
        return true
    }
    
    override init(frame: NSRect){
        super.init(frame: frame)
        wantsLayer = true
        layer?.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func makeBackingLayer() -> CALayer {
        let layer = CATiledLayer()
        pointToPixelsFactor = layer.contentsScale
        layer.tileSize = CGSize(width: World.tileExtent*pointToPixelsFactor, height: World.tileExtent*pointToPixelsFactor)
        layer.levelsOfDetail = World.maxZoom
        layer.levelsOfDetailBias = 0
        return layer
    }
    
    override func draw(_ rect: CGRect) {
        let tile = MapTile.getTile(data: getTileData(rect: rect), tileSource: Settings.shared.tileSource)
        drawTile(tile, rect: rect)
        if Settings.shared.hasOverlay, Settings.shared.showOverlay, let overlaySource = Settings.shared.overlayTileSource{
            let overlayTile = MapTile.getTile(data: getTileData(rect: rect), tileSource: overlaySource)
            drawTile(overlayTile, rect: rect, asOverlay: true)
        }
    }
    
    private func getTileData(rect: CGRect) -> MapTileData{
        let x = Int(round(rect.minX / World.tileExtent))
        let y = Int(round(rect.minY / World.tileExtent))
        return MapTileData(zoom: MapStatus.shared.zoom, x: x, y: y, tileSource: Settings.shared.tileSource)
    }
    
    // rect is in contentSize = planetSize
    func drawTile(_ tile: MapTile, rect: CGRect, asOverlay: Bool = false){
        if let imageData = tile.imageData, let image = NSImage(data: imageData){
            image.draw(in: rect)
            return
        }
        if !asOverlay{
            mapGearImage?.draw(in: rect.scaleCenteredBy(0.25))
        }
        TileProvider.shared.getTileImage(tile: tile){ success in
            //Logger.debug("refresh tile \(tile.shortDescription) \(success)")
            if success{
                DispatchQueue.main.async {
                    self.layer?.setNeedsDisplay(rect)
                }
            }
            else{
                Logger.error("TileLayerView could not load tile \(tile.shortDescription)")
            }
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        if event.type == .leftMouseDragged{
            delegate?.mouseDragged(dx: event.deltaX, dy: event.deltaY)
        }
    }
    
    func refresh(){
        layer?.setNeedsDisplay()
    }
    
}



