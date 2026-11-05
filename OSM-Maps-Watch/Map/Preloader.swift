/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers
import OSLog

enum PreloaderStatus{
    case idle
    case downloading
}

@Observable class MapPreloader{
    
    static var maxDownloadTiles = 5000
    static var defaultMaxPreloadZoom : Int = 8
    
    // state
    
    var status: PreloaderStatus = .idle
    
    // map
    
    var tileRegion = TileRegion()
    
    private var tileDownloadQueue : OperationQueue?
    
    var allPreloadTiles = 0
    var existingTiles = 0
    var preloadErrors = 0
    
    // tiles
    
    func setTileRegion(_ tileRegion: TileRegion){
        self.tileRegion = tileRegion
        allPreloadTiles = tileRegion.size
        existingTiles = tileRegion.tiles.checkExistingTiles(tileSource: Settings.shared.tileSource)
        switch status{
        case .downloading:
            cancelDownload()
        default:
            break
        }
        status = .idle
    }
    
    func startDownload() -> Bool{
        if status != .idle{
            return false
        }
        preloadErrors = 0
        tileDownloadQueue = OperationQueue()
        tileDownloadQueue!.name = "downloadQueue"
        tileDownloadQueue!.maxConcurrentOperationCount = 2
        let tiles = tileRegion.tiles
        status = .downloading
        for z in 0..<tiles.grids.count{
            let grid = tileRegion.tiles.grids[z]
            for y in 0..<grid.count{
                let line = grid[y]
                for x in 0..<line.count{
                    let tile = tiles.grids[z][y][x]
                    if !tile.present{
                        let operation = TileDownloadOperation(tile: MapTile(zoom: tile.zoom, x: tile.x, y: tile.y, tileSource: Settings.shared.tileSource))
                        operation.delegate = self
                        tileDownloadQueue!.addOperation(operation)
                    }
                }
            }
        }
        return true
    }
    
    func cancelDownload(){
        tileDownloadQueue?.cancelAllOperations()
        existingTiles = tileRegion.tiles.checkExistingTiles(tileSource: Settings.shared.tileSource)
        status = .idle
    }
    
}

extension MapPreloader: DownloadDelegate{
    
    func downloadSucceeded() {
        existingTiles += 1
    }
    
    func downloadWithError() {
        preloadErrors += 1
    }
    
}




    

