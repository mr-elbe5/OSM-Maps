/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation

class TileSourceViewController: PopoverViewController {
    
    var contentView: TileSourceView{
        view as! TileSourceView
    }
    
    override func loadView() {
        view = TileSourceView(controller: self)
        view.frame = CGRect(origin: .zero, size: CGSize(width: 300, height: 0))
        view.setupView()
    }
    
    func clearTiles(){
        showDestructiveApprove(title: "deleteAllTiles".localize(), text: "deleteAllTilesHint".localize(table: "Hints")){
            TileProvider.shared.deleteAllTiles()
            MainViewController.shared.refreshMap()
        }
    }
    
    func deleteAllTiles(){
        showDestructiveApprove(title: "clearMapCache".localize(), text: "clearMapCacheHint".localize(table: "Hints")){
            TileProvider.shared.deleteAllTiles()
        }
    }
    
    func deleteCurrentTiles(){
        showDestructiveApprove(title: "clearCurrentMapCache".localize(), text: "clearCurrentMapCacheHint".localize(table: "Hints")){
            TileProvider.shared.deleteCurrentTiles()
        }
    }
    
}

class TileSourceView: PopoverView{
    
    var contentController: TileSourceViewController{
        controller as! TileSourceViewController
    }
    
    var nameField: LabeledTextField!
    var tileUrlTemplateField: LabeledTextField!
    
    var overlaySelectPanel = NSView()
    
    var overlayNameField: LabeledTextField!
    var overlayUrlTemplateField: LabeledTextField!
    
    override func setupView(){
        setupContent()
    }
    
