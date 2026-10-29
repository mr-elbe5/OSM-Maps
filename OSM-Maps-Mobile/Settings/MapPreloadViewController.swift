/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers
import OSLog

class MapPreloadViewController: ScrollViewController{
    
    var maxPreloadZoomControl = UISegmentedControl()
    
    var calculateTilesButton = UIButton()
    
    var allTilesValueLabel = UILabel()
    var existingTilesValueLabel = UILabel()
    var tilesToLoadValueLabel = UILabel()
    
    var startPreloadButton = UIButton()
    var cancelPreloadButton = UIButton()
    
    var preloadProgressView = UIProgressView()
    
    var preloadErrorsValueLabel = UILabel()
    
    // watch upload
    
    var watchStatusLabel = UILabel(text: "disconnected".localize())
    var prepareWatchUploadButton = UIButton()
    var startWatchUploadButton = UIButton()
    var cancelWatchUploadButton = UIButton()
    
    var watchProgressView = UIProgressView()
    
    var existingWatchTilesValueLabel = UILabel()
    var uploadErrorsValueLabel = UILabel()
    
    var preloader = MapPreloader()
    
    override func loadView() {
        title = "mapPreload".localize()
        super.loadView()
        view.addSubviewFillingSafeArea(scrollView, insets: .zero)
        scrollView.backgroundColor = .systemBackground
        setupScrollView()
        loadScrollableSubviews()
        preloader.delegate = self
        if preloader.tileRegion.tiles.grids.isEmpty{
            setTileRegion()
        }
        setupPreloadButtons()
        if !WatchConnector.shared.isWatchConnected{
            WatchConnector.shared.start()
            DispatchQueue.main.async {
                self.updateConnectionStatus()
            }
        }
    }
    
    func loadScrollableSubviews() {
        
        let segmentTitleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]
        
        var header = UILabel(header: "currentServer".localize())
        contentView.addSubviewBelow(header)
        
        let serverLabel = UILabel(text: Settings.shared.tileSource.displayName)
        contentView.addSubviewBelow(serverLabel, upperView: header, insets: OSInsets.defaultInsets)
        
        let clearTileCacheButton = UIButton(name: "clearTileCache".localize(), action: UIAction(){ action in
            self.deleteAllTiles()
        })
        contentView.addSubviewBelow(clearTileCacheButton, upperView: serverLabel)
        let clearCurrentTileCacheButton = UIButton(name: "clearCurrentTileCache".localize(), action: UIAction(){ action in
            self.deleteCurrentTiles()
        })
        contentView.addSubviewBelow(clearCurrentTileCacheButton, upperView: clearTileCacheButton)
        
        header = UILabel(header: "mapTiles".localize())
        contentView.addSubviewBelow(header, upperView: clearCurrentTileCacheButton)
        
        let note = UILabel(hint: "mapPreloadNote".localize(table: "Hints"))
        note.numberOfLines = 0
        note.lineBreakMode = .byWordWrapping
        contentView.addSubviewBelow(note, upperView: header)
        
        let sourceLabel = UILabel()
        sourceLabel.numberOfLines = 0
        sourceLabel.text = "\("currentServer".localize()): \(Settings.shared.tileSource.displayName)"
        contentView.addSubviewBelow(sourceLabel, upperView: note)
        
        let segSize = World.maxZoom - World.minZoom
        var label = UILabel(text: "maxZoom".localize())
        contentView.addSubviewBelow(label, upperView: sourceLabel)
        
        for i: Int in 0...segSize{
            maxPreloadZoomControl.insertSegment(action: UIAction(){ action in
                self.enableDownload(false)
                self.preloader.maxPreloadZoom = i + World.minZoom
            }, at: i, animated: false)
            maxPreloadZoomControl.setTitle(String(i + World.minZoom), forSegmentAt: i)
        }
        maxPreloadZoomControl.setTitleTextAttributes(segmentTitleAttributes, for: .normal)
        maxPreloadZoomControl.selectedSegmentIndex = preloader.maxPreloadZoom - World.minZoom
        contentView.addSubviewBelow(maxPreloadZoomControl, upperView: label)
        
