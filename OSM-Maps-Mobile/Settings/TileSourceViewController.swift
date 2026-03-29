/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol TileSourceDelegate{
    func deleteAllTiles()
}

class TileSourceViewController: ScrollViewController{
    
    var nameField = LabeledTextField()
    var tileUrlTemplateField = LabeledTextField()
    
    var delegate: TileSourceDelegate? = nil
    
    override func loadView() {
        title = "mapSource".localize()
        super.loadView()
        addScrollViewFillingWithKeyboard()
        scrollView.backgroundColor = .systemBackground
        setupScrollView()
        loadScrollableSubviews()
    }
    
    func loadScrollableSubviews() {
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
        
        let clearTileCacheButton = UIButton(name: "clearMapCache".localize(), action: UIAction(){ action in
            self.deleteAllTiles()
        })
        contentView.addSubviewBelow(clearTileCacheButton, upperView: saveButton)
        let clearCurrentTileCacheButton = UIButton(name: "clearCurrentMapCache".localize(), action: UIAction(){ action in
            self.deleteCurrentTiles()
        })
        contentView.addSubviewBelow(clearCurrentTileCacheButton, upperView: clearTileCacheButton)
            .connectToBottom(of: contentView)
    }
    
    func save(){
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
            Settings.shared.save()
            Settings.shared.assertTileDir()
            showDone(title: "ok".localize(), text: "mapSourceSaved".localize())
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

    

