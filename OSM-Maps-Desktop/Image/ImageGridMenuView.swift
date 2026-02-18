/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

protocol ImageGridMenuDelegate: GridMenuDelegate{
    func showSelected()
    func importImagesFromPhotos()
    func importImagesFromFiles()
}

class ImageGridMenuView: GridMenuView{
    
    var showPresenterButton: NSButton!
    var importImagesFromPhotosButton: NSButton!
    var importImagesFromFilesButton: NSButton!
    
    override init(){
        super.init()
        showPresenterButton = NSButton(icon: "photo", target: self, action: #selector(showSelected))
        showPresenterButton.toolTip = "showSelectedImages".localize()
        importImagesFromPhotosButton = NSButton(icon: "photo.badge.plus", target: self, action: #selector(importImagesFromPhotos))
        importImagesFromPhotosButton.toolTip = "importImagesFromPhotos".localize()
        importImagesFromFilesButton = NSButton(icon: "photo.badge.plus.fill", target: self, action: #selector(importImagesFromFiles))
        importImagesFromFilesButton.toolTip = "importImagesFromFiles".localize()
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
        addSubviewBelow(importImagesFromPhotosButton, upperView: decreaseSizeButton, insets: insets)
        addSubviewBelow(importImagesFromFilesButton, upperView: importImagesFromPhotosButton, insets: insets)
        addSubviewBelow(deleteButton, upperView: importImagesFromFilesButton, insets: insets)
    }
    
    @objc func showSelected() {
        (delegate as? ImageGridMenuDelegate)?.showSelected()
    }
    
    @objc func importImagesFromPhotos(){
        (delegate as? ImageGridMenuDelegate)?.importImagesFromPhotos()
    }
    
    @objc func importImagesFromFiles(){
        (delegate as? ImageGridMenuDelegate)?.importImagesFromFiles()
    }
    
}
    
