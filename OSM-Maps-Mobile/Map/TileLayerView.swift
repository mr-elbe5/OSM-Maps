/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class TileLayerView: UIView {
    
    var mapGearImage = UIImage(named: "gear.grey")
    
    var pointToPixelsFactor : CGFloat = 1.0
    
    var upScale : CGFloat = 0.0
    var zoom : Int = 0
    
    override init(frame: CGRect){
        super.init(frame: frame)
        pointToPixelsFactor = tileLayer.contentsScale
        tileLayer.tileSize = CGSize(width: Double(World.tileExtent)*pointToPixelsFactor, height: Double(World.tileExtent)*pointToPixelsFactor)
        tileLayer.levelsOfDetail = World.maxZoom
        tileLayer.levelsOfDetailBias = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var layerClass: AnyClass {
        return CATiledLayer.self
    }
    
    var tileLayer: CATiledLayer {
        return self.layer as! CATiledLayer
    }
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()!
        upScale = 1.0/ctx.ctm.a*pointToPixelsFactor
        zoom = World.maxZoom - World.zoomLevelAtUpScale(scale: upScale)
        let tile = MapTile.getTile(data: getTileData(rect: rect), tileSource: Settings.shared.tileSource)
        drawTile(tile, rect: rect)
        if Settings.shared.hasOverlay, Settings.shared.showOverlay, let overlaySource = Settings.shared.overlayTileSource{
            let overlayTile = MapTile.getTile(data: getTileData(rect: rect), tileSource: overlaySource)
            drawTile(overlayTile, rect: rect, asOverlay: true)
        }
    }
    
    private func getTileData(rect: CGRect) -> MapTileData{
        var x = Int(round(rect.minX / upScale / Double(World.tileSize.width)))
        let currentMaxTiles = Int(World.zoomFactor(at: zoom))
        // for infinite scroll
        while x >= currentMaxTiles{
            x -= currentMaxTiles
        }
        let y = Int(round(rect.minY / upScale / Double(World.tileSize.height)))
        return MapTileData(zoom: zoom, x: x, y: y, tileSource: Settings.shared.tileSource)
    }
    
    // rect is in contentSize = planetSize
    func drawTile(_ tile: MapTile, rect: CGRect, asOverlay: Bool = false){
        if let imageData = tile.imageData, let image = UIImage(data: imageData){
            //Log.debug("drawing tile \(tile.shortDescription)")
            image.draw(in: rect)
            return
        }
        if !asOverlay{
            mapGearImage?.draw(in: rect.scaleCenteredBy(0.25))
        }
        TileProvider.shared.getTileImage(tile: tile){ success in
            //Log.debug("refresh tile \(tile.shortDescription) \(success)")
            if success{
                DispatchQueue.main.async {
                    self.setNeedsDisplay(rect)
                }
            }
            else{
                Log.error("TileLayerView could not load tile \(tile.shortDescription)")
            }
        }
    }
    
    func refresh(){
        tileLayer.setNeedsDisplay()
    }
    
}



