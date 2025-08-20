/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

protocol ImageGridMenuDelegate: GridMenuDelegate{
    
    func toggleSelectAll()
    func showSelected()
    func importImagesFromPhotos()
    func importImagesFromFiles()
    func deleteSelected()
}

class ImageGridMenuView: NSView{
    
    var selectAllButton: NSButton!
    var showPresenterButton: NSButton!
    var increaseSizeButton: NSButton!
    var decreaseSizeButton: NSButton!
    var importImagesFromPhotosButton: NSButton!
    var importImagesFromFilesButton: NSButton!
    var deleteButton: NSButton!
    
    var delegate: ImageGridMenuDelegate? = nil
    
    var insets = OSInsets(top: 10, left: 5, bottom: 10, right: 5)
    
    init(){
        super.init(frame: .zero)
        selectAllButton = NSButton(icon: "checkmark.square", target: self, action: #selector(toggleSelectAll))
        selectAllButton.toolTip = "selectAll".localize()
        showPresenterButton = NSButton(icon: "photo", target: self, action: #selector(showSelected))
        showPresenterButton.toolTip = "showSelectedImages".localize()
        increaseSizeButton = NSButton(icon: "plus", target: self, action: #selector(increasePreviewSize))
        increaseSizeButton.toolTip = "increaseImageSize".localize()
        decreaseSizeButton = NSButton(icon: "minus", target: self, action: #selector(decreasePreviewSize))
        decreaseSizeButton.toolTip = "decreaseImageSize".localize()
        importImagesFromPhotosButton = NSButton(icon: "photo.badge.plus", target: self, action: #selector(importImagesFromPhotos))
        importImagesFromPhotosButton.toolTip = "importImagesFromPhotos".localize()
        importImagesFromFilesButton = NSButton(icon: "photo.badge.plus.fill", target: self, action: #selector(importImagesFromFiles))
        importImagesFromFilesButton.toolTip = "importImagesFromFiles".localize()
        deleteButton = NSButton(icon: "trash.square", color: .systemRed, target: self, action: #selector(deleteSelected))
        deleteButton.toolTip = "deleteSelectedImages".localize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView(){
        addSubviewBelow(selectAllButton, insets: insets)
        addSubviewBelow(showPresenterButton, upperView: selectAllButton, insets: insets)
        addSubviewBelow(increaseSizeButton, upperView: showPresenterButton, insets: insets)
        addSubviewBelow(decreaseSizeButton, upperView: increaseSizeButton, insets: insets)
        addSubviewBelow(importImagesFromPhotosButton, upperView: decreaseSizeButton, insets: insets)
        addSubviewBelow(importImagesFromFilesButton, upperView: importImagesFromPhotosButton, insets: insets)
        addSubviewBelow(deleteButton, upperView: importImagesFromFilesButton, insets: insets)
    }
    
    @objc func toggleSelectAll(){
        delegate?.toggleSelectAll()
    }
    
    @objc func showSelected(){
        delegate?.showSelected()
    }
    
    @objc func increasePreviewSize() {
        delegate?.increasePreviewSize()
    }
    
    @objc func decreasePreviewSize() {
        delegate?.decreasePreviewSize()
    }
    
    @objc func importImagesFromPhotos(){
        delegate?.importImagesFromPhotos()
    }
    
    @objc func importImagesFromFiles(){
        delegate?.importImagesFromFiles()
    }
    
    @objc func deleteSelected(){
        delegate?.deleteSelected()
    }
    
}
    
