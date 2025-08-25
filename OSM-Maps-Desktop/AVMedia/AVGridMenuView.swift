/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

protocol AVGridMenuDelegate: GridMenuDelegate{
    
    func toggleSelectAll()
    func importMediaFromPhotos()
    func importMediaFromFiles()
    func deleteSelected()
}

class AVGridMenuView: NSView{
    
    var selectAllButton: NSButton!
    var increaseSizeButton: NSButton!
    var decreaseSizeButton: NSButton!
    var importMediaFromPhotosButton: NSButton!
    var importMediaFromFilesButton: NSButton!
    var deleteButton: NSButton!
    
    var delegate: AVGridMenuDelegate? = nil
    
    var insets = OSInsets(top: 10, left: 5, bottom: 10, right: 5)
    
    init(){
        super.init(frame: .zero)
        selectAllButton = NSButton(icon: "checkmark.square", target: self, action: #selector(toggleSelectAll))
        selectAllButton.toolTip = "selectAll".localize()
        increaseSizeButton = NSButton(icon: "plus", target: self, action: #selector(increasePreviewSize))
        increaseSizeButton.toolTip = "increaseImageSize".localize()
        decreaseSizeButton = NSButton(icon: "minus", target: self, action: #selector(decreasePreviewSize))
        decreaseSizeButton.toolTip = "decreaseImageSize".localize()
        importMediaFromPhotosButton = NSButton(icon: "photo.badge.plus", target: self, action: #selector(importMediaFromPhotos))
        importMediaFromPhotosButton.toolTip = "importMediaFromPhotos".localize()
        importMediaFromFilesButton = NSButton(icon: "photo.badge.plus.fill", target: self, action: #selector(importMediaFromFiles))
        importMediaFromFilesButton.toolTip = "importMediaFromFiles".localize()
        deleteButton = NSButton(icon: "trash.square", color: .systemRed, target: self, action: #selector(deleteSelected))
        deleteButton.toolTip = "deleteSelectedImages".localize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView(){
        addSubviewBelow(selectAllButton, insets: insets)
        addSubviewBelow(increaseSizeButton, upperView: selectAllButton, insets: insets)
        addSubviewBelow(decreaseSizeButton, upperView: increaseSizeButton, insets: insets)
        addSubviewBelow(importMediaFromPhotosButton, upperView: decreaseSizeButton, insets: insets)
        addSubviewBelow(importMediaFromFilesButton, upperView: importMediaFromPhotosButton, insets: insets)
        addSubviewBelow(deleteButton, upperView: importMediaFromFilesButton, insets: insets)
    }
    
    @objc func toggleSelectAll(){
        delegate?.toggleSelectAll()
    }
    
    @objc func increasePreviewSize() {
        delegate?.increasePreviewSize()
    }
    
    @objc func decreasePreviewSize() {
        delegate?.decreasePreviewSize()
    }
    
    @objc func importMediaFromPhotos(){
        delegate?.importMediaFromPhotos()
    }
    
    @objc func importMediaFromFiles(){
        delegate?.importMediaFromFiles()
    }
    
    @objc func deleteSelected(){
        delegate?.deleteSelected()
    }
    
}
    
