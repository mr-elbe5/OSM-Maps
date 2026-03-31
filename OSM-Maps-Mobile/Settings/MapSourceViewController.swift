/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class MapSourceViewController: ScrollViewController{
    
    var nameField = LabeledTextField()
    var tileUrlTemplateField = LabeledTextField()
    
    var overlayNameField = LabeledTextField()
    var overlayUrlTemplateField = LabeledTextField()
    
    override func loadView() {
        title = "mapSource".localize()
        super.loadView()
        addScrollViewFillingWithKeyboard()
        scrollView.backgroundColor = .systemBackground
        setupScrollView()
        loadScrollableSubviews()
    }
    
    func loadScrollableSubviews() {
        contentView.removeAllSubviews()
        nameField.setupView(labelText: "serverName".localize(), text: Settings.shared.mapSource.displayName, isHorizontal: false)
        contentView.addSubviewBelow(nameField, insets: .defaultInsets)
        tileUrlTemplateField.setupView(labelText: "templateURL".localize(), text: Settings.shared.mapSource.templateUrl, isHorizontal: false)
        contentView.addSubviewBelow(tileUrlTemplateField, upperView: nameField, insets: .defaultInsets)
        var lastView: UIView = tileUrlTemplateField
        
        for mapServer in MapSources.shared{
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
                MapSources.shared.remove(mapServer)
                MapSources.shared.save()
                self.loadScrollableSubviews()
            }, for: .touchDown)
            contentView.addSubviewWithAnchors(deleteButton, leading: button.trailingAnchor, insets: .flatInsets)
                .centerY(button.centerYAnchor)
            lastView = button
        }
        
        overlayNameField.setupView(labelText: "overlayName".localize(), text: Settings.shared.mapOverlaySource?.displayName ?? "", isHorizontal: false)
        contentView.addSubviewBelow(overlayNameField, upperView: lastView, insets: .defaultInsets)
        overlayUrlTemplateField.setupView(labelText: "templateURL".localize(), text: Settings.shared.mapOverlaySource?.templateUrl ?? "", isHorizontal: false)
        contentView.addSubviewBelow(overlayUrlTemplateField, upperView: overlayNameField, insets: .defaultInsets)
        lastView = overlayUrlTemplateField
        
        for overlayServer in MapOverlaySources.shared{
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
                MapOverlaySources.shared.remove(overlayServer)
                MapOverlaySources.shared.save()
                self.loadScrollableSubviews()
            }, for: .touchDown)
            contentView.addSubviewWithAnchors(deleteButton, leading: button.trailingAnchor, insets: .flatInsets)
                .centerY(button.centerYAnchor)
            lastView = button
        }
        
        let hintText = UILabel(text: "mapServerHint".localize())
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
        let clearTileCacheButton = UIButton(name: "clearMapCache".localize(), action: UIAction(){ action in
            self.deleteAllTiles()
        })
        contentView.addSubviewBelow(clearTileCacheButton, upperView: setDefaultsButton)
        let clearCurrentTileCacheButton = UIButton(name: "clearCurrentMapCache".localize(), action: UIAction(){ action in
            self.deleteCurrentTiles()
        })
        contentView.addSubviewBelow(clearCurrentTileCacheButton, upperView: clearTileCacheButton)
            .connectToBottom(of: contentView)
    }
    
    func save(){
        let serverDone = saveServer()
        let overlayDone = saveOverlay()
        if serverDone || overlayDone{
            Settings.shared.save()
            Settings.shared.assertTileDirs()
            self.showDone(title: "ok".localize(), text: "mapSourceSaved".localize())
        }
    }
    
    func saveServer() -> Bool{
        let newDisplayName = nameField.text
        let newTemplateUrl = tileUrlTemplateField.text
        if !newDisplayName.isEmpty, !newTemplateUrl.isEmpty{ // only name changed
            if let mapSource = MapSources.shared.getByUrl(newTemplateUrl){
                mapSource.displayName = newDisplayName
                Settings.shared.mapSource = mapSource
            }
            else{
                let newName = newDisplayName.lowercased().replacingOccurrences(of: " ", with: "_")
                let mapSource = MapSource(name: newName, displayName: newDisplayName, templateUrl: newTemplateUrl)
                MapSources.shared.append(mapSource)
                Settings.shared.mapSource = mapSource
            }
            MapSources.shared.save()
            return true
        }
        return false
    }
    
    func saveOverlay() -> Bool{
        let newOverlayDisplayName = overlayNameField.text
        let newOverlayTemplateUrl = overlayUrlTemplateField.text
        if !newOverlayDisplayName.isEmpty, !newOverlayTemplateUrl.isEmpty{ // only name changed
            if let overlaySource = MapOverlaySources.shared.getByUrl(newOverlayTemplateUrl){
                overlaySource.displayName = newOverlayDisplayName
                Settings.shared.mapOverlaySource = overlaySource
            }
            else{
                let newName = newOverlayDisplayName.lowercased().replacingOccurrences(of: " ", with: "_")
                let overlaySource = MapOverlaySource(name: newName, displayName: newOverlayDisplayName, templateUrl: newOverlayTemplateUrl)
                MapOverlaySources.shared.append(overlaySource)
                Settings.shared.mapOverlaySource = overlaySource
            }
            MapOverlaySources.shared.save()
            return true
        }
        return false
    }
    
    func setDefaults(){
        MapSources.setDefaults()
        MapOverlaySources.setDefaults()
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

    

