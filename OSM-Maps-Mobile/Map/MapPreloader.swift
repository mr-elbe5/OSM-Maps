/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation

class MapPreloader {
    
    static var maxDownloadTiles = 5000
    
    var maxZoom: Int = 16
    var allTiles = 0
    var existingTiles = 0
    var downloadErrors = 0
    var downloadProgress: Double = 0
    
    var allWatchTiles = 0
    var existingWatchTiles = 0
    var uploadedTiles: Int = 0
    var uploadErrors: Int = 0
    var uploadProgress: Double = 0
    
    var showSpinner = false
    var showPreloadOk: Bool = false
    
    var downloadQueue: OperationQueue? = nil
    var uploadQueue: OperationQueue? = nil
    
    private var coordinateRegion: CoordinateRegion? = nil
    private var tileSets = Dictionary<Int, TileSet>()
    private var tiles = MapTileList()
    private var watchTiles = MapTileList()
    
    func reset(){
        allTiles = 0
        existingTiles = 0
        downloadErrors = 0
    }
    
    func resetWatch(){
        allWatchTiles = 0
        existingWatchTiles = 0
        uploadErrors = 0
    }
    
    @discardableResult
    func update(coordinareRegion: CoordinateRegion) -> Bool{
        self.coordinateRegion = coordinareRegion
        return update()
    }
    
    @discardableResult
    func update() -> Bool{
        reset()
        if let coordinateRegion = self.coordinateRegion{
            tiles.removeAll()
            var tileSets = Dictionary<Int, TileSet>()
            for zoom in World.minZoom...maxZoom{
                let tileSet = TileSet()
                tileSet.minX = World.tileX(coordinateRegion.minLongitude, withZoom: zoom)
                tileSet.maxX = World.tileX(coordinateRegion.maxLongitude, withZoom: zoom)
                tileSet.minY = World.tileY(coordinateRegion.maxLatitude, withZoom: zoom)
                tileSet.maxY = World.tileY(coordinateRegion.minLatitude, withZoom: zoom)
                //Log.debug("tiles at \(zoom): \(tileSet.size) from \(tileSet.minX),\(tileSet.minY) to \(tileSet.maxX),\(tileSet.maxY)")
                tileSets[zoom] = tileSet
                allTiles += tileSet.size
            }
            if allTiles > Self.maxDownloadTiles{
                Log.info("too many tiles")
                return false
            }
            for zoom in tileSets.keys{
                guard let tileSet = tileSets[zoom] else { continue }
                for x in tileSet.minX...tileSet.maxX{
                    for y in tileSet.minY...tileSet.maxY{
                        let tile = MapTile(zoom: zoom, x: x, y: y)
                        if tile.fileExists{
                            existingTiles += 1
                            continue
                        }
                        tiles.append(tile)
                    }
                }
            }
            return true
        }
        return false
    }
    
    func startDownload(){
        if tiles.isEmpty{
            return
        }
        if downloadErrors > 0{
            downloadErrors = 0
        }
        showSpinner = true
        downloadQueue = OperationQueue()
        downloadQueue!.name = "downloadQueue"
        downloadQueue!.maxConcurrentOperationCount = 2
        tiles.forEach { tile in
            let operation = TileDownloadOperation(tile: tile)
            operation.delegate = self
            downloadQueue!.addOperation(operation)
        }
    }
    
    func cancelDownload(){
        downloadQueue?.cancelAllOperations()
        reset()
        update()
    }
    
    func startWatchTileCheck(){
        checkWatchTiles()
    }
    