    func setupContent(){
        removeAllSubviews()
        nameField = LabeledTextField()
        nameField.setupView(labelText: "mapName".localize(), text: Settings.shared.tileSource.displayName, isHorizontal: false)
        addSubviewBelow(nameField, insets: .defaultInsets)
        tileUrlTemplateField = LabeledTextField()
        tileUrlTemplateField.setupView(labelText: "templateURL".localize(), text: Settings.shared.tileSource.templateUrl, isHorizontal: false)
        addSubviewBelow(tileUrlTemplateField, upperView: nameField, insets: .defaultInsets)
        var label = NSTextField(labelWithString: "use".localizeWithColon())
        addSubviewBelow(label, upperView: tileUrlTemplateField, insets: .defaultInsets)
        var lastView: NSView = label
        
        for mapServer in TileSources.shared{
            let button = TileSourceActionButton()
            button.asTextButton(mapServer.displayName,target: self, action: #selector(setTileSource))
            button.source = mapServer
            addSubviewWithAnchors(button, top: lastView.bottomAnchor, leading: leadingAnchor)
            let deleteButton = TileSourceActionButton(icon: "trash", color: .systemRed, target: self, action: #selector(deleteTileSource))
            deleteButton.source = mapServer
            addSubviewWithAnchors(deleteButton, leading: button.trailingAnchor, trailing: trailingAnchor)
                .centerY(button.centerYAnchor)
                .width(30)
            lastView = button
        }
        
        let saveButton = NSButton().asTextButton("save".localize(), target: self, action: #selector(save))
        addSubviewWithAnchors(saveButton, top: lastView.bottomAnchor, insets: .doubleInsets)
        .centerX(centerXAnchor)
        
        label = NSTextField(labelWithString: "overlays".localizeWithColon()).asHeadline()
        addSubviewBelow(label, upperView: saveButton)
        setupOverlaySelectPanel()
        addSubviewBelow(overlaySelectPanel, upperView: label)
        
        label = NSTextField(labelWithString: "newOverlay".localizeWithColon()).asHeadline()
        addSubviewBelow(label, upperView: overlaySelectPanel)
        overlayNameField = LabeledTextField()
        overlayNameField.setupView(labelText: "overlayName".localize(), text: "", isHorizontal: false)
        addSubviewBelow(overlayNameField, upperView: label, insets: .defaultInsets)
        overlayUrlTemplateField = LabeledTextField()
        overlayUrlTemplateField.setupView(labelText: "templateURL".localize(), text: "", isHorizontal: false)
        addSubviewBelow(overlayUrlTemplateField, upperView: overlayNameField, insets: .defaultInsets)
        let addOverlayButton = NSButton().asTextButton("add".localize(), target: self, action: #selector(addNewOverlay))
        addSubviewWithAnchors(addOverlayButton, top: overlayUrlTemplateField.bottomAnchor, insets: .doubleInsets)
        .centerX(centerXAnchor)
        
        let hintText = NSTextField(wrappingLabelWithString: "tileServerHint".localize())
        hintText.font = .preferredFont(forTextStyle: .footnote)
        addSubviewBelow(hintText, upperView: addOverlayButton, insets: .flatInsets)
        
        let setDefaultsButton = NSButton().asTextButton("setDefaults".localize(), target: self, action: #selector(setDefaults))
        addSubviewBelow(setDefaultsButton, upperView: hintText)
        lastView = setDefaultsButton
        let clearTileCacheButton = NSButton().asTextButton("clearTileCache".localize(), target: self,  action: #selector(deleteAllTiles))
        addSubviewBelow(clearTileCacheButton, upperView: lastView)
        let clearCurrentTileCacheButton = NSButton().asTextButton("clearCurrentTileCache".localize(), target: self, action: #selector(deleteCurrentTiles))
        addSubviewBelow(clearCurrentTileCacheButton, upperView: clearTileCacheButton)
            .connectToBottom(of: self)
    }
    
    func setupOverlaySelectPanel(){
        var lastLine: NSView? = nil
        overlaySelectPanel.removeAllSubviews()
        for idx in 0..<OverlayTileSources.shared.count{
            let overlay = OverlayTileSources.shared[idx]
            let overlayLine = OverlayLine(source: overlay)
            overlayLine.setupView()
            overlayLine.delegate = self
            overlaySelectPanel.addSubviewBelow(overlayLine, upperView: lastLine, insets: .narrowInsets)
            lastLine = overlayLine
        }
        lastLine?.connectToBottom(of: overlaySelectPanel)
    }
    
    @objc func setTileSource(_ sender: AnyObject){
        if let button = sender as? TileSourceActionButton{
            self.nameField.text = button.source.displayName
            self.tileUrlTemplateField.text = button.source.templateUrl
        }
    }
    
    @objc func deleteTileSource(_ sender: AnyObject){
        if let button = sender as? TileSourceActionButton{
            TileSources.shared.remove(button.source)
            TileSources.shared.save()
            self.setupContent()
        }
    }
    
    @objc func addNewOverlay(){
        let newOverlayDisplayName = overlayNameField.text
        let newOverlayTemplateUrl = overlayUrlTemplateField.text
        if !newOverlayDisplayName.isEmpty, !newOverlayTemplateUrl.isEmpty{
            let newName = newOverlayDisplayName.lowercased().replacingOccurrences(of: " ", with: "_")
            let overlaySource = OverlayTileSource(name: newName, displayName: newOverlayDisplayName, templateUrl: newOverlayTemplateUrl)
            TileProvider.shared.checkSource(overlaySource){ success in
                if success{
                    OverlayTileSources.shared.append(overlaySource)
                    OverlayTileSources.shared.updateIndices()
                    OverlayTileSources.shared.save()
                    DispatchQueue.main.async {
                        self.overlayNameField.text = ""
                        self.overlayUrlTemplateField.text = ""
                        self.setupOverlaySelectPanel()
                    }
                }
                else{
                    DispatchQueue.main.async {
                        self.contentController.showError(text: "sourceNotFound".localize())
                    }
                }
            }
            
        }
    }
    
    @objc func deleteOverlay(_ sender: AnyObject){
        if let button = sender as? TileSourceActionButton{
            OverlayTileSources.shared.remove(button.source)
            OverlayTileSources.shared.save()
            self.setupContent()
        }
    }
    
    @objc func clearOverlay(){
        self.overlayNameField.text = ""
        self.overlayUrlTemplateField.text = ""
        self.setupContent()
    }
    
    @objc func save(){
        saveTileSource()
        saveOverlay()
        Settings.shared.save()
        Settings.shared.assertTileDirs()
        MainViewController.shared.mapView.refresh()
    }
    
    @objc func saveTileSource(){
        let newDisplayName = nameField.text
        let newTemplateUrl = tileUrlTemplateField.text
        if !newDisplayName.isEmpty, !newTemplateUrl.isEmpty{ // only name changed
            if let mapSource = TileSources.shared.getByUrl(newTemplateUrl){
                mapSource.displayName = newDisplayName
                Settings.shared.tileSource = mapSource
            }
            else{
                let newName = newDisplayName.lowercased().replacingOccurrences(of: " ", with: "_")
                let mapSource = TileSource(name: newName, displayName: newDisplayName, templateUrl: newTemplateUrl)
                TileSources.shared.append(mapSource)
                Settings.shared.tileSource = mapSource
            }
            TileSources.shared.save()
        }
    }
    
    @objc func saveOverlay(){
        let newOverlayDisplayName = overlayNameField.text
        let newOverlayTemplateUrl = overlayUrlTemplateField.text
        if !newOverlayDisplayName.isEmpty, !newOverlayTemplateUrl.isEmpty{ // only name changed
            let newName = newOverlayDisplayName.lowercased().replacingOccurrences(of: " ", with: "_")
            let overlaySource = OverlayTileSource(name: newName, displayName: newOverlayDisplayName, templateUrl: newOverlayTemplateUrl)
            OverlayTileSources.shared.append(overlaySource)
            OverlayTileSources.shared.save()
        }
        if Settings.shared.hasOverlay{
            Settings.shared.showOverlay = true
        }
    }
    
    @objc func setDefaults(){
        TileSources.setDefaults()
        OverlayTileSources.setDefaults()
        Settings.shared.tileSource = TileSource.defaultTileSource
        self.setupContent()
    }
    
    @objc func deleteAllTiles(){
        contentController.deleteAllTiles()
    }
    
    @objc func deleteCurrentTiles(){
        contentController.deleteCurrentTiles()
    }
    
}

extension TileSourceView: OverlayLineDelegate{
    
    func selectionChanged(){
        for sv in overlaySelectPanel.subviews{
            if let ol = sv as? OverlayLine{
                ol.source.active = ol.switchView.state == .on
            }
        }
    }
    
    func moveSourceUp(_ line: OverlayLine){
        OverlayTileSources.shared.moveUp(idx: line.source.idx)
        setupOverlaySelectPanel()
    }
    
    func removeSource(_ line: OverlayLine){
        if OverlayTileSources.shared.contains(line.source){
            OverlayTileSources.shared.remove(line.source)
            setupOverlaySelectPanel()
        }
    }
    
}

protocol OverlayLineDelegate{
    func selectionChanged()
    func moveSourceUp(_ line: OverlayLine)
    func removeSource(_ line: OverlayLine)
}

class OverlayLine: NSView{
    
    var source: OverlayTileSource
    
    var label: NSTextField!
    var switchView: NSSwitch!
    var upButton: NSButton
    var deleteButton: NSButton
    
    var delegate: OverlayLineDelegate?
    
    init(source: OverlayTileSource) {
        self.source = source
        label = NSTextField(labelWithString: source.name)
        switchView = NSSwitch()
        upButton = NSButton().asIconButton("arrow.up", color: .white)
        deleteButton = NSButton().asIconButton("trash", color: .systemRed)
        super.init(frame: .zero)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView(){
        height(20)
        addSubviewWithAnchors(label, leading: leadingAnchor, insets: .zero).centerY(centerYAnchor)
        addSubviewWithAnchors(switchView, leading: label.trailingAnchor).centerY(centerYAnchor)
        
        addSubviewWithAnchors(deleteButton, trailing: trailingAnchor).centerY(centerYAnchor)
        addSubviewWithAnchors(upButton, trailing: deleteButton.leadingAnchor).centerY(centerYAnchor)
        
        switchView.target = self
        switchView.action = #selector(selectionChanged)
        switchView.state = source.active ? .on : .off
        upButton.target = self
        upButton.action = #selector(moveSourceUp)
        upButton.isEnabled = source.idx > 0
        deleteButton.target = self
        deleteButton.action = #selector(removeSource)
    }
    
    @objc func selectionChanged(){
        self.source.active = self.switchView.state == .on
        self.delegate?.selectionChanged()
    }
    
    @objc func moveSourceUp(){
        self.delegate?.moveSourceUp(self)
    }
    
    @objc func removeSource(){
        self.delegate?.removeSource(self)
    }
    
}

class TileSourceActionButton: NSButton{
    
    var source: TileSource = .dummyTileSource
    
}



