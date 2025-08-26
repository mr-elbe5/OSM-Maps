/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation

class CrossButtonMenu: PopoverViewController, CrossButtonViewDelegate {
    
    init(mapView: MapView){
        super.init()
        let menuView = CrossButtonMenuView()
        menuView.setupView()
        menuView.width(250)
        menuView.delegate = self
        contentView = menuView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addNote(text: String){
        close()
        MainViewController.shared.addNoteAtCenter(text: text)
    }
    
    func addImagesFromPhotos(){
        close()
        MainViewController.shared.addImagesFromPhotosAtCenter(){
            MainViewController.shared.updateItemLayer()
        }
    }
    
    func addImagesFromFiles(){
        close()
        MainViewController.shared.addImagesFromFilesAtCenter(){
            MainViewController.shared.updateItemLayer()
        }
    }
    
    func addVideosFromPhotos(){
        close()
        MainViewController.shared.addVideosFromPhotosAtCenter(){
            MainViewController.shared.updateItemLayer()
        }
    }
    
    func addVideosFromFiles(){
        close()
        MainViewController.shared.addVideosFromFilesAtCenter(){
            MainViewController.shared.updateItemLayer()
        }
    }
    
}

protocol CrossButtonViewDelegate{
    func addNote(text: String)
    func addImagesFromPhotos()
    func addImagesFromFiles()
    func addVideosFromPhotos()
    func addVideosFromFiles()
}

class CrossButtonMenuView: NSView{
    
    var nameLabel =  NSTextField(labelWithString: "unknownLocation".localize())
    
    var delegate: CrossButtonViewDelegate?
    
    override func setupView(){
        backgroundColor = PopoverViewController.backgroundColor
        let coordinate = MapStatus.shared.centerCoordinate
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        addSubviewCenteredBelow(nameLabel)
        let coordinateLabel = NSTextField(labelWithString: location.coordinate.asString)
        addSubviewCenteredBelow(coordinateLabel, upperView: nameLabel)
        let noteButton = NSButton(title: "addNote".localize(), target: self, action: #selector(addNote))
        noteButton.bezelColor = PopoverViewController.bezelColor
        addSubviewCenteredBelow(noteButton, upperView: coordinateLabel)
        let photoImageButton = NSButton(title: "addImagesFromPhotoLibrary".localize(), target: self, action: #selector(addImagesFromPhotos))
        photoImageButton.bezelColor = PopoverViewController.bezelColor
        addSubviewCenteredBelow(photoImageButton, upperView: noteButton)
        let fileImageButton = NSButton(title: "addImagesFromFileSystem".localize(), target: self, action: #selector(addImagesFromFiles))
        fileImageButton.bezelColor = PopoverViewController.bezelColor
        addSubviewCenteredBelow(fileImageButton, upperView: photoImageButton)
        let photoVideoButton = NSButton(title: "addVideosFromPhotoLibrary".localize(), target: self, action: #selector(addVideosFromPhotos))
        photoVideoButton.bezelColor = PopoverViewController.bezelColor
        addSubviewCenteredBelow(photoVideoButton, upperView: fileImageButton)
        let fileVideoButton = NSButton(title: "addVideosFromFileSystem".localize(), target: self, action: #selector(addVideosFromFiles))
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
    
    @objc func addNote(){
        delegate?.addNote(text: nameLabel.stringValue)
    }
    
    @objc func addImagesFromPhotos(){
        delegate?.addImagesFromPhotos()
    }
    
    @objc func addImagesFromFiles(){
        delegate?.addImagesFromFiles()
    }
    
    @objc func addVideosFromPhotos(){
        delegate?.addVideosFromPhotos()
    }
    
    @objc func addVideosFromFiles(){
        delegate?.addVideosFromFiles()
    }
    
}
