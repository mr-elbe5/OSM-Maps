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
    
    var nameField = LabeledTextField()
    var tileUrlTemplateField = LabeledTextField()
    
    var overlayNameField = LabeledTextField()
    var overlayUrlTemplateField = LabeledTextField()
    
    override func setupView(){
        setupContent()
    }
    
    func setupContent(){
        nameField.setupView(labelText: "mapName".localize(), text: Settings.shared.tileSource.displayName, isHorizontal: false)
        addSubviewBelow(nameField, insets: .defaultInsets)
        tileUrlTemplateField.setupView(labelText: "templateURL".localize(), text: Settings.shared.tileSource.templateUrl, isHorizontal: false)
        addSubviewBelow(tileUrlTemplateField, upperView: nameField, insets: .defaultInsets)
        var useLabel = NSTextField(labelWithString: "use".localizeWithColon())
        addSubviewBelow(useLabel, upperView: tileUrlTemplateField, insets: .defaultInsets)
        var lastView: NSView = useLabel
        
        for mapServer in TileSources.shared{
            let button = TileSourceActionButton()
            button.asTextButton(mapServer.displayName,target: self, action: #selector(setTileSource))
            button.source = mapServer
            addSubviewWithAnchors(button, top: lastView.bottomAnchor, leading: leadingAnchor, insets: .flatInsets)
            let deleteButton = TileSourceActionButton(icon: "trash", color: .systemRed, target: self, action: #selector(deleteTileSource))
            addSubviewWithAnchors(deleteButton, leading: button.trailingAnchor, insets: .flatInsets)
                .centerY(button.centerYAnchor)
            lastView = button
        }
        
        overlayNameField.setupView(labelText: "overlayName".localize(), text: Settings.shared.overlayTileSource?.displayName ?? "", isHorizontal: false)
        addSubviewBelow(overlayNameField, upperView: lastView, insets: .defaultInsets)
        overlayUrlTemplateField.setupView(labelText: "templateURL".localize(), text: Settings.shared.overlayTileSource?.templateUrl ?? "", isHorizontal: false)
        addSubviewBelow(overlayUrlTemplateField, upperView: overlayNameField, insets: .defaultInsets)
        let clearOverlayButton = NSButton().asTextButton("clear".localize(), target: self, action: #selector(clearOverlay))
        addSubviewBelow(clearOverlayButton, upperView: overlayUrlTemplateField)
        useLabel = NSTextField(labelWithString: "use".localizeWithColon())
        addSubviewBelow(useLabel, upperView: clearOverlayButton, insets: .defaultInsets)
        lastView = useLabel
        
        for overlayServer in TileSources.sharedOverlays{
            let button = TileSourceActionButton()
            button.asTextButton(overlayServer.displayName, target: self, action: #selector(setOverlay))
            button.source = overlayServer
            addSubviewWithAnchors(button, top: lastView.bottomAnchor, leading: leadingAnchor, insets: .flatInsets)
            let deleteButton = NSButton(icon: "trash", color: .systemRed, target: self, action: #selector(deleteOverlay))
            addSubviewWithAnchors(deleteButton, leading: button.trailingAnchor, insets: .flatInsets)
                .centerY(button.centerYAnchor)
            lastView = button
        }
        
        let hintText = NSTextField(labelWithString: "tileServerHint".localize())
        hintText.font = .preferredFont(forTextStyle: .footnote)
        addSubviewBelow(hintText, upperView: lastView, insets: .flatInsets)
        
        let saveButton = NSButton().asTextButton("save".localize(), target: self, action: #selector(save))
        addSubviewWithAnchors(saveButton, top: hintText.bottomAnchor, insets: .doubleInsets)
        .centerX(centerXAnchor)
        
        let setDefaultsButton = NSButton().asTextButton("setDefaults".localize(), target: self, action: #selector(setDefaults))
        addSubviewBelow(setDefaultsButton, upperView: saveButton)
        lastView = setDefaultsButton
        let clearTileCacheButton = NSButton().asTextButton("clearTileCache".localize(), target: self,  action: #selector(deleteAllTiles))
        addSubviewBelow(clearTileCacheButton, upperView: lastView)
        let clearCurrentTileCacheButton = NSButton().asTextButton("clearCurrentTileCache".localize(), target: self, action: #selector(deleteCurrentTiles))
        addSubviewBelow(clearCurrentTileCacheButton, upperView: clearTileCacheButton)
            .connectToBottom(of: self)
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
            TileSources.save()
            self.setupContent()
        }
    }
    
    @objc func setOverlay(_ sender: AnyObject){
        if let button = sender as? TileSourceActionButton{
            self.overlayNameField.text = button.source.displayName
            self.overlayUrlTemplateField.text = button.source.templateUrl
        }
    }
    
    @objc func deleteOverlay(_ sender: AnyObject){
        if let button = sender as? TileSourceActionButton{
            TileSources.sharedOverlays.remove(button.source)
            TileSources.save()
            self.setupContent()
        }
    }
    
    @objc func clearOverlay(){
        self.overlayNameField.text = ""
        self.overlayUrlTemplateField.text = ""
        self.setupContent()
    }
    
    @objc func save(){
        saveServer()
        saveOverlay()
        Settings.shared.save()
        Settings.shared.assertTileDirs()
        MainViewController.shared.mapView.refresh()
    }
    
    @objc func saveServer(){
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
            TileSources.save()
        }
    }
    
    @objc func saveOverlay(){
        let newOverlayDisplayName = overlayNameField.text
        let newOverlayTemplateUrl = overlayUrlTemplateField.text
        if !newOverlayDisplayName.isEmpty, !newOverlayTemplateUrl.isEmpty{ // only name changed
            if let overlaySource = TileSources.sharedOverlays.getByUrl(newOverlayTemplateUrl){
                overlaySource.displayName = newOverlayDisplayName
                Settings.shared.overlayTileSource = overlaySource
            }
            else{
                let newName = newOverlayDisplayName.lowercased().replacingOccurrences(of: " ", with: "_")
                let overlaySource = TileSource(name: newName, displayName: newOverlayDisplayName, templateUrl: newOverlayTemplateUrl)
                TileSources.sharedOverlays.append(overlaySource)
                Settings.shared.overlayTileSource = overlaySource
            }
            TileSources.saveOverlays()
        }
        else{
            Settings.shared.overlayTileSource = nil
        }
        if Settings.shared.hasOverlay{
            Settings.shared.showOverlay = true
        }
    }
    
    @objc func setDefaults(){
        TileSources.setDefaults()
        TileSources.setOverlayDefaults()
        Settings.shared.setDefaultSources()
        self.setupContent()
    }
    
    @objc func deleteAllTiles(){
        contentController.deleteAllTiles()
    }
    
    @objc func deleteCurrentTiles(){
        contentController.deleteCurrentTiles()
    }
    
}

class TileSourceActionButton: NSButton{
    
    var source: TileSource = .dummyTileSource
    
}

