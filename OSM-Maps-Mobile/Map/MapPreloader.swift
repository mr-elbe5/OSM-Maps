/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers
import OSLog

protocol PreloaderDelegate{
    func tileRegionReady()
    func downloadStarted()
    func downloadCanceled()
    func downloadSucceeded()
    func downloadWithError()
    func downloadCompleted()
    func uploadPrepared()
    func uploadStarted()
    func uploadCanceled()
    func uploadSucceeded()
    func uploadWithError()
    func uploadCompleted()
}

class MapPreloader{
    
    static var maxDownloadTiles = 5000
    
    var delegate: PreloaderDelegate? = nil
    
    // map
    
    var tileRegion = TileRegion()
    
    var tileDownloadQueue : OperationQueue?
    var tileUploadQueue : OperationQueue?
    
    var allPreloadTiles = 0
    var existingTiles = 0
    var preloadErrors = 0
    
    var maxPreloadZoomControl = UISegmentedControl()
    
    var maxPreloadZoom : Int = 16
    
    // watch upload
    
    var uploadPrepared = false
    var existingWatchTiles = 0
    var uploadErrors = 0
    
    var uploadableWatchTiles: Int{
        allPreloadTiles - existingWatchTiles
    }
    
    var watchTileRegion = TileRegion()
    
    var sliderValue: Float{
        Float(existingTiles + preloadErrors)/Float(allPreloadTiles)
    }
    
    var watchSliderValue: Float{
        Float(Float(existingWatchTiles + uploadErrors)/Float(watchTileRegion.size))
    }
    
    // tiles
    
    func reset(){
        allPreloadTiles = 0
        existingTiles = 0
        preloadErrors = 0
    }
    
    func setTileRegion(_ tileRegion: TileRegion) -> Bool{
        tileRegion.updateTileSets()
        if tileRegion.size > MapPreloader.maxDownloadTiles{
            return false
        }
        self.tileRegion = tileRegion
        allPreloadTiles = tileRegion.size
        existingTiles = tileRegion.tiles.checkExistingTiles(tileSource: Settings.shared.tileSource)
        delegate?.tileRegionReady()
        return true
    }
    
    func startDownload(){
        if tileRegion.size == 0{
            return
        }
        preloadErrors = 0
        delegate?.downloadStarted()
        tileDownloadQueue = OperationQueue()
        tileDownloadQueue!.name = "downloadQueue"
        tileDownloadQueue!.maxConcurrentOperationCount = 2
        let tiles = tileRegion.tiles
        for z in 0..<tiles.grids.count{
            let grid = tileRegion.tiles.grids[z]
            for y in 0..<grid.count{
                let line = grid[y]
                for x in 0..<line.count{
                    let tile = tiles.grids[z][y][x]
                    if !tile.flag{
                        let operation = TileDownloadOperation(tile: MapTile(zoom: tile.zoom, x: tile.x, y: tile.y, tileSource: Settings.shared.tileSource))
                        operation.delegate = self
                        tileDownloadQueue!.addOperation(operation)
                    }
                }
            }
        }
    }
    
    func cancelDownload(){
        tileDownloadQueue?.cancelAllOperations()
        reset()
        existingTiles = tileRegion.tiles.checkExistingTiles(tileSource: Settings.shared.tileSource)
        delegate?.downloadCanceled()
    }
    
    // watch
    
    func prepareUpload(){
        uploadPrepared = false
        watchTileRegion = tileRegion.getCopy(maxZoom: min(tileRegion.maxZoom, maxPreloadZoom), complete: true)
        if WatchConnector.shared.isWatchConnected{
            WatchConnector.shared.checkTiles(watchTileRegion.tiles){ region in
                if let region = region{
                    self.existingWatchTiles = region.getExistingTiles()
                    self.uploadPrepared = true
                    self.delegate?.uploadPrepared()
                }
            }
        }
    }
    
    func startWatchUpload() -> Bool{
        if WatchConnector.shared.isWatchConnected, uploadPrepared{
            delegate?.uploadStarted()
            uploadErrors = 0
            tileUploadQueue = OperationQueue()
            tileUploadQueue!.name = "uploadQueue"
            tileUploadQueue!.maxConcurrentOperationCount = 1
            for tileGrid in watchTileRegion.tiles.grids{
                for tileLine in tileGrid{
                    for tile in tileLine{
                        if let data = FileManager.default.readFile(url: tile.fileUrl(tileSource: Settings.shared.tileSource)){
                            let operation = TileUploadOperation(tile: MapTile(zoom: tile.zoom, x: tile.x, y: tile.y, tileSource: Settings.shared.tileSource), data:data)
                            operation.delegate = self
                            tileUploadQueue!.addOperation(operation)
                        }
                    }
                }
            }
            return true
        }
        else{
            return false
        }
    }
    
    func cancelWatchUpload(){
        tileUploadQueue?.cancelAllOperations()
        reset()
        delegate?.uploadCanceled()
    }
    
}

extension MapPreloader: DownloadDelegate{
    
    func downloadSucceeded() {
        existingTiles += 1
        if existingTiles > allPreloadTiles{
            existingTiles = allPreloadTiles
        }
        delegate?.downloadSucceeded()
        checkCompletion()
    }
    
    func downloadWithError() {
        preloadErrors += 1
        delegate?.downloadWithError()
        checkCompletion()
    }
    
    private func checkCompletion(){
        if existingTiles + preloadErrors >= allPreloadTiles{
            tileDownloadQueue?.cancelAllOperations()
            tileDownloadQueue = nil
            delegate?.downloadCompleted()
        }
    }
    
}

extension MapPreloader: UploadDelegate{
    
    func uploadSucceeded() {
        existingWatchTiles += 1
        delegate?.uploadSucceeded()
        checkWatchCompletion()
    }
    
    func uploadWithError() {
        uploadErrors += 1
        delegate?.uploadWithError()
        checkWatchCompletion()
    }
    
    private func checkWatchCompletion(){
        if existingWatchTiles + uploadErrors == watchTileRegion.size{
            tileUploadQueue?.cancelAllOperations()
            tileUploadQueue = nil
            delegate?.uploadCompleted()
        }
    }
    
}




    

