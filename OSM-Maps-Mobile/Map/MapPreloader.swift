/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers
import OSLog

protocol PreloaderDelegate{
    func updateValueViews()
    func updateSliderValue(_ value: Float)
    func enableDownload(_ flag: Bool)
    func enableUpload(_ flag: Bool)
    func enableZoomControls(_ flag: Bool)
    func downloadFinished()
    func updateWatchValueViews()
    func updateWatchSliderValue(_ value: Float)
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
        reset()
        self.tileRegion = tileRegion
        tileRegion.updateTileSets()
        allPreloadTiles = tileRegion.size
        if allPreloadTiles > MapPreloader.maxDownloadTiles{
            self.tileRegion = TileRegion()
            reset()
            return false
        }
        existingTiles = tileRegion.tiles.checkExistingTiles(tileSource: Settings.shared.tileSource)
        delegate?.updateValueViews()
        delegate?.updateSliderValue(sliderValue)
        delegate?.enableDownload(tileRegion.size > 0)
        delegate?.enableUpload(existingTiles == allPreloadTiles)
        return true
    }
    
    func startDownload(){
        if tileRegion.size == 0{
            return
        }
        if preloadErrors > 0{
            preloadErrors = 0
            delegate?.updateValueViews()
            delegate?.updateSliderValue(sliderValue)
        }
        delegate?.enableDownload(false)
        delegate?.enableUpload(false)
        delegate?.enableZoomControls(false)
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
        delegate?.updateValueViews()
        delegate?.updateSliderValue(sliderValue)
        delegate?.enableDownload(true)
        delegate?.enableUpload(true)
        delegate?.enableZoomControls(true)
    }
    
    // watch
    
    func prepareUpload(){
        uploadPrepared = false
        watchTileRegion = tileRegion.getCopy(maxZoom: min(tileRegion.maxZoom, maxPreloadZoom), complete: true)
        if WatchConnector.shared.isWatchConnected{
            WatchConnector.shared.checkTiles(watchTileRegion.tiles){ region in
                if let region = region{
                    self.existingWatchTiles = region.getExistingTiles()
                    self.delegate?.updateWatchValueViews()
                    self.delegate?.updateWatchSliderValue(self.watchSliderValue)
                    self.uploadPrepared = true
                }
            }
        }
    }
    
    func startWatchUpload() -> Bool{
        if WatchConnector.shared.isWatchConnected, uploadPrepared{
            delegate?.enableUpload(false)
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
        reset()
        delegate?.enableDownload(true)
        delegate?.enableUpload(true)
        delegate?.enableZoomControls(true)
    }
    
}

extension MapPreloader: DownloadDelegate{
    
    func downloadSucceeded() {
        existingTiles += 1
        if existingTiles > allPreloadTiles{
            existingTiles = allPreloadTiles
        }
        delegate?.updateValueViews()
        delegate?.updateSliderValue(sliderValue)
        checkCompletion()
    }
    
    func downloadWithError() {
        preloadErrors += 1
        delegate?.updateValueViews()
        delegate?.updateSliderValue(sliderValue)
        checkCompletion()
    }
    
    private func checkCompletion(){
        if existingTiles + preloadErrors >= allPreloadTiles{
            delegate?.enableZoomControls(true)
            delegate?.enableUpload(existingTiles == allPreloadTiles)
            tileDownloadQueue?.cancelAllOperations()
            tileDownloadQueue = nil
            delegate?.downloadFinished()
        }
    }
    
}

extension MapPreloader: UploadDelegate{
    
    func uploadSucceeded() {
        existingWatchTiles += 1
        delegate?.updateWatchValueViews()
        delegate?.updateWatchSliderValue(watchSliderValue)
        checkWatchCompletion()
    }
    
    func uploadWithError() {
        uploadErrors += 1
        delegate?.updateWatchValueViews()
        delegate?.updateWatchSliderValue(watchSliderValue)
        checkWatchCompletion()
    }
    
    private func checkWatchCompletion(){
        if existingWatchTiles + uploadErrors == watchTileRegion.size{
            delegate?.enableUpload(true)
            tileUploadQueue?.cancelAllOperations()
            tileUploadQueue = nil
        }
    }
    
}




    