    @discardableResult
    func checkWatchTiles() -> Bool{
        resetWatch()
        var tileList = MapTileDataList()
        if let coordinateRegion = self.coordinateRegion{
            watchTiles.removeAll()
            var tileSets = Dictionary<Int, TileSet>()
            for zoom in World.minZoom...maxZoom{
                let tileSet = TileSet()
                tileSet.minX = World.tileX(coordinateRegion.minLongitude, withZoom: zoom)
                tileSet.maxX = World.tileX(coordinateRegion.maxLongitude, withZoom: zoom)
                tileSet.minY = World.tileY(coordinateRegion.maxLatitude, withZoom: zoom)
                tileSet.maxY = World.tileY(coordinateRegion.minLatitude, withZoom: zoom)
                //Log.debug("tiles at \(zoom): \(tileSet.size) from \(tileSet.minX),\(tileSet.minY) to \(tileSet.maxX),\(tileSet.maxY)")
                tileSets[zoom] = tileSet
                allWatchTiles += tileSet.size
            }
            if allWatchTiles > Self.maxDownloadTiles{
                Log.info("too many tiles")
                return false
            }
            for zoom in tileSets.keys{
                guard let tileSet = tileSets[zoom] else { continue }
                for x in tileSet.minX...tileSet.maxX{
                    for y in tileSet.minY...tileSet.maxY{
                        let tile = MapTileData(zoom: zoom, x: x, y: y)
                        tileList.append(tile)
                    }
                }
            }
            WatchConnector.shared.checkTiles(tileList){ list in
                if let missingTiles = list{
                    for tileData in missingTiles{
                        self.watchTiles.append(MapTile(zoom: tileData.zoom, x: tileData.x, y: tileData.y))
                    }
                }
                self.existingWatchTiles = self.allWatchTiles - self.watchTiles.count
                Log.info("watch tiles missing: \(self.watchTiles.count)")
            }
            return true
        }
        return false
    }
    
    func startWatchUpload(){
        if watchTiles.isEmpty{
            return
        }
        if WatchConnector.shared.isWatchConnected{
            uploadedTiles = 0
            uploadErrors = 0
            uploadQueue = OperationQueue()
            uploadQueue!.name = "uploadQueue"
            uploadQueue!.maxConcurrentOperationCount = 1
            Log.info("uploading \(watchTiles.count) tiles")
            watchTiles.forEach { tile in
                if let data = FileManager.default.readFile(url: tile.fileUrl){
                    let operation = TileUploadOperation(tile: tile, data:data)
                    operation.delegate = self
                    uploadQueue!.addOperation(operation)
                }
                else{
                    uploadWithError()
                }
            }
            Log.info("watch upload started")
        }
    }
    
    func cancelWatchUpload(){
        uploadQueue?.cancelAllOperations()
        Log.info("watch upload canceled")
        reset()
    }
    
    private class TileSet{
        
        var minX = 0
        var minY = 0
        var maxX = 0
        var maxY = 0
        
        init(){
        }
        
        var size : Int{
            (maxX - minX + 1) * (maxY - minY + 1)
        }
        
    }
    
}

extension MapPreloader: DownloadDelegate{
    
    func downloadSucceeded() {
        existingTiles += 1
        if existingTiles > allTiles{
            existingTiles = allTiles
        }
        if allTiles != 0{
            downloadProgress = Double(existingTiles + downloadErrors) / Double(allTiles)
        }
        checkCompletion()
    }
    
    func downloadWithError() {
        downloadErrors += 1
        if allTiles != 0{
            downloadProgress = Double(existingTiles + downloadErrors) / Double(allTiles)
        }
        checkCompletion()
    }
    
    private func checkCompletion(){
        if existingTiles + downloadErrors >= allTiles{
            downloadQueue?.cancelAllOperations()
            downloadQueue = nil
        }
    }
    
}

extension MapPreloader: UploadDelegate{
    
    func uploadSucceeded() {
        uploadedTiles += 1
        existingWatchTiles += 1
        if watchTiles.count != 0{
            uploadProgress = Double(uploadedTiles + uploadErrors)/Double(watchTiles.count)
        }
        checkWatchCompletion()
    }
    
    func uploadWithError() {
        uploadErrors += 1
        if watchTiles.count != 0{
            uploadProgress = Double(uploadedTiles + uploadErrors)/Double(watchTiles.count)
        }
        checkWatchCompletion()
    }
    
    private func checkWatchCompletion(){
        if uploadedTiles + uploadErrors == watchTiles.count{
            uploadQueue?.cancelAllOperations()
            uploadQueue = nil
        }
    }
    
}


