/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class TileSourceViewController: ScrollViewController{
    
    var nameField = LabeledTextField()
    var tileUrlTemplateField = LabeledTextField()
    
    var overlaySelectPanel = UIView()
    
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
        let useLabel = UILabel(text: "use".localizeWithColon())
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
                TileSources.shared.save()
                self.loadScrollableSubviews()
            }, for: .touchDown)
            contentView.addSubviewWithAnchors(deleteButton, leading: button.trailingAnchor, insets: .flatInsets)
                .centerY(button.centerYAnchor)
            lastView = button
        }
        
        let saveButton = UIButton()
        saveButton.setTitle("save".localize(), for: .normal)
        saveButton.setTitleColor(.systemBlue, for: .normal)
        saveButton.addAction(UIAction(){ action in
            self.save()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(saveButton, top: lastView.bottomAnchor, insets: .doubleInsets)
        .centerX(contentView.centerXAnchor)
        
        var label = UILabel(header: "overlays".localizeWithColon())
        contentView.addSubviewBelow(label, upperView: saveButton)
        setupOverlaySelectPanel()
        contentView.addSubviewBelow(overlaySelectPanel, upperView: label)
        
        label = UILabel(text: "newOverlay".localizeWithColon())
        contentView.addSubviewBelow(label, upperView: overlaySelectPanel)
        overlayNameField.setupView(labelText: "overlayName".localize(), text: "", isHorizontal: false)
        contentView.addSubviewBelow(overlayNameField, upperView: label, insets: .defaultInsets)
        overlayUrlTemplateField.setupView(labelText: "templateURL".localize(), text: "", isHorizontal: false)
        contentView.addSubviewBelow(overlayUrlTemplateField, upperView: overlayNameField, insets: .defaultInsets)
        let addNewOverlayButton = UIButton(name: "add".localize(), action: UIAction(){ action in
            self.addNewOverlay()
        })
        contentView.addSubviewBelow(addNewOverlayButton, upperView: overlayUrlTemplateField)
        lastView = addNewOverlayButton
        
        let hintText = UILabel(text: "tileServerHint".localize())
        hintText.numberOfLines = 0
        hintText.font = .preferredFont(forTextStyle: .footnote)
        contentView.addSubviewBelow(hintText, upperView: lastView, insets: .flatInsets)
        
        let setDefaultsButton = UIButton(name: "setDefaults".localize(), action: UIAction(){ action in
            self.setDefaults()
        })
        contentView.addSubviewBelow(setDefaultsButton, upperView: hintText)
        lastView = setDefaultsButton
        if WatchConnector.shared.isWatchConnected {
            let watchButton = UIButton(name: "sendToWatch".localize(), action: UIAction(){ action in
                self.sendToWatch()
            })
            contentView.addSubviewBelow(watchButton, upperView: lastView)
            lastView = watchButton
        }
        let clearTileCacheButton = UIButton(name: "clearTileCache".localize(), action: UIAction(){ action in
            self.deleteAllTiles()
        })
        contentView.addSubviewBelow(clearTileCacheButton, upperView: lastView)
        let clearCurrentTileCacheButton = UIButton(name: "clearCurrentTileCache".localize(), action: UIAction(){ action in
            self.deleteCurrentTiles()
        })
        contentView.addSubviewBelow(clearCurrentTileCacheButton, upperView: clearTileCacheButton)
            .connectToBottom(of: contentView)
    }
    
    func setupOverlaySelectPanel(){
        var lastLine: UIView? = nil
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
    
    func addNewOverlay(){
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
                        self.showAlert(title: "error".localize(), text: "sourceNotFound".localize())
                    }
                }
            }
            
        }
    }
    
    func save(){
        saveTileSource()
        Settings.shared.save()
        Settings.shared.assertTileDirs()
        self.showDone(title: "ok".localize(), text: "mapSourceSaved".localize())
        MainViewController.shared.mapView.refresh()
    }
    
    func saveTileSource(){
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
    
    func setDefaults(){
        TileSources.setDefaults()
        OverlayTileSources.setDefaults()
        
        self.loadScrollableSubviews()
    }
    
    func sendToWatch(){
        WatchConnector.shared.sendTileSources(){ success in
            self.showDone(title: "tileSourcesSent".localize(), text: "tileSourcesSentText".localize())
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

extension TileSourceViewController: OverlayLineDelegate{
    
    func selectionChanged(){
        for sv in overlaySelectPanel.subviews{
            if let ol = sv as? OverlayLine{
                ol.source.active = ol.switchView.isOn
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

class OverlayLine: UIView{
    
    var source: OverlayTileSource
    
    var label: UILabel!
    var switchView: UISwitch!
    var upButton: UIButton
    var deleteButton: UIButton
    
    var delegate: OverlayLineDelegate?
    
    init(source: OverlayTileSource) {
        self.source = source
        label = UILabel(text: source.name)
        switchView = UISwitch()
        switchView.preferredStyle = .checkbox
        upButton = UIButton().asIconButton("arrow.up")
        deleteButton = UIButton().asIconButton("trash", color: .systemRed)
        super.init(frame: .zero)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(){
        height(20)
        addSubviewWithAnchors(label, leading: leadingAnchor, insets: .zero).centerY(centerYAnchor)
        addSubviewWithAnchors(switchView, leading: label.trailingAnchor).centerY(centerYAnchor)
        
        addSubviewWithAnchors(deleteButton, trailing: trailingAnchor).centerY(centerYAnchor)
        addSubviewWithAnchors(upButton, trailing: deleteButton.leadingAnchor).centerY(centerYAnchor)
        
        switchView.addAction(UIAction(){ action in
            self.source.active = self.switchView.isOn
            self.delegate?.selectionChanged()
        }, for: .valueChanged)
        switchView.isOn = source.active
        upButton.addAction(UIAction(){ action in
            self.delegate?.moveSourceUp(self)
        }, for: .touchDown)
        upButton.isEnabled = source.idx > 0
        deleteButton.addAction(UIAction(){ action in
            self.delegate?.removeSource(self)
        }, for: .touchDown)
    }
    
}



    

