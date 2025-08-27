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
    
    var frameSize = CGSize(width: 300, height: 300)
    
    init(coordinate: CLLocationCoordinate2D, title: String){
        self.coordinate = coordinate
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.setRoundedBorders(radius: 10)
        view.backgroundColor = .systemBackground
        let label = UILabel(header: title!)
        view.addSubviewCenteredBelow(label)
        let closeButton = IconButton(icon: "xmark", tintColor: .label)
        view.addSubviewWithAnchors(closeButton, top: view.topAnchor, trailing: view.trailingAnchor)
        closeButton.addAction(UIAction(){ action in
            self.dismiss(animated: true)
        }, for: .touchDown)
        locationLabel.textAlignment = .center
        view.addSubviewCenteredBelow(locationLabel, upperView: label)
        let coordinateLabel = UILabel(text: coordinate.asString)
        view.addSubviewCenteredBelow(coordinateLabel, upperView: locationLabel)
        
        let hint = UILabel(hint: "addAtCenterHint".localize(table: "Hints"))
        hint .textAlignment = .center
        view.addSubviewWithAnchors(hint, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: view.bottomAnchor)
        let addVideosButton = TextButton(text: "addVideo".localize())
        addVideosButton.menu = getVideosMenu()
        addVideosButton.showsMenuAsPrimaryAction = true
        view.addSubviewWithAnchors(addVideosButton, bottom: hint.topAnchor)
            .centerX(view.centerXAnchor)
        let addImagesButton = TextButton(text: "addImages".localize())
        addImagesButton.menu = getImagesMenu()
        addImagesButton.showsMenuAsPrimaryAction = true
        view.addSubviewWithAnchors(addImagesButton, bottom: addVideosButton.topAnchor)
            .centerX(view.centerXAnchor)
        let addNoteButton = TextButton(text: "addNote".localize())
        addNoteButton.addAction(UIAction(){ action in
            self.dismiss(animated: false)
            let item = NoteItem(coordinate: self.coordinate)
            let controller = EditNoteViewController(item: item)
            controller.delegate = self
            MainViewController.shared.navigationController?.pushViewController(controller, animated: true)
        }, for: .touchDown)
        view.addSubviewWithAnchors(addNoteButton, bottom: addImagesButton.topAnchor)
            .centerX(view.centerXAnchor)
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
    
    override func viewWillAppear(_ animated: Bool) {
        view.frame = CGRect(origin: CGPoint(x: view.frame.width/2 - frameSize.width/2, y: view.frame.height/2 - frameSize.height/2), size: frameSize)
    }
    
    func getImagesMenu() -> UIMenu {
        var actions = Array<UIAction>()
        actions.append(UIAction(title: "fromPhotoLibrary".localize(), image: UIImage(systemName: "photo.stack")){ action in
            self.importImagesFromPhotoLibrary()
        })
        actions.append(UIAction(title: "fromFiles".localize(), image: UIImage(systemName: "folder")){ action in
            self.importImagesFromFiles()
        })
        return UIMenu(title: "", children: actions)
    }
    
    func getVideosMenu() -> UIMenu {
        var actions = Array<UIAction>()
        actions.append(UIAction(title: "fromPhotoLibrary".localize(), image: UIImage(systemName: "photo.stack")){ action in
            self.importVideosFromPhotoLibrary()
        })
        actions.append(UIAction(title: "fromFiles".localize(), image: UIImage(systemName: "folder")){ action in
            self.importVideosFromFiles()
        })
        return UIMenu(title: "", children: actions)
    }
    
    func importImagesFromPhotoLibrary() {
        ImagePicker.shared = ImagePicker(controller: self)
        ImagePicker.shared?.addImagesFromPhotos(atCenter: true){
            MainViewController.shared.updateItemLayer()
        }
    }
    
    func importImagesFromFiles() {
        ImagePicker.shared = ImagePicker(controller: self)
        ImagePicker.shared?.addImagesFromFiles(atCenter: true)
        {
            MainViewController.shared.updateItemLayer()
        }
    }
    
    func importVideosFromPhotoLibrary() {
        VideoPicker.shared = VideoPicker(controller: self)
        VideoPicker.shared?.addVideosFromPhotos(atCenter: true){
            MainViewController.shared.updateItemLayer()
        }
    }
    
    func importVideosFromFiles() {
        VideoPicker.shared = VideoPicker(controller: self)
        VideoPicker.shared?.addVideosFromFiles(atCenter: true)
        {
            MainViewController.shared.updateItemLayer()
        }
    }
    
}

extension CrossMenuViewController : EditNoteDelegate{
    
    func noteChanged(item: NoteItem) {
      // nothing to do
    }
    
}
