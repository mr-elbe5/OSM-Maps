/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers

class SettingsViewController: ScrollViewController{
    
    static var maxDownloadTiles = 5000
    
    // date filter
    
    var dateFilterView = DateFilterView()
    var sortAscendingCheckbox = Checkbox()
    
    // cloud
    
    var syncProgressView = UIProgressView()
    var currentSyncStep: Int = 0
    var maxSyncSteps: Int = 1
    
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
    
    var followLocationSwitch = LabeledSwitchView()
    var mapSourceControl = UISegmentedControl()
    var distanceFilterControl = UISegmentedControl()
    
    var trackpointIntervalField = UISegmentedControl()
    
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
        if !WatchConnector.shared.isWatchConnectionActivated{
            WatchConnector.shared.start()
            DispatchQueue.main.async {
                self.updateConnectionStatus()
            }
        }
    }
    
    func loadScrollableSubviews() {
        
        let segmentTitleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]
        
        var header = UILabel(header: "dateFilter".localize())
        contentView.addSubviewBelow(header)
        dateFilterView.setupView(minLabelText: "minimumDate".localize(), maxLabelText: "maximumDate".localize(), minDate: ViewFilter.shared.dateFilterMinDate, maxDate: ViewFilter.shared.dateFilterMaxDate)
        dateFilterView.delegate = self
        contentView.addSubviewBelow(dateFilterView, upperView: header, insets: .zero)
        header = UILabel(header: "sorting".localize())
        contentView.addSubviewBelow(header, upperView: dateFilterView)
        sortAscendingCheckbox.setup(title: "sortAscending".localize(), index: 0, isOn: ViewFilter.shared.defaultSortAscending)
        sortAscendingCheckbox.delegate = self
        contentView.addSubviewWithAnchors(sortAscendingCheckbox, top: header.bottomAnchor, leading: contentView.leadingAnchor, insets: .zero)
        
        header = UILabel(header: "data".localize())
        contentView.addSubviewBelow(header, upperView: sortAscendingCheckbox)
        
        let deleteDataButton = UIButton()
        deleteDataButton.setTitle("deleteAllData".localize(), for: .normal)
        deleteDataButton.setTitleColor(.systemBlue, for: .normal)
        deleteDataButton.addAction(UIAction(){ action in
            self.deleteAllData()
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(deleteDataButton, upperView: header)
        
        header = UILabel(header: "iCloud".localize())
        contentView.addSubviewBelow(header, upperView: deleteDataButton)
        
        let syncNowButton = UIButton()
        syncNowButton.setTitle("synchronizeNow".localize(), for: .normal)
        syncNowButton.setTitleColor(.systemBlue, for: .normal)
        syncNowButton.addAction(UIAction(){ action in
            self.synchronizeFull()
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(syncNowButton, upperView: header)
        var hint = UILabel(hint: "synchronizeHint".localize(table: "Hints"))
        contentView.addSubviewBelow(hint, upperView: syncNowButton, insets: OSInsets.flatInsets)
        
        let synchronizeFromCloudButton = UIButton()
        synchronizeFromCloudButton.setTitle("synchronizeFromCloud".localize(), for: .normal)
        synchronizeFromCloudButton.setTitleColor(.systemBlue, for: .normal)
        synchronizeFromCloudButton.addAction(UIAction(){ action in
            self.synchronizeFromCloud()
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(synchronizeFromCloudButton, upperView: hint)
        hint = UILabel(hint: "synchronizeFromCloudHint".localize(table: "Hints"))
        contentView.addSubviewBelow(hint, upperView: synchronizeFromCloudButton, insets: OSInsets.flatInsets)
        
        let synchronizeToCloudButton = UIButton()
        synchronizeToCloudButton.setTitle("synchronizeToCloud".localize(), for: .normal)
        synchronizeToCloudButton.setTitleColor(.systemBlue, for: .normal)
        synchronizeToCloudButton.addAction(UIAction(){ action in
            self.synchronizeToCloud()
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(synchronizeToCloudButton, upperView: hint)
        hint = UILabel(hint: "synchronizeToCloudHint".localize(table: "Hints"))
        contentView.addSubviewBelow(hint, upperView: synchronizeToCloudButton, insets: OSInsets.flatInsets)
        
        let clearCloudButton = UIButton()
        clearCloudButton.setTitle("clearCloud".localize(), for: .normal)
        clearCloudButton.setTitleColor(.systemBlue, for: .normal)
        clearCloudButton.addAction(UIAction(){ action in
            self.clearCloud()
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(clearCloudButton, upperView: hint)
        hint = UILabel(hint: "clearCloudHint".localize(table: "Hints"))
        contentView.addSubviewBelow(hint, upperView: clearCloudButton, insets: OSInsets.flatInsets)
        let cloudProgressLabel = UILabel(hint: "progress".localizeWithColon())
        contentView.addSubviewBelow(cloudProgressLabel, upperView: hint)
        setSynchronizationSteps(1)
        contentView.addSubviewBelow(syncProgressView, upperView: cloudProgressLabel)
        
        header = UILabel(header: "backup".localize())
        contentView.addSubviewBelow(header, upperView: syncProgressView)
        
        let createBackupButton = UIButton()
        createBackupButton.setTitle("createBackup".localize(), for: .normal)
        createBackupButton.setTitleColor(.systemBlue, for: .normal)
        createBackupButton.addAction(UIAction(){ action in
            self.createBackup()
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(createBackupButton, upperView: header)
        hint = UILabel(hint: "backupHint".localize(table: "Hints"))
        contentView.addSubviewBelow(hint, upperView: createBackupButton, insets: OSInsets.flatInsets)
        
        let restoreBackupButton = UIButton()
        restoreBackupButton.setTitle("restoreBackup".localize(), for: .normal)
        restoreBackupButton.setTitleColor(.systemBlue, for: .normal)
        restoreBackupButton.addAction(UIAction(){ action in
            self.restoreBackup()
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(restoreBackupButton, upperView: hint)
        hint = UILabel(hint: "restoreBackupHint".localize(table: "Hints"))
        contentView.addSubviewBelow(hint, upperView: restoreBackupButton, insets: OSInsets.flatInsets)
        
        let restoreFromMapsForOSMButton = UIButton()
        restoreFromMapsForOSMButton.setTitle("restoreFromMapsForOSM".localize(), for: .normal)
        restoreFromMapsForOSMButton.setTitleColor(.systemBlue, for: .normal)
        restoreFromMapsForOSMButton.addAction(UIAction(){ action in
            self.restoreBackupFromMapsForOSM()
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(restoreFromMapsForOSMButton, upperView: hint)
        hint = UILabel(hint: "restoreFromMapsForOSMHint".localize(table: "Hints"))
        contentView.addSubviewBelow(hint, upperView: restoreFromMapsForOSMButton, insets: OSInsets.flatInsets)
        
        header = UILabel(header: "map".localize())
        contentView.addSubviewBelow(header, upperView: hint)
        
        followLocationSwitch.setupView(labelText: "followLocation".localize(), isOn: Preferences.shared.followLocation)
        followLocationSwitch.delegate = self
        contentView.addSubviewBelow(followLocationSwitch, upperView: header, insets: .zero)
        
        var subheader = UILabel(subheader: "mapServer".localize())
        contentView.addSubviewBelow(subheader, upperView: followLocationSwitch)
        
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
        
        hint = UILabel(hint: "mapServerHint".localize(table: "Hints"))
        contentView.addSubviewBelow(hint, upperView: mapSourceControl, insets: OSInsets.flatInsets)
        
        let clearTileCacheButton = UIButton(name: "clearMapCache".localize(), action: UIAction(){ action in
            self.deleteAllTiles()
        })
        contentView.addSubviewBelow(clearTileCacheButton, upperView: hint)
        
        subheader = UILabel(subheader: "distanceFilter".localize())
        contentView.addSubviewBelow(subheader, upperView: clearTileCacheButton)
        
        distanceFilterControl.insertSegment(action: UIAction(){ action in
            Preferences.shared.distanceFilter = .gps
            Preferences.shared.save()
        }, at: 0, animated: false)
        distanceFilterControl.setTitle("gpsAccuracy".localize(), forSegmentAt: 0)
        distanceFilterControl.insertSegment(action: UIAction(){ action in
            Preferences.shared.distanceFilter = .tight
            Preferences.shared.save()
        }, at: 1, animated: false)
        distanceFilterControl.setTitle("\(Int(LocationDistance.tight.distance))m", forSegmentAt: 1)
        distanceFilterControl.insertSegment(action: UIAction(){ action in
            Preferences.shared.distanceFilter = .medium
            Preferences.shared.save()
        }, at: 2, animated: false)
        distanceFilterControl.setTitle("\(Int(LocationDistance.medium.distance))m", forSegmentAt: 2)
        distanceFilterControl.insertSegment(action: UIAction(){ action in
            Preferences.shared.distanceFilter = .wide
            Preferences.shared.save()
        }, at: 3, animated: false)
        distanceFilterControl.setTitle("\(Int(LocationDistance.wide.distance))m", forSegmentAt: 3)
        distanceFilterControl.insertSegment(action: UIAction(){ action in
            Preferences.shared.distanceFilter = .extraWide
            Preferences.shared.save()
        }, at: 4, animated: false)
        distanceFilterControl.setTitle("\(Int(LocationDistance.extraWide.distance))m", forSegmentAt: 4)
        distanceFilterControl.setTitleTextAttributes(segmentTitleAttributes, for: .normal)
        distanceFilterControl.selectedSegmentIndex = LocationDistanceList.shared.indexOf(distance: Preferences.shared.distanceFilter)
        contentView.addSubviewBelow(distanceFilterControl, upperView: subheader)
        hint = UILabel(hint: "distanceFilterHint".localize(table: "Hints"))
        contentView.addSubviewBelow(hint, upperView: distanceFilterControl, insets: OSInsets.flatInsets)
        
        header = UILabel(header: "mapTiles".localize())
        contentView.addSubviewBelow(header, upperView: hint)
        
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
        
        header = UILabel(header: "tracks".localize())
        contentView.addSubviewBelow(header, upperView: errorsInfo)
        
        subheader = UILabel(subheader: "trackpointInterval".localize())
        contentView.addSubviewBelow(subheader, upperView: header)
        
        trackpointIntervalField.insertSegment(action: UIAction(){ action in
            Preferences.shared.trackpointInterval = .extrashort
            Preferences.shared.save()
        }, at: 0, animated: false)
        trackpointIntervalField.setTitle("\(Int(TrackpointInterval.extrashort.interval))s", forSegmentAt: 0)
        trackpointIntervalField.insertSegment(action: UIAction(){ action in
            Preferences.shared.trackpointInterval = .short
            Preferences.shared.save()
        }, at: 1, animated: false)
        trackpointIntervalField.setTitle("\(Int(TrackpointInterval.short.interval))s", forSegmentAt: 1)
        trackpointIntervalField.insertSegment(action: UIAction(){ action in
            Preferences.shared.trackpointInterval = .medium
            Preferences.shared.save()
        }, at: 2, animated: false)
        trackpointIntervalField.setTitle("\(Int(TrackpointInterval.medium.interval))s", forSegmentAt: 2)
        trackpointIntervalField.insertSegment(action: UIAction(){ action in
            Preferences.shared.trackpointInterval = .long
            Preferences.shared.save()
        }, at: 3, animated: false)
        trackpointIntervalField.setTitle("\(Int(TrackpointInterval.long.interval))s", forSegmentAt: 3)
        trackpointIntervalField.insertSegment(action: UIAction(){ action in
            Preferences.shared.trackpointInterval = .extralong
            Preferences.shared.save()
        }, at: 4, animated: false)
        trackpointIntervalField.setTitle("\(Int(TrackpointInterval.extralong.interval))s", forSegmentAt: 4)
        trackpointIntervalField.setTitleTextAttributes(segmentTitleAttributes, for: .normal)
        trackpointIntervalField.selectedSegmentIndex = TrackpointIntervalList.shared.indexOf(interval: Preferences.shared.trackpointInterval)
        contentView.addSubviewBelow(trackpointIntervalField, upperView: subheader)
        hint = UILabel(hint: "trackpointIntervalHint".localize(table: "Hints"))
        contentView.addSubviewBelow(hint, upperView: trackpointIntervalField, insets: OSInsets.flatInsets)
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

extension SettingsViewController{
    
    // cloud
    
    func synchronizeFull(){
        showDestructiveApprove(title: "synchronize".localize(), text: "synchronizeWarnHint".localize(table: "Hints")){
            let synchronizer = CloudSynchronizer(syncType: .full)
            synchronizer.delegate = self
            Task{
                synchronizer.synchronize()
            }
        }
    }
    
    func synchronizeFromCloud(){
        showDestructiveApprove(title: "synchronizeFromCloud".localize(), text: "synchronizeWarnHint".localize(table: "Hints")){
            let synchronizer = CloudSynchronizer(syncType: .fromCloud)
            synchronizer.delegate = self
            Task{
                synchronizer.synchronize()
            }
        }
    }
    
    func synchronizeToCloud(){
        showDestructiveApprove(title: "synchronizeToCloud".localize(), text: "synchronizeWarnHint".localize(table: "Hints")){
            let synchronizer = CloudSynchronizer(syncType: .toCloud)
            synchronizer.delegate = self
            Task{
                synchronizer.synchronize()
            }
        }
    }
    
    func clearCloud(){
        showDestructiveApprove(title: "synchronize".localize(), text: "synchronizeHint".localize(table: "Hints")){
            let synchronizer = CloudSynchronizer()
            synchronizer.delegate = self
            Task{
                synchronizer.clear()
            }
        }
    }
    
    // backup
    
    func createBackup(){
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("maps4osm_backup_\(Date.localDate.shortFileDate()).zip")
        let spinner = startSpinner()
        DispatchQueue.global(qos: .userInitiated).async {
            if Backup.createBackupFile(at: url){
                DispatchQueue.main.async {
                    let picker = UIDocumentPickerViewController(forExporting: [url])
                    picker.delegate = nil
                    picker.title = "backup".localize()
                    self.present(picker, animated: true)
                    self.stopSpinner(spinner)
                }
            }
            else{
                DispatchQueue.main.async {
                    self.showError("backupNotCreated".localize())
                    self.stopSpinner(spinner)
                }
            }
        }
        
    }
    
    func deleteAllData(){
        showDestructiveApprove(title: "deleteAllData".localize(), text: "deleteAllDataHint".localize(table: "Hints")){
            AppData.shared.deleteAllData()
        }
    }
    
    func restoreBackup(){
        showDestructiveApprove(title: "restoreBackup".localize(), text: "restoreBackupHint".localize(table: "Hints")){
            let types = UTType.types(tag: "zip", tagClass: UTTagClass.filenameExtension, conformingTo: nil)
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
            picker.title = "restore".localize()
            picker.delegate = self
            let spinner = self.startSpinner()
            self.present(picker, animated: true, completion: nil)
            self.stopSpinner(spinner)
        }
    }
    
    func restoreBackupFromMapsForOSM(){
        showDestructiveApprove(title: "restoreFromMapsForOSM".localize(), text: "restoreBackupHint".localize(table: "Hints")){
            let types = UTType.types(tag: "zip", tagClass: UTTagClass.filenameExtension, conformingTo: nil)
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
            picker.title = "restoreOld".localize()
            picker.delegate = self
            let spinner = self.startSpinner()
            self.present(picker, animated: true, completion: nil)
            self.stopSpinner(spinner)
        }
    }
    
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
            if allPreloadTiles > SettingsViewController.maxDownloadTiles{
                updateValueViews()
                updateSliderValue()
                enableDownload(false)
                enableDownload(false)
                stopSpinner(spinner)
                showError("tooManyTiles".localize(param: String(SettingsViewController.maxDownloadTiles)))
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
        if WatchConnector.shared.isWatchConnectionActivated{
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
        watchStatusLabel.text = WatchConnector.shared.isWatchConnectionActivated ? "connected".localize() : "disconnected".localize()
        enableUpload(WatchConnector.shared.isWatchConnectionActivated)
    }
    
}

extension SettingsViewController: SwitchDelegate{
    
    func switchValueDidChange(sender: LabeledSwitchView, isOn: Bool) {
        if sender == followLocationSwitch{
            Preferences.shared.followLocation = isOn
            Preferences.shared.save()
        }
    }
    
}

extension SettingsViewController: DownloadDelegate{
    
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

extension SettingsViewController: UploadDelegate{
    
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

extension SettingsViewController: DateFilterDelegate {
    
    func dateFilterDidChange() {
        ViewFilter.shared.dateFilterMinDate = dateFilterView.minDate
        ViewFilter.shared.dateFilterMaxDate = dateFilterView.maxDate
        ViewFilter.shared.save()
        MainViewController.shared.updateItemLayer()
    }
    
}

extension SettingsViewController: CheckboxDelegate {
    
    func checkboxIsSelected(index: Int, value: String) {
        switch index {
        case 0:
            ViewFilter.shared.defaultSortAscending = sortAscendingCheckbox.isOn
            ViewFilter.shared.save()
        default:
            break
        }
    }
    
}

extension SettingsViewController : CloudSynchronizerDelegate{
    
    func setSynchronizationSteps(_ value: Int) {
        maxSyncSteps = value
        currentSyncStep = 0
        syncProgressView.progress = 0
    }
    
    func nextSynchronizationStep() {
        currentSyncStep += 1
        syncProgressView.setProgress(Float(currentSyncStep) / Float(maxSyncSteps), animated: false)
    }
    
    func synchronizationDone() {
        DispatchQueue.main.async{
            self.showDone(title: "success".localize(), text: "synchronized".localize())
            MainViewController.shared.updateItemLayer()
        }
    }
    
    func clearDone() {
        DispatchQueue.main.async{
            self.showDone(title: "success".localize(), text: "cloudCleared".localize())
        }
    }
    
}

extension SettingsViewController : UIDocumentPickerDelegate{
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if controller.title == "restore".localize(){
            if let url = urls.first, url.pathExtension == "zip"{
                if url.startAccessingSecurityScopedResource(){
                    let spinner = startSpinner()
                    DispatchQueue.global(qos: .userInitiated).async {
                        if Backup.unzipBackupFile(zipFileURL: url){
                            if Backup.restoreBackupFile(){
                                DispatchQueue.main.async {
                                    self.stopSpinner(spinner)
                                    self.showDone(title: "success".localize(), text: "restoreDone".localize())
                                    MainViewController.shared.updateItemLayer()
                                }
                            }
                            else{
                                DispatchQueue.main.async {
                                    self.stopSpinner(spinner)
                                    self.showError("wrongZipFile".localize())
                                }
                            }
                        }
                        url.stopAccessingSecurityScopedResource()
                    }
                }
            }
            return
        }
        if controller.title == "restoreOld".localize(){
            if let url = urls.first, url.pathExtension == "zip"{
                if url.startAccessingSecurityScopedResource(){
                    let spinner = startSpinner()
                    DispatchQueue.global(qos: .userInitiated).async {
                        if Backup.unzipBackupFile(zipFileURL: url){
                            if Backup.importfromMapsForOSMFile(){
                                DispatchQueue.main.async {
                                    self.stopSpinner(spinner)
                                    self.showDone(title: "success".localize(), text: "restoreDone".localize())
                                    MainViewController.shared.updateItemLayer()
                                }
                                
                            }
                            else{
                                DispatchQueue.main.async {
                                    self.stopSpinner(spinner)
                                    self.showError("wrongZipFile".localize())
                                }
                            }
                        }
                        url.stopAccessingSecurityScopedResource()
                    }
                }
            }
        }
    }
    
}



    

