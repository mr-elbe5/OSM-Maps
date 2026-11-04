/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers
import OSLog

protocol PreloaderDelegate{
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

enum PreloaderStatus{
    case idle
    case downloading
    case uploading
}

class MapPreloader{
    
    static var maxDownloadTiles = 5000
    static var defaultMaxPreloadZoom : Int = 8
    
    var delegate: PreloaderDelegate? = nil
    
    // state
    
    var status: PreloaderStatus = .idle
    var uploadPrepared = false
    
    // map
    
    var tileRegion = TileRegion()
    
    var tileDownloadQueue : OperationQueue?
    var tileUploadQueue : OperationQueue?
    
    var allPreloadTiles = 0
    var existingTiles = 0
    var preloadErrors = 0
    
    var maxPreloadZoomControl = UISegmentedControl()
    
    // watch upload
    
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
    
    func setTileRegion(_ tileRegion: TileRegion){
        self.tileRegion = tileRegion
        allPreloadTiles = tileRegion.size
        existingTiles = tileRegion.tiles.checkExistingTiles(tileSource: Settings.shared.tileSource)
        switch status{
        case .downloading:
            cancelDownload()
        case .uploading:
            cancelWatchUpload()
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
        uploadPrepared = false
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
    
    // watch
    
    func prepareUpload(success: @escaping (Bool) -> Void){
        if status != .idle{
            return success(false)
        }
        watchTileRegion = tileRegion.getCopy(minZoom: tileRegion.minZoom, maxZoom: tileRegion.maxZoom)
        if WatchConnector.shared.isWatchConnected{
            WatchConnector.shared.prepareTileUpload(watchTileRegion.tiles){ tiles in
                if let tiles = tiles{
                    self.watchTileRegion.tiles = tiles
                    self.existingWatchTiles = tiles.getExistingTiles()
                    self.uploadPrepared = true
                    self.delegate?.uploadPrepared()
                    success(true)
                }
                else{
                    self.uploadPrepared = false
                    success(false)
                }
            }
        }
        else{
            success(false)
        }
    }
    
    func startWatchUpload() -> Bool{
        if status != .idle || !uploadPrepared{
            return false
        }
        if WatchConnector.shared.isWatchConnected{
            status = .uploading
            delegate?.uploadStarted()
            uploadErrors = 0
            tileUploadQueue = OperationQueue()
            tileUploadQueue!.name = "uploadQueue"
            tileUploadQueue!.maxConcurrentOperationCount = 1
            for tileGrid in watchTileRegion.tiles.grids{
                for tileLine in tileGrid{
                    for tile in tileLine{
                        if tile.present{
                            continue
                        }
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
        checkDownloadComplete()
    }
    
    func downloadWithError() {
        preloadErrors += 1
        delegate?.downloadWithError()
        checkDownloadComplete()
    }
    
    private func checkDownloadComplete(){
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
        checkUploadComplete()
    }
    
    func uploadWithError() {
        uploadErrors += 1
        delegate?.uploadWithError()
        checkUploadComplete()
    }
    
    private func checkUploadComplete(){
        if existingWatchTiles + uploadErrors == watchTileRegion.size{
            tileUploadQueue?.cancelAllOperations()
            tileUploadQueue = nil
            delegate?.uploadCompleted()
        }
    }
    
}




    