        calculateTilesButton.setTitle("recalculateTiles".localize(), for: .normal)
        calculateTilesButton.setTitleColor(.systemBlue, for: .normal)
        calculateTilesButton.setTitleColor(.systemGray, for: .disabled)
        calculateTilesButton.addAction(UIAction(){ action in
            self.setTileRegion()
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
            self.preloader.startDownload()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(startPreloadButton, top: tilesToLoadLabel.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.centerXAnchor)
        
        cancelPreloadButton.setTitle("cancel".localize(), for: .normal)
        cancelPreloadButton.setTitleColor(.systemBlue, for: .normal)
        cancelPreloadButton.setTitleColor(.systemGray, for: .disabled)
        cancelPreloadButton.addAction(UIAction(){ action in
            self.preloader.cancelDownload()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(cancelPreloadButton, top: tilesToLoadLabel.bottomAnchor, leading: contentView.centerXAnchor, trailing: contentView.trailingAnchor)
        
        let preloadProgressLabel = UILabel(hint: "progress".localizeWithColon())
        contentView.addSubviewBelow(preloadProgressLabel, upperView: startPreloadButton)
        preloadProgressView.progress = 0
        contentView.addSubviewWithAnchors(preloadProgressView, top: preloadProgressLabel.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: OSInsets.doubleInsets)
        
        var errorsInfo = UILabel()
        errorsInfo.text = "unloadedTiles".localize()
        contentView.addSubviewWithAnchors(errorsInfo, top: preloadProgressView.bottomAnchor, leading: contentView.leadingAnchor)
        preloadErrorsValueLabel.text = String(preloader.preloadErrors)
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
        
        prepareWatchUploadButton.setTitle("prepareWatchUpload".localize(), for: .normal)
        prepareWatchUploadButton.setTitleColor(.systemBlue, for: .normal)
        prepareWatchUploadButton.setTitleColor(.systemGray, for: .disabled)
        prepareWatchUploadButton.addAction(UIAction(){ action in
            self.prepareWatchUpload()
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(prepareWatchUploadButton, upperView: label)
        
        let existingWatchTilesLabel = UILabel()
        existingWatchTilesLabel.text = "existingTiles".localize()
        contentView.addSubviewWithAnchors(existingWatchTilesLabel, top: prepareWatchUploadButton.bottomAnchor, leading: contentView.leadingAnchor)
        contentView.addSubviewWithAnchors(existingWatchTilesValueLabel, top: prepareWatchUploadButton.bottomAnchor, leading: existingWatchTilesLabel.trailingAnchor)
        
        startWatchUploadButton.setTitle("startWatchUpload".localize(), for: .normal)
        startWatchUploadButton.setTitleColor(.systemBlue, for: .normal)
        startWatchUploadButton.setTitleColor(.systemGray, for: .disabled)
        startWatchUploadButton.addAction(UIAction(){ action in
            let started = self.startWatchUpload()
            if !started{
                self.cancelWatchUpload()
                self.showError("watchUploadNotStarted".localize())
            }
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(startWatchUploadButton, upperView: existingWatchTilesLabel)
        
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
        uploadErrorsValueLabel.text = String(preloader.uploadErrors)
        contentView.addSubviewWithAnchors(uploadErrorsValueLabel, top: watchProgressView.bottomAnchor, leading: errorsInfo.trailingAnchor)
            .connectToBottom(of: contentView)
        
        enableZoomControls(true)
        enableDownload(false)
        updateConnectionStatus()
        
    }
    
    func deleteAllTiles(){
        showDestructiveApprove(title: "clearMapCache".localize(), text: "clearMapCacheHint".localize(table: "Hints")){
            TileProvider.shared.resetTileDirectories()
        }
    }
    
    func deleteCurrentTiles(){
        showDestructiveApprove(title: "clearCurrentMapCache".localize(), text: "clearCurrentMapCacheHint".localize(table: "Hints")){
            TileProvider.shared.deleteTiles(dirURL: Settings.shared.tileDirURL)
        }
    }
    
    func setupPreloadButtons(){
        if preloader.existingTiles == preloader.allPreloadTiles{
            startPreloadButton.isEnabled = false
            cancelPreloadButton.isEnabled = false
        }
        else{
            startPreloadButton.isEnabled = true
            cancelPreloadButton.isEnabled = false
        }
    }
    
    func setTileRegion(){
        if !preloader.setTileRegion(MainViewController.shared.mapView.scrollView.tileRegion){
            updateValueViews()
            updateSliderValue(0.0)
            enableDownload(false)
            enableDownload(false)
            showError("tooManyTiles".localize(param: String(MapPreloader.maxDownloadTiles)))
        }
    }
    
}

extension MapPreloadViewController: PreloaderDelegate{
    
    func updateValueViews(){
        allTilesValueLabel.text = String(preloader.allPreloadTiles)
        existingTilesValueLabel.text = String(preloader.existingTiles)
        tilesToLoadValueLabel.text = String(preloader.allPreloadTiles - preloader.existingTiles)
        preloadErrorsValueLabel.text = String(preloader.preloadErrors)
    }
    
    func updateSliderValue(_ value: Float){
        if preloader.allPreloadTiles != 0{
            preloadProgressView.progress = value
        }
    }
    
    func enableDownload(_ flag: Bool){
        startPreloadButton.isEnabled = flag
        cancelPreloadButton.isEnabled = !flag
    }
    
    func enableUpload(_ flag: Bool){
        startWatchUploadButton.isEnabled = flag
        cancelWatchUploadButton.isEnabled = !flag
    }
    
    func enableZoomControls(_ flag: Bool){
        maxPreloadZoomControl.isEnabled = flag
    }
    
    func downloadFinished(){
        startPreloadButton.isEnabled = true
        cancelPreloadButton.isEnabled = false
    }
    
    func updateWatchValueViews(){
        existingWatchTilesValueLabel.text = String(preloader.existingWatchTiles)
        uploadErrorsValueLabel.text = String(preloader.uploadErrors)
    }
    
    func updateWatchSliderValue(_ value: Float){
        watchProgressView.progress = value
    }
    
}

extension MapPreloadViewController{
    
    // watch
    
    func prepareWatchUpload(){
        if WatchConnector.shared.isWatchConnected{
            preloader.prepareUpload()
        }
        else{
            showError("watchNotConnected".localize())
        }
    }
    
    func startWatchUpload() -> Bool{
        if WatchConnector.shared.isWatchConnected, preloader.uploadPrepared{
            enableUpload(false)
            showApprove(title: "tilepUload".localize(), text: "uploadingTiles".localize(i: preloader.uploadableWatchTiles))
            return preloader.startWatchUpload()
        }
        else{
            showError("watchNotConnected".localize())
            return false
        }
    }
    
    func cancelWatchUpload(){
        preloader.cancelWatchUpload()
        enableUpload(true)
    }
    
    func updateConnectionStatus(){
        watchStatusLabel.text = WatchConnector.shared.isWatchConnected ? "connected".localize() : "disconnected".localize()
        enableUpload(WatchConnector.shared.isWatchConnected)
    }
    
}




    

