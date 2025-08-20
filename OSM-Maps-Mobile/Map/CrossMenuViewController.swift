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
    
    var frameSize = CGSize(width: 300, height: 250)
    
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
        let addImagesButton = UIButton().asTextButton("addImages".localize()).withTextColor(color: .systemBlue).withRoundedCorners()
        addImagesButton.menu = getImagesMenu()
        addImagesButton.showsMenuAsPrimaryAction = true
        view.addSubviewWithAnchors(addImagesButton, bottom: hint.topAnchor)
            .centerX(view.centerXAnchor)
        let addNoteButton = UIButton().asTextButton("addNote".localize()).withTextColor(color: .systemBlue).withRoundedCorners()
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
    
    func importImagesFromPhotoLibrary() {
        PHPhotoLibrary.checkAuthorization() { success in
            DispatchQueue.main.async {
                var configuration = PHPickerConfiguration(photoLibrary: .shared())
                configuration.filter = PHPickerFilter.any(of: [.images])
                configuration.preferredAssetRepresentationMode = .automatic
                configuration.selection = .ordered
                configuration.selectionLimit = 0
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = self
                self.present(picker, animated: true)
            }
        }
    }
    
    func importImagesFromFiles() {
        let documentPickerController = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.image])
        documentPickerController.delegate = self
        self.present(documentPickerController, animated: true, completion: nil)
    }
    
}

extension CrossMenuViewController: PHPickerViewControllerDelegate{
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        for result in results{
            var creationDate : Date? = nil
            if let ident = result.assetIdentifier{
                if let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [ident], options: nil).firstObject{
                    creationDate = fetchResult.creationDate
                    if fetchResult.mediaType != .image{
                        continue
                    }
                }
            }
            let itemProvider = result.itemProvider
            itemProvider.loadFileRepresentation(forTypeIdentifier: "public.image") { (url, error) in
                if error != nil {
                   print("error \(error!)");
                } else {
                    if let url = url, let data = FileManager.default.readFile(url: url) {
                        let image = ImageItem(coordinate: self.coordinate)
                        image.creationDate = creationDate ?? Date()
                        image.updateLocation()
                        image.originalFileName = url.lastPathComponent
                        image.generateFileName()
                        image.loadMetaData(from: data)
                        image.metaData!.latitude = self.coordinate.latitude
                        image.metaData!.longitude = self.coordinate.longitude
                        if let newData = image.updateData(data), image.saveImageAndCreatePreview(data: newData){
                            AppData.shared.addItem(image)
                            AppData.shared.sortItemsByDate(ascending: ViewFilter.shared.defaultSortAscending)
                            DispatchQueue.main.async {
                                MainViewController.shared.updateItemLayer()
                            }
                        }
                    }
                }
            }
        }
        picker.dismiss(animated: false)
        self.dismiss(animated: false)
    }
    
}

extension CrossMenuViewController : UIDocumentPickerDelegate{
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first{
            if url.startAccessingSecurityScopedResource(){
                if let data = FileManager.default.readFile(url: url){
                    let image = ImageItem(coordinate: coordinate)
                    image.originalFileName = url.lastPathComponent
                    image.generateFileName()
                    image.loadMetaData(from: data)
                    image.creationDate = image.metaData!.dateTime ?? Date()
                    image.metaData!.latitude = coordinate.latitude
                    image.metaData!.longitude = coordinate.longitude
                    if let newData = image.updateData(data), image.saveImageAndCreatePreview(data: newData){
                        AppData.shared.addItem(image)
                        AppData.shared.sortItemsByDate(ascending: ViewFilter.shared.defaultSortAscending)
                        DispatchQueue.main.async {
                            MainViewController.shared.updateItemLayer()
                        }
                    }
                }
                url.stopAccessingSecurityScopedResource()
            }
        }
        self.dismiss(animated: false)
    }
    
}

extension CrossMenuViewController : EditNoteDelegate{
    
    func noteChanged(item: NoteItem) {
      // nothing to do
    }
    
}
