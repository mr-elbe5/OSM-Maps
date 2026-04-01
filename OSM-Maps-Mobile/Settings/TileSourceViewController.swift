/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class TileSourceViewController: ScrollViewController{
    
    var nameField = LabeledTextField()
    var tileUrlTemplateField = LabeledTextField()
    
    var overlayNameField = LabeledTextField()
    var overlayUrlTemplateField = LabeledTextField()
    
    override func loadView() {
        title = "tileSource".localize()
        super.loadView()
        addScrollViewFillingWithKeyboard()
        scrollView.backgroundColor = .systemBackground
        setupScrollView()
        loadScrollableSubviews()
    }
    
    func loadScrollableSubviews() {
        contentView.removeAllSubviews()
        nameField.setupView(labelText: "mapName".localize(), text: Settings.shared.tileSource.displayName, isHorizontal: false)
        contentView.addSubviewBelow(nameField, insets: .defaultInsets)
        tileUrlTemplateField.setupView(labelText: "templateURL".localize(), text: Settings.shared.tileSource.templateUrl, isHorizontal: false)
        contentView.addSubviewBelow(tileUrlTemplateField, upperView: nameField, insets: .defaultInsets)
        var useLabel = UILabel(text: "use".localizeWithColon())
        contentView.addSubviewBelow(useLabel, upperView: tileUrlTemplateField, insets: .defaultInsets)
        var lastView: UIView = useLabel
        
        for mapServer in TileSources.shared{
            let button = UIButton(type: .system)
            button.setTitle(mapServer.displayName, for: .normal)
            button.setTitleColor(.systemBlue, for: .normal)
            button.addAction(UIAction(){ action in
                self.nameField.text = mapServer.displayName
                self.tileUrlTemplateField.text = mapServer.templateUrl
            }, for: .touchDown)
            contentView.addSubviewWithAnchors(button, top: lastView.bottomAnchor, leading: contentView.leadingAnchor, insets: .flatInsets)
            let deleteButton = IconButton(smallIcon: "trash", tintColor: .systemRed)
            deleteButton.addAction(UIAction(){ action in
                TileSources.shared.remove(mapServer)
                TileSources.save()
                self.loadScrollableSubviews()
            }, for: .touchDown)
            contentView.addSubviewWithAnchors(deleteButton, leading: button.trailingAnchor, insets: .flatInsets)
                .centerY(button.centerYAnchor)
            lastView = button
        }
        
        overlayNameField.setupView(labelText: "overlayName".localize(), text: Settings.shared.overlayTileSource?.displayName ?? "", isHorizontal: false)
        contentView.addSubviewBelow(overlayNameField, upperView: lastView, insets: .defaultInsets)
        overlayUrlTemplateField.setupView(labelText: "templateURL".localize(), text: Settings.shared.overlayTileSource?.templateUrl ?? "", isHorizontal: false)
        contentView.addSubviewBelow(overlayUrlTemplateField, upperView: overlayNameField, insets: .defaultInsets)
        let clearOverlayButton = UIButton(name: "clear".localize(), action: UIAction(){ action in
            self.clearOverlay()
        })
        contentView.addSubviewBelow(clearOverlayButton, upperView: overlayUrlTemplateField)
        useLabel = UILabel(text: "use".localizeWithColon())
        contentView.addSubviewBelow(useLabel, upperView: clearOverlayButton, insets: .defaultInsets)
        lastView = useLabel
        
        for overlayServer in TileSources.sharedOverlays{
            let button = UIButton(type: .system)
            button.setTitle(overlayServer.displayName, for: .normal)
            button.setTitleColor(.systemBlue, for: .normal)
            button.addAction(UIAction(){ action in
                self.overlayNameField.text = overlayServer.displayName
                self.overlayUrlTemplateField.text = overlayServer.templateUrl
            }, for: .touchDown)
            contentView.addSubviewWithAnchors(button, top: lastView.bottomAnchor, leading: contentView.leadingAnchor, insets: .flatInsets)
            let deleteButton = IconButton(smallIcon: "trash", tintColor: .systemRed)
            deleteButton.addAction(UIAction(){ action in
                TileSources.sharedOverlays.remove(overlayServer)
                TileSources.saveOverlays()
                self.loadScrollableSubviews()
            }, for: .touchDown)
            contentView.addSubviewWithAnchors(deleteButton, leading: button.trailingAnchor, insets: .flatInsets)
                .centerY(button.centerYAnchor)
            lastView = button
        }
        
        let hintText = UILabel(text: "tileServerHint".localize())
        hintText.numberOfLines = 0
        hintText.font = .preferredFont(forTextStyle: .footnote)
        contentView.addSubviewBelow(hintText, upperView: lastView, insets: .flatInsets)
        
        let saveButton = UIButton()
        saveButton.setTitle("save".localize(), for: .normal)
        saveButton.setTitleColor(.systemBlue, for: .normal)
        saveButton.addAction(UIAction(){ action in
            self.save()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(saveButton, top: hintText.bottomAnchor, insets: .doubleInsets)
        .centerX(contentView.centerXAnchor)
        
        let setDefaultsButton = UIButton(name: "setDefaults".localize(), action: UIAction(){ action in
            self.setDefaults()
        })
        contentView.addSubviewBelow(setDefaultsButton, upperView: saveButton)
        let clearTileCacheButton = UIButton(name: "clearTileCache".localize(), action: UIAction(){ action in
            self.deleteAllTiles()
        })
        contentView.addSubviewBelow(clearTileCacheButton, upperView: setDefaultsButton)
        let clearCurrentTileCacheButton = UIButton(name: "clearCurrentTileCache".localize(), action: UIAction(){ action in
            self.deleteCurrentTiles()
        })
        contentView.addSubviewBelow(clearCurrentTileCacheButton, upperView: clearTileCacheButton)
            .connectToBottom(of: contentView)
    }
    
    func clearOverlay(){
        self.overlayNameField.text = ""
        self.overlayUrlTemplateField.text = ""
    }
    
    func save(){
        saveServer()
        saveOverlay()
        Settings.shared.save()
        Settings.shared.assertTileDirs()
        self.showDone(title: "ok".localize(), text: "mapSourceSaved".localize())
        MainViewController.shared.mapView.refresh()
    }
    
    func saveServer(){
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
    
    func saveOverlay(){
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
    
    func setDefaults(){
        TileSources.setDefaults()
        TileSources.setOverlayDefaults()
        Settings.shared.setDefaultSources()
        self.loadScrollableSubviews()
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

    

