/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

protocol VideoGridMenuDelegate: GridMenuDelegate{
    func showSelected()
    func importVideosFromPhotos()
    func importVideosFromFiles()
}

class VideoGridMenuView: GridMenuView{
    
    var showPresenterButton: NSButton!
    var importVideosFromPhotosButton: NSButton!
    var importVideosFromFilesButton: NSButton!
    
    override init(){
        super.init()
        showPresenterButton = NSButton(icon: "photo", target: self, action: #selector(showSelected))
        showPresenterButton.toolTip = "showSelectedImages".localize()
        importVideosFromPhotosButton = NSButton(icon: "video.badge.plus", target: self, action: #selector(importVideosFromPhotos))
        importVideosFromPhotosButton.toolTip = "importVideosFromPhotos".localize()
        importVideosFromFilesButton = NSButton(icon: "video.badge.plus.fill", target: self, action: #selector(importVideosFromFiles))
        importVideosFromFilesButton.toolTip = "importVideosFromFiles".localize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView(){
        addSubviewBelow(selectButton, insets: insets)
        addSubviewBelow(showButton, upperView: selectButton, insets: insets)
        addSubviewBelow(showPresenterButton, upperView: showButton, insets: insets)
        addSubviewBelow(increaseSizeButton, upperView: showPresenterButton, insets: insets)
        addSubviewBelow(decreaseSizeButton, upperView: increaseSizeButton, insets: insets)
        addSubviewBelow(importVideosFromPhotosButton, upperView: decreaseSizeButton, insets: insets)
        addSubviewBelow(importVideosFromFilesButton, upperView: importVideosFromPhotosButton, insets: insets)
        addSubviewBelow(deleteButton, upperView: importVideosFromFilesButton, insets: insets)
    }
    
    @objc func showSelected(){
        (delegate as? VideoGridMenuDelegate)?.showSelected()
    }
    
    @objc func importVideosFromPhotos(){
        (delegate as? VideoGridMenuDelegate)?.importVideosFromPhotos()
    }
    
    @objc func importVideosFromFiles(){
        (delegate as? VideoGridMenuDelegate)?.importVideosFromFiles()
    }
    
}
    
