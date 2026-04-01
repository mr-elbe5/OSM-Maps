/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

class DrawTileData: Identifiable{
    
    var id: UUID = UUID()
    var drawRect: CGRect
    var tile: MapTile
    var complete = false
    
    var image: OSImage?{
        if let imageData = tile.imageData{
            return OSImage(data: imageData)
        }
        return nil
    }
    
    init(drawRect: CGRect, tile: MapTile){
        self.drawRect = drawRect
        self.tile = tile
    }
    
    func assertTileImage(){
        if tile.imageData == nil {
            TileProvider.shared.loadTileImage(tile: tile){ success in
                if success{
                    self.complete = true
                }
            }
        }
        else{
            complete = true
        }
    }
    
    func draw(){
        if let imageData = tile.imageData, let image = OSImage(data: imageData){
            image.draw(in: drawRect)
        }
    }
    
}

typealias DrawTileList = Array<DrawTileData>

extension DrawTileList{
    
    static func getDrawTiles(size: CGSize, zoom: Int, downScale: CGFloat, scaledWorldViewRect: CGRect) -> DrawTileList{
        let tileExtent = World.tileExtent
        let minTileX = Int(floor(scaledWorldViewRect.minX/tileExtent))
        let minTileY = Int(floor(scaledWorldViewRect.minY/tileExtent))
        let maxTileX = minTileX + Int(size.width/tileExtent) + 1
        let maxTileY = minTileY + Int(size.height/tileExtent) + 1
        var drawTileList = DrawTileList()
        var drawRect = CGRect()
        for x in minTileX...maxTileX{
            for y in Int(minTileY)...maxTileY{
                drawRect = CGRect(x: Double(x)*tileExtent - scaledWorldViewRect.minX, y: Double(y)*tileExtent - scaledWorldViewRect.minY, width: tileExtent, height: tileExtent)
                let tile = MapTile(zoom: zoom, x: x, y: y, tileSource: Settings.shared.tileSource)
                TileProvider.shared.getTileImage(tile: tile){ success in
                    if !success{
                        Log.error("loading tile failed")
                    }
                }
                drawTileList.append(DrawTileData(drawRect: drawRect, tile: tile))
            }
        }
        return drawTileList
    }
    
    var complete: Bool{
        for drawTile in self{
            if !drawTile.complete{
                return false
            }
        }
        return true
    }
    
    func assertDrawTileImages() -> Bool{
        for drawTile in self{
            drawTile.assertTileImage()
        }
        return complete
    }
    
    func draw(){
        for drawTile in self{
            drawTile.draw()
        }
    }
    
}
