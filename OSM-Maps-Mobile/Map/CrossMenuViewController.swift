/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import PhotosUI

class CrossMenuViewController: UIViewController{
    
    var coordinate: CLLocationCoordinate2D
    
    let locationLabel = UILabel(text: "")
    
    init(coordinate: CLLocationCoordinate2D, title: String){
        self.coordinate = coordinate
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .clear
        let contentView = UIView()
        contentView.backgroundColor = .systemBackground
        view.addSubviewCentered(contentView, centerX: view.centerXAnchor, centerY: view.centerYAnchor)
            .width(300)
            .height(350)
        contentView.setRoundedBorders(radius: 10)
        
        let label = UILabel(header: title!)
        contentView.addSubviewCenteredBelow(label)
        let closeButton = IconButton(icon: "xmark", tintColor: .label)
        contentView.addSubviewWithAnchors(closeButton, top: contentView.topAnchor, trailing: contentView.trailingAnchor)
        closeButton.addAction(UIAction(){ action in
            self.dismiss(animated: true)
        }, for: .touchDown)
        locationLabel.textAlignment = .center
        contentView.addSubviewCenteredBelow(locationLabel, upperView: label)
        let coordinateLabel = UILabel(text: coordinate.asString)
        contentView.addSubviewCenteredBelow(coordinateLabel, upperView: locationLabel)
        
        let hint = UILabel(hint: "addAtCenterHint".localize(table: "Hints"))
        hint .textAlignment = .center
        contentView.addSubviewWithAnchors(hint, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, bottom: contentView.bottomAnchor)
        let addVideosButton = TextButton(text: "addVideo".localize())
        addVideosButton.menu = getVideosMenu()
        addVideosButton.showsMenuAsPrimaryAction = true
        contentView.addSubviewWithAnchors(addVideosButton, bottom: hint.topAnchor)
            .centerX(contentView.centerXAnchor)
        let addImagesButton = TextButton(text: "addImages".localize())
        addImagesButton.menu = getImagesMenu()
        addImagesButton.showsMenuAsPrimaryAction = true
        contentView.addSubviewWithAnchors(addImagesButton, bottom: addVideosButton.topAnchor)
            .centerX(contentView.centerXAnchor)
        let addNoteButton = TextButton(text: "addNote".localize())
        addNoteButton.addAction(UIAction(){ action in
            self.dismiss(animated: false)
            let item = NoteItem(coordinate: self.coordinate)
            let controller = EditNoteViewController(item: item)
            controller.delegate = self
            MainViewController.shared.navigationController?.pushViewController(controller, animated: true)
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(addNoteButton, bottom: addImagesButton.topAnchor)
            .centerX(contentView.centerXAnchor)
    }
    
    override func viewDidLoad() {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLPlacemark.getPlacemark(for: location){ placemark in
            var str : String
            if let placemark = placemark{
                str = placemark.asString
            } else{
                str = location.coordinate.asString
            }
            self.locationLabel.text = str
        }
    }
    
    func getImagesMenu() -> UIMenu {
        var actions = Array<UIAction>()
        actions.append(UIAction(title: "fromPhotoLibrary".localize(), image: UIImage(systemName: "photo.stack")){ action in
            self.importImagesFromPhotoLibrary(){
                self.dismiss(animated: false)
            }
        })
        actions.append(UIAction(title: "fromFiles".localize(), image: UIImage(systemName: "folder")){ action in
            self.importImagesFromFiles(){
                self.dismiss(animated: false)
            }
        })
        return UIMenu(title: "", children: actions)
    }
    
    func getVideosMenu() -> UIMenu {
        var actions = Array<UIAction>()
        actions.append(UIAction(title: "fromPhotoLibrary".localize(), image: UIImage(systemName: "photo.stack")){ action in
            self.importVideosFromPhotoLibrary(){
                self.dismiss(animated: false)
            }
        })
        actions.append(UIAction(title: "fromFiles".localize(), image: UIImage(systemName: "folder")){ action in
            self.importVideosFromFiles(){
                self.dismiss(animated: false)
            }
        })
        return UIMenu(title: "", children: actions)
    }
    
    func importImagesFromPhotoLibrary(onCompletion: (() -> Void)? = nil) {
        ImagePicker.shared = ImagePicker(controller: self)
        ImagePicker.shared?.addImagesFromPhotos(atCenter: true){
            MainViewController.shared.updateItemLayer()
            onCompletion?()
        }
    }
    
    func importImagesFromFiles(onCompletion: (() -> Void)? = nil) {
        ImagePicker.shared = ImagePicker(controller: self)
        ImagePicker.shared?.addImagesFromFiles(atCenter: true)
        {
            MainViewController.shared.updateItemLayer()
            onCompletion?()
        }
    }
    
    func importVideosFromPhotoLibrary(onCompletion: (() -> Void)? = nil) {
        VideoPicker.shared = VideoPicker(controller: self)
        VideoPicker.shared?.addVideosFromPhotos(atCenter: true){
            MainViewController.shared.updateItemLayer()
            onCompletion?()
        }
    }
    
    func importVideosFromFiles(onCompletion: (() -> Void)? = nil) {
        VideoPicker.shared = VideoPicker(controller: self)
        VideoPicker.shared?.addVideosFromFiles(atCenter: true)
        {
            MainViewController.shared.updateItemLayer()
            onCompletion?()
        }
    }
    
}

extension CrossMenuViewController : EditNoteDelegate{
    
    func noteChanged(item: NoteItem) {
      // nothing to do
    }
    
}
