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
        let tile = MapTile.getTile(data: getTileData(rect: rect))
        drawTile(tile, rect: rect)
        if Settings.shared.hasOverlay{
            drawOverlayTile(tile, rect: rect)
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
        return MapTileData(zoom: zoom, x: x, y: y)
    }
    
    // rect is in contentSize = planetSize
    func drawTile(_ tile: MapTile, rect: CGRect){
        if let imageData = tile.imageData, let image = UIImage(data: imageData){
            image.draw(in: rect)
            return
        }
        mapGearImage?.draw(in: rect.scaleCenteredBy(0.25))
        TileProvider.shared.getTileImage(tile: tile){ success in
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
    
    // rect is in contentSize = planetSize
    func drawOverlayTile(_ tile: MapTile, rect: CGRect){
        if let overlayImageData = tile.overlayImageData, let overlayImage = UIImage(data: overlayImageData){
            overlayImage.draw(in: rect)
            return
        }
        TileProvider.shared.getTileOverlayImage(tile: tile){ success in
            if success{
                DispatchQueue.main.async {
                    self.setNeedsDisplay(rect)
                }
            }
            else{
                Log.error("TileLayerView could not load overlay tile \(tile.shortDescription)")
            }
        }
    }
    
    func refresh(){
        tileLayer.setNeedsDisplay()
    }
    
}



