/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers
import OSLog

class MapPreloadViewController: ScrollViewController{
    
    var coordinateRegion = CoordinateRegion()
    
    var maxPreloadZoomControl = UISegmentedControl()
    var maxZoom = MapPreloader.defaultMaxPreloadZoom
    
    var allTilesValueLabel = UILabel()
    var existingTilesValueLabel = UILabel()
    var tilesToLoadValueLabel = UILabel()
    
    var startPreloadButton = UIButton()
    var cancelPreloadButton = UIButton()
    
    var downloadProgressSlider = UIProgressView()
    
    var preloadErrorsValueLabel = UILabel()
    
    var preloader = MapPreloader()
    
    override func loadView() {
        title = "mapPreload".localize()
        coordinateRegion = MainViewController.shared.mapView.scrollView.coordinateRegion
        maxZoom = coordinateRegion.getMaxZoomForTileNumber(MapPreloader.maxDownloadTiles)
        super.loadView()
        view.addSubviewFillingSafeArea(scrollView, insets: .zero)
        scrollView.backgroundColor = .systemBackground
        setupScrollView()
        loadScrollableSubviews()
        preloader.delegate = self
        if preloader.tileRegion.tiles.grids.isEmpty{
            setTileRegion()
        }
        if !WatchConnector.shared.isWatchConnected{
            WatchConnector.shared.start()
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
        let label = UILabel(text: "maxZoom".localize())
        contentView.addSubviewBelow(label, upperView: sourceLabel)
        
        for i: Int in 0...segSize{
            maxPreloadZoomControl.insertSegment(action: UIAction(){ action in
                self.maxZoom = i + World.minZoom
                self.setTileRegion()
            }, at: i, animated: false)
            maxPreloadZoomControl.setTitle(String(i + World.minZoom), forSegmentAt: i)
        }
        maxPreloadZoomControl.setTitleTextAttributes(segmentTitleAttributes, for: .normal)
        maxPreloadZoomControl.selectedSegmentIndex = maxZoom - World.minZoom
        contentView.addSubviewBelow(maxPreloadZoomControl, upperView: label)
        
        let allTilesLabel = UILabel()
        allTilesLabel.text = "allTilesForDownload".localize()
        contentView.addSubviewWithAnchors(allTilesLabel, top: maxPreloadZoomControl.bottomAnchor, leading: contentView.leadingAnchor)
        contentView.addSubviewWithAnchors(allTilesValueLabel, top: maxPreloadZoomControl.bottomAnchor, leading: allTilesLabel.trailingAnchor)
        
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
        downloadProgressSlider.progress = 0
        contentView.addSubviewWithAnchors(downloadProgressSlider, top: preloadProgressLabel.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: OSInsets.doubleInsets)
        
        let errorsInfo = UILabel()
        errorsInfo.text = "unloadedTiles".localize()
        contentView.addSubviewWithAnchors(errorsInfo, top: downloadProgressSlider.bottomAnchor, leading: contentView.leadingAnchor)
        preloadErrorsValueLabel.text = String(preloader.preloadErrors)
        contentView.addSubviewWithAnchors(preloadErrorsValueLabel, top: downloadProgressSlider.bottomAnchor, leading: errorsInfo.trailingAnchor)
            .connectToBottom(of: contentView)
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
    
    func setTileRegion(){
        let tileRegion = TileRegion(coordinateRegion: coordinateRegion, minZoom: World.minZoom, maxZoom: maxZoom)
        if tileRegion.size > MapPreloader.maxDownloadTiles{
            updateDownloadLabels(tileRegion.size)
            showError("tooManyTiles".localize(param: String(MapPreloader.maxDownloadTiles)))
        }
        else{
            preloader.setTileRegion(tileRegion)
            updateDownloadLabels()
            updateDownloadSliderValue(preloader.sliderValue)
        }
        updateButtons()
    }
    
    func startDownload(){
        if preloader.tileRegion.size > 0, self.preloader.startDownload(){
            updateDownloadLabels()
            updateDownloadSliderValue(preloader.sliderValue)
            updateButtons()
        }
    }
    
    func cancelDownload(){
        preloader.cancelDownload()
        updateDownloadLabels()
        updateButtons()
    }
    
    func updateDownloadLabels(_ size: Int){
        allTilesValueLabel.text = String(size)
        allTilesValueLabel.textColor = .red
    }
    
    func updateDownloadLabels(){
        allTilesValueLabel.text = String(preloader.allPreloadTiles)
        allTilesValueLabel.textColor = .label
        existingTilesValueLabel.text = String(preloader.existingTiles)
        tilesToLoadValueLabel.text = String(preloader.allPreloadTiles - preloader.existingTiles)
        preloadErrorsValueLabel.text = String(preloader.preloadErrors)
    }
    
    func updateDownloadSliderValue(_ value: Float){
        downloadProgressSlider.progress = value
    }
    
    func updateButtons(){
        switch preloader.status{
        case .downloading:
            startPreloadButton.isEnabled = false
        default:
            startPreloadButton.isEnabled = true
        }
    }
    
}

extension MapPreloadViewController: PreloaderDelegate{
    
    func downloadSucceeded(){
        updateDownloadLabels()
        updateDownloadSliderValue(preloader.sliderValue)
    }
    
    func downloadWithError(){
        updateDownloadLabels()
        updateDownloadSliderValue(preloader.sliderValue)
    }
    
    func downloadCompleted(){
        updateButtons()
    }
    
}





    

