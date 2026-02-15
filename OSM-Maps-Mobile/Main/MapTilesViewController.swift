/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers

class MapTilesViewController: ScrollViewController{
    
    static var maxDownloadTiles = 5000
    
    // map
    
    var mapRegion: TileRegion? = nil
    
    var tileDownloadQueue : OperationQueue?
    var tileUploadQueue : OperationQueue?
    
    var allPreloadTiles = 0
    var existingTiles = 0
    var preloadErrors = 0
    
    var regionTiles = [MapTile]()
    
    var maxPreloadZoomControl = UISegmentedControl()
    
    var maxPreloadZoom : Int = 16
    
    var calculateTilesButton = UIButton()
    
    var allTilesValueLabel = UILabel()
    var existingTilesValueLabel = UILabel()
    var tilesToLoadValueLabel = UILabel()
    
    var startPreloadButton = UIButton()
    var cancelPreloadButton = UIButton()
    
    var preloadProgressView = UIProgressView()
    
    var preloadErrorsValueLabel = UILabel()
    
    // watch upload
    
    var uploadedTiles = 0
    var uploadErrors = 0
    
    var watchTiles = [MapTile]()
    
    var watchStatusLabel = UILabel(text: "disconnected".localize())
    var startWatchUploadButton = UIButton()
    var cancelWatchUploadButton = UIButton()
    
    var watchProgressView = UIProgressView()
    
    var uploadErrorsValueLabel = UILabel()
    
    // other settings
    
    var mapSourceControl = UISegmentedControl()
    
    override func loadView() {
        title = "preferences".localize()
        super.loadView()
        view.addSubviewFillingSafeArea(scrollView, insets: .zero)
        scrollView.backgroundColor = .systemBackground
        setupScrollView()
        loadScrollableSubviews()
        if existingTiles == allPreloadTiles{
            startPreloadButton.isEnabled = false
            cancelPreloadButton.isEnabled = false
        }
        else{
            startPreloadButton.isEnabled = true
            cancelPreloadButton.isEnabled = false
        }
        if !WatchConnector.shared.isWatchConnected{
            WatchConnector.shared.start()
            DispatchQueue.main.async {
                self.updateConnectionStatus()
            }
        }
    }
    
    func loadScrollableSubviews() {
        
        let segmentTitleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]
        
        let subheader = UILabel(subheader: "mapServer".localize())
        contentView.addSubviewBelow(subheader)
        
        mapSourceControl.insertSegment(action: UIAction(){ action in
            Preferences.shared.mapSource = .osm
        }, at: 0, animated: false)
        mapSourceControl.setTitle("osm".localize(), forSegmentAt: 0)
        mapSourceControl.insertSegment(action: UIAction(){ action in
            Preferences.shared.mapSource = .elbe5
        }, at: 1, animated: false)
        mapSourceControl.setTitle("elbe5".localize(), forSegmentAt: 1)
        mapSourceControl.insertSegment(action: UIAction(){ action in
            Preferences.shared.mapSource = .elbe5Topo
        }, at: 2, animated: false)
        mapSourceControl.setTitle("elbe5topo".localize(), forSegmentAt: 2)
        mapSourceControl.setTitleTextAttributes(segmentTitleAttributes, for: .normal)
        mapSourceControl.selectedSegmentIndex = MapSourceList.shared.indexOf(source: Preferences.shared.mapSource)
        contentView.addSubviewBelow(mapSourceControl, upperView: subheader)
        
        let hint = UILabel(hint: "mapServerHint".localize(table: "Hints"))
        contentView.addSubviewBelow(hint, upperView: mapSourceControl, insets: OSInsets.flatInsets)
        
        let clearTileCacheButton = UIButton(name: "clearMapCache".localize(), action: UIAction(){ action in
            self.deleteAllTiles()
        })
        contentView.addSubviewBelow(clearTileCacheButton, upperView: hint)
        
        let header = UILabel(header: "mapTiles".localize())
        contentView.addSubviewBelow(header, upperView: clearTileCacheButton)
        
        let note = UILabel(hint: "mapPreloadNote".localize(table: "Hints"))
        note.numberOfLines = 0
        note.lineBreakMode = .byWordWrapping
        contentView.addSubviewBelow(note, upperView: header)
        
        let sourceLabel = UILabel()
        sourceLabel.numberOfLines = 0
        sourceLabel.text = "\("currentServer".localize()): \(Preferences.shared.mapSource.rawValue.localize())"
        contentView.addSubviewBelow(sourceLabel, upperView: note)
        
        let segSize = World.maxZoom - World.minZoom
        var label = UILabel(text: "maxZoom".localize())
        contentView.addSubviewBelow(label, upperView: sourceLabel)
        
