/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation

class CrossButtonMenu: PopoverViewController {
    
    override func loadView() {
        let menuView = CrossButtonMenuView(controller: self)
        menuView.setupView()
        menuView.width(250)
        view = menuView
        menuView.setupView()
    }
    
    func addNote(text: String){
        close()
        MainViewController.shared.addNoteAtCenter(text: text)
    }
    
    func addImagesFromPhotos(){
        close()
        MainViewController.shared.addImagesFromPhotosAtCenter(){
            MainViewController.shared.itemsChanged()
        }
    }
    
    func addImagesFromFiles(){
        close()
        MainViewController.shared.addImagesFromFilesAtCenter(){
            MainViewController.shared.itemsChanged()
        }
    }
    
    func addVideosFromPhotos(){
        close()
        MainViewController.shared.addVideosFromPhotosAtCenter(){
            MainViewController.shared.itemsChanged()
        }
    }
    
    func addVideosFromFiles(){
        close()
        MainViewController.shared.addVideosFromFilesAtCenter(){
            MainViewController.shared.itemsChanged()
        }
    }
    
}

class CrossButtonMenuView: PopoverView{
    
    var nameLabel =  NSTextField(labelWithString: "unknownLocation".localize())
    
    override func setupView(){
        backgroundColor = PopoverViewController.backgroundColor
        let coordinate = MapStatus.shared.centerCoordinate
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        addSubviewCenteredBelow(nameLabel)
        let coordinateLabel = NSTextField(labelWithString: location.coordinate.asString)
        addSubviewCenteredBelow(coordinateLabel, upperView: nameLabel)
        let noteButton = NSButton(title: "addNote".localize(), target: self, action: #selector(addNoteAtCenter))
        noteButton.bezelColor = PopoverViewController.bezelColor
        addSubviewCenteredBelow(noteButton, upperView: coordinateLabel)
        let photoImageButton = NSButton(title: "addImagesFromPhotoLibrary".localize(), target: self, action: #selector(addImagesFromPhotosAtCenter))
        photoImageButton.bezelColor = PopoverViewController.bezelColor
        addSubviewCenteredBelow(photoImageButton, upperView: noteButton)
        let fileImageButton = NSButton(title: "addImagesFromFileSystem".localize(), target: self, action: #selector(addImagesFromFilesAtCenter))
        fileImageButton.bezelColor = PopoverViewController.bezelColor
        addSubviewCenteredBelow(fileImageButton, upperView: photoImageButton)
        let photoVideoButton = NSButton(title: "addVideosFromPhotoLibrary".localize(), target: self, action: #selector(addVideosFromPhotosAtCenter))
        photoVideoButton.bezelColor = PopoverViewController.bezelColor
        addSubviewCenteredBelow(photoVideoButton, upperView: fileImageButton)
        let fileVideoButton = NSButton(title: "addVideosFromFileSystem".localize(), target: self, action: #selector(addVideosFromFilesAtCenter))
        fileVideoButton.bezelColor = PopoverViewController.bezelColor
        addSubviewCenteredBelow(fileVideoButton, upperView: photoVideoButton)
        let hint = NSTextField(wrappingLabelWithString: "addAtCenterHint".localize(table: "Hints"))
        hint.font = .systemFont(ofSize: 12)
        addSubviewBelow(hint, upperView: fileVideoButton)
            .connectToBottom(of: self)
        CLPlacemark.getPlacemark(for: location){ placemark in
            if let locationmark = placemark{
                self.nameLabel.stringValue = locationmark.asString
            } else{
                self.nameLabel.stringValue = location.coordinate.asString
            }
            
        }
    }
    
    @objc func addNoteAtCenter(){
        (controller as! CrossButtonMenu).addNote(text: nameLabel.stringValue)
    }
    
    @objc func addImagesFromPhotosAtCenter(){
        (controller as! CrossButtonMenu).addImagesFromPhotos()
    }
    
    @objc func addImagesFromFilesAtCenter(){
        (controller as! CrossButtonMenu).addImagesFromFiles()
    }
    
    @objc func addVideosFromPhotosAtCenter(){
        (controller as! CrossButtonMenu).addVideosFromPhotos()
    }
    
    @objc func addVideosFromFilesAtCenter(){
        (controller as! CrossButtonMenu).addVideosFromFiles()
    }
    
}
