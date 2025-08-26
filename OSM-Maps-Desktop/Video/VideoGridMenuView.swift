/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

protocol VideoGridMenuDelegate: GridMenuDelegate{
    
    func toggleSelectAll()
    func showSelected()
    func importVideosFromPhotos()
    func importVideosFromFiles()
    func deleteSelected()
}

class VideoGridMenuView: NSView{
    
    var selectAllButton: NSButton!
    var showPresenterButton: NSButton!
    var increaseSizeButton: NSButton!
    var decreaseSizeButton: NSButton!
    var importVideosFromPhotosButton: NSButton!
    var importVideosFromFilesButton: NSButton!
    var deleteButton: NSButton!
    
    var delegate: VideoGridMenuDelegate? = nil
    
    var insets = OSInsets(top: 10, left: 5, bottom: 10, right: 5)
    
    init(){
        super.init(frame: .zero)
        selectAllButton = NSButton(icon: "checkmark.square", target: self, action: #selector(toggleSelectAll))
        selectAllButton.toolTip = "selectAll".localize()
        showPresenterButton = NSButton(icon: "video", target: self, action: #selector(showSelected))
        showPresenterButton.toolTip = "showSelectedVideos".localize()
        increaseSizeButton = NSButton(icon: "plus", target: self, action: #selector(increasePreviewSize))
        increaseSizeButton.toolTip = "increaseImageSize".localize()
        decreaseSizeButton = NSButton(icon: "minus", target: self, action: #selector(decreasePreviewSize))
        decreaseSizeButton.toolTip = "decreaseImageSize".localize()
        importVideosFromPhotosButton = NSButton(icon: "video.badge.plus", target: self, action: #selector(importVideosFromPhotos))
        importVideosFromPhotosButton.toolTip = "importVideosFromPhotos".localize()
        importVideosFromFilesButton = NSButton(icon: "video.badge.plus.fill", target: self, action: #selector(importVideosFromFiles))
        importVideosFromFilesButton.toolTip = "importVideosFromFiles".localize()
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
        addSubviewBelow(importVideosFromPhotosButton, upperView: decreaseSizeButton, insets: insets)
        addSubviewBelow(importVideosFromFilesButton, upperView: importVideosFromPhotosButton, insets: insets)
        addSubviewBelow(deleteButton, upperView: importVideosFromFilesButton, insets: insets)
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
    
    @objc func importVideosFromPhotos(){
        delegate?.importVideosFromPhotos()
    }
    
    @objc func importVideosFromFiles(){
        delegate?.importVideosFromFiles()
    }
    
    @objc func deleteSelected(){
        delegate?.deleteSelected()
    }
    
}
    