        for i: Int in 0...segSize{
            maxPreloadZoomControl.insertSegment(action: UIAction(){ action in
                self.enableDownload(false)
                self.maxPreloadZoom = i + World.minZoom
                self.enableDownload(false)
            }, at: i, animated: false)
            maxPreloadZoomControl.setTitle(String(i + World.minZoom), forSegmentAt: i)
        }
        maxPreloadZoomControl.setTitleTextAttributes(segmentTitleAttributes, for: .normal)
        maxPreloadZoomControl.selectedSegmentIndex = maxPreloadZoom - World.minZoom
        contentView.addSubviewBelow(maxPreloadZoomControl, upperView: label)
        
        calculateTilesButton.setTitle("recalculateTiles".localize(), for: .normal)
        calculateTilesButton.setTitleColor(.systemBlue, for: .normal)
        calculateTilesButton.setTitleColor(.systemGray, for: .disabled)
        calculateTilesButton.addAction(UIAction(){ action in
            self.recalculateTiles()
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(calculateTilesButton, upperView: maxPreloadZoomControl)
        
        let allTilesLabel = UILabel()
        allTilesLabel.text = "allTilesForDownload".localize()
        contentView.addSubviewWithAnchors(allTilesLabel, top: calculateTilesButton.bottomAnchor, leading: contentView.leadingAnchor)
        contentView.addSubviewWithAnchors(allTilesValueLabel, top: calculateTilesButton.bottomAnchor, leading: allTilesLabel.trailingAnchor)
        
        let existingTilesLabel = UILabel()
        existingTilesLabel.text = "existingTiles".localize()
        contentView.addSubviewWithAnchors(existingTilesLabel, top: allTilesLabel.bottomAnchor, leading: contentView.leadingAnchor)
        contentView.addSubviewWithAnchors(existingTilesValueLabel, top: allTilesLabel.bottomAnchor, leading: existingTilesLabel.trailingAnchor)
        
        let tilesToLoadLabel = UILabel()
        tilesToLoadLabel.text = "tilesToLoad".localize()
        contentView.addSubviewWithAnchors(tilesToLoadLabel, top: existingTilesLabel.bottomAnchor, leading: contentView.leadingAnchor)
        contentView.addSubviewWithAnchors(tilesToLoadValueLabel, top: existingTilesLabel.bottomAnchor, leading: tilesToLoadLabel.trailingAnchor)
        
        startPreloadButton.setTitle("startPreload".localize(), for: .normal)
        startPreloadButton.setTitleColor(.systemBlue, for: .normal)
        startPreloadButton.setTitleColor(.systemGray, for: .disabled)
        startPreloadButton.addAction(UIAction(){ action in
            self.startDownload()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(startPreloadButton, top: tilesToLoadLabel.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.centerXAnchor)
        
        cancelPreloadButton.setTitle("cancel".localize(), for: .normal)
        cancelPreloadButton.setTitleColor(.systemBlue, for: .normal)
        cancelPreloadButton.setTitleColor(.systemGray, for: .disabled)
        cancelPreloadButton.addAction(UIAction(){ action in
            self.cancelDownload()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(cancelPreloadButton, top: tilesToLoadLabel.bottomAnchor, leading: contentView.centerXAnchor, trailing: contentView.trailingAnchor)
        
        let preloadProgressLabel = UILabel(hint: "progress".localizeWithColon())
        contentView.addSubviewBelow(preloadProgressLabel, upperView: startPreloadButton)
        preloadProgressView.progress = 0
        contentView.addSubviewWithAnchors(preloadProgressView, top: preloadProgressLabel.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: OSInsets.doubleInsets)
        
        var errorsInfo = UILabel()
        errorsInfo.text = "unloadedTiles".localize()
        contentView.addSubviewWithAnchors(errorsInfo, top: preloadProgressView.bottomAnchor, leading: contentView.leadingAnchor)
        preloadErrorsValueLabel.text = String(preloadErrors)
        contentView.addSubviewWithAnchors(preloadErrorsValueLabel, top: preloadProgressView.bottomAnchor, leading: errorsInfo.trailingAnchor)
        
        // watch
        
        let watchHeader = UILabel(header: "watchUploadArea".localize())
        contentView.addSubviewBelow(watchHeader, upperView: preloadErrorsValueLabel)
        
        let watchInfo = UILabel(hint: "watchUploadHint".localize(table: "Hints"))
        watchInfo.numberOfLines = 0
        contentView.addSubviewBelow(watchInfo, upperView: watchHeader)
        
        label = UILabel(text: "watchStatus".localizeWithColon())
        contentView.addSubviewWithAnchors(label, top: watchInfo.bottomAnchor, leading: contentView.leadingAnchor)
        contentView.addSubviewWithAnchors(watchStatusLabel, top: watchInfo.bottomAnchor, leading: label.trailingAnchor)
        
        startWatchUploadButton.setTitle("startWatchUpload".localize(), for: .normal)
        startWatchUploadButton.setTitleColor(.systemBlue, for: .normal)
        startWatchUploadButton.setTitleColor(.systemGray, for: .disabled)
        startWatchUploadButton.addAction(UIAction(){ action in
            self.startWatchUpload()
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(startWatchUploadButton, upperView: label)
        
        cancelWatchUploadButton.setTitle("cancel".localize(), for: .normal)
        cancelWatchUploadButton.setTitleColor(.systemBlue, for: .normal)
        cancelWatchUploadButton.setTitleColor(.systemGray, for: .disabled)
        cancelWatchUploadButton.addAction(UIAction(){ action in
            self.cancelWatchUpload()
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(cancelWatchUploadButton, upperView: startWatchUploadButton)
        
        let watchProgressLabel = UILabel(hint: "progress".localizeWithColon())
        contentView.addSubviewBelow(watchProgressLabel, upperView: cancelWatchUploadButton)
        watchProgressView.progress = 0
        contentView.addSubviewBelow(watchProgressView, upperView: watchProgressLabel)
        
        errorsInfo = UILabel()
        errorsInfo.text = "unloadedTiles".localize()
        contentView.addSubviewWithAnchors(errorsInfo, top: watchProgressView.bottomAnchor, leading: contentView.leadingAnchor)
        uploadErrorsValueLabel.text = String(uploadErrors)
        contentView.addSubviewWithAnchors(uploadErrorsValueLabel, top: watchProgressView.bottomAnchor, leading: errorsInfo.trailingAnchor)
            .connectToBottom(of: contentView)
        
        enableZoomControls(true)
        enableDownload(false)
        updateConnectionStatus()
        
    }
    
    func deleteAllTiles(){
        showDestructiveApprove(title: "deleteAllTiles".localize(), text: "deleteAllTilesHint".localize(table: "Hints")){
            TileProvider.shared.deleteAllTiles()
        }
    }
    
}

extension MapTilesViewController{
    
    // tiles
    
    func reset(){
        allPreloadTiles = 0
        existingTiles = 0
        preloadErrors = 0
    }
    
    func updateValueViews(){
        allTilesValueLabel.text = String(allPreloadTiles)
        existingTilesValueLabel.text = String(existingTiles)
        tilesToLoadValueLabel.text = String(allPreloadTiles - existingTiles)
        preloadErrorsValueLabel.text = String(preloadErrors)
    }
    
    func updateSliderValue(){
        if allPreloadTiles != 0{
            preloadProgressView.progress = Float(existingTiles + preloadErrors)/Float(allPreloadTiles)
        }
    }
    
    func recalculateTiles(){
        if mapRegion == nil{
            mapRegion = MainViewController.shared.mapView.scrollView.tileRegion
        }
        let spinner = startSpinner()
        regionTiles.removeAll()
        if let region = mapRegion{
            reset()
            for zoom in region.tiles.keys{
                if zoom > maxPreloadZoom{
                    continue
                }
                if let tileSet = region.tiles[zoom]{
                    for _ in tileSet.minX...tileSet.maxX{
                        for _ in tileSet.minY...tileSet.maxY{
                            allPreloadTiles += 1
                        }
                    }
                }
            }
            if allPreloadTiles > MapTilesViewController.maxDownloadTiles{
                updateValueViews()
                updateSliderValue()
                enableDownload(false)
                enableDownload(false)
                stopSpinner(spinner)
                showError("tooManyTiles".localize(param: String(MapTilesViewController.maxDownloadTiles)))
                return
            }
            for zoom in region.tiles.keys{
                if zoom > maxPreloadZoom{
                    continue
                }
                if let tileSet = region.tiles[zoom]{
                    for x in tileSet.minX...tileSet.maxX{
                        for y in tileSet.minY...tileSet.maxY{
                            let tile = MapTile(zoom: zoom, x: x, y: y)
                            if tile.exists{
                                existingTiles += 1
                                continue
                            }
                            regionTiles.append(tile)
                        }
                    }
                }
            }
        }
        updateValueViews()
        updateSliderValue()
        enableDownload(regionTiles.count > 0)
        enableUpload(existingTiles == allPreloadTiles)
        stopSpinner(spinner)
    }
    
    func startDownload(){
        if regionTiles.isEmpty{
            return
        }
        if preloadErrors > 0{
            preloadErrors = 0
            updateValueViews()
            updateSliderValue()
        }
        enableDownload(false)
        enableUpload(false)
        enableZoomControls(false)
        tileDownloadQueue = OperationQueue()
        tileDownloadQueue!.name = "downloadQueue"
        tileDownloadQueue!.maxConcurrentOperationCount = 2
        regionTiles.forEach { tile in
            let operation = TileDownloadOperation(tile: tile)
            operation.delegate = self
            tileDownloadQueue!.addOperation(operation)
        }
    }
    
    func cancelDownload(){
        tileDownloadQueue?.cancelAllOperations()
        reset()
        recalculateTiles()
        enableDownload(true)
        enableUpload(true)
        enableZoomControls(true)
    }

    func enableZoomControls(_ flag: Bool){
        maxPreloadZoomControl.isEnabled = flag
    }
    
    func enableDownload(_ flag: Bool){
        startPreloadButton.isEnabled = flag
        cancelPreloadButton.isEnabled = !flag
    }
    
    func downloadFinished(){
        startPreloadButton.isEnabled = true
        cancelPreloadButton.isEnabled = false
    }
    
    // watch
    
    func updateWatchValueViews(){
        uploadErrorsValueLabel.text = String(uploadErrors)
    }
    
    func updateWatchSliderValue(){
        if watchTiles.count != 0{
            watchProgressView.progress = Float(uploadedTiles + uploadErrors)/Float(watchTiles.count)
        }
    }
    
    func recalculateWatchTiles(){
        watchTiles.removeAll()
        if let region = mapRegion{
            reset()
            for zoom in region.tiles.keys{
                if zoom > maxPreloadZoom{
                    continue
                }
                if let tileSet = region.tiles[zoom]{
                    for x in tileSet.minX...tileSet.maxX{
                        for y in tileSet.minY...tileSet.maxY{
                            let tile = MapTile(zoom: zoom, x: x, y: y)
                            watchTiles.append(tile)
                        }
                    }
                }
            }
        }
    }
    
    func startWatchUpload(){
        if WatchConnector.shared.isWatchConnected{
            enableUpload(false)
            recalculateWatchTiles()
            uploadedTiles = 0
            uploadErrors = 0
            tileUploadQueue = OperationQueue()
            tileUploadQueue!.name = "uploadQueue"
            tileUploadQueue!.maxConcurrentOperationCount = 1
            Log.info("uploading \(watchTiles.count) tiles")
            watchTiles.forEach { tile in
                if let data = FileManager.default.readFile(url: tile.fileUrl){
                    let operation = TileUploadOperation(tile: tile, data:data)
                    operation.delegate = self
                    tileUploadQueue!.addOperation(operation)
                }
                else{
                    uploadWithError()
                }
            }
        }
    }
    
    func cancelWatchUpload(){
        tileUploadQueue?.cancelAllOperations()
        reset()
        recalculateWatchTiles()
        enableUpload(true)
    }
    
    func enableUpload(_ flag: Bool){
        startWatchUploadButton.isEnabled = flag
        cancelWatchUploadButton.isEnabled = !flag
    }
    
    func updateConnectionStatus(){
        watchStatusLabel.text = WatchConnector.shared.isWatchConnected ? "connected".localize() : "disconnected".localize()
        enableUpload(WatchConnector.shared.isWatchConnected)
    }
    
}

extension MapTilesViewController: DownloadDelegate{
    
    func downloadSucceeded() {
        existingTiles += 1
        if existingTiles > allPreloadTiles{
            existingTiles = allPreloadTiles
        }
        updateValueViews()
        updateSliderValue()
        checkCompletion()
    }
    
    func downloadWithError() {
        preloadErrors += 1
        updateValueViews()
        updateSliderValue()
        checkCompletion()
    }
    
    private func checkCompletion(){
        if existingTiles + preloadErrors >= allPreloadTiles{
            enableZoomControls(true)
            enableUpload(existingTiles == allPreloadTiles)
            tileDownloadQueue?.cancelAllOperations()
            tileDownloadQueue = nil
            downloadFinished()
        }
    }
    
}

extension MapTilesViewController: UploadDelegate{
    
    func uploadSucceeded() {
        uploadedTiles += 1
        updateWatchValueViews()
        updateWatchSliderValue()
        checkWatchCompletion()
    }
    
    func uploadWithError() {
        uploadErrors += 1
        updateWatchValueViews()
        updateWatchSliderValue()
        checkWatchCompletion()
    }
    
    private func checkWatchCompletion(){
        if uploadedTiles + uploadErrors == watchTiles.count{
            enableUpload(true)
            tileUploadQueue?.cancelAllOperations()
            tileUploadQueue = nil
        }
    }
    
}




    

