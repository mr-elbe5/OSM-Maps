/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import AVFoundation
import CoreLocation
import PhotosUI

class ImagePicker: NSObject  {
    
    static var shared: ImagePicker?
    
    var controller: UIViewController
    var atCenter: Bool = false
    var completionHandler: (() -> Void)?
    
    init(controller: UIViewController){
        self.controller = controller
    }
    
    func addImagesFromPhotos(atCenter: Bool, onCompletion: (() -> Void)? = nil) {
        self.atCenter = atCenter
        self.completionHandler = onCompletion
        PHPhotoLibrary.checkAuthorization() { success in
            DispatchQueue.main.async {
                var configuration = PHPickerConfiguration(photoLibrary: .shared())
                configuration.filter = PHPickerFilter.any(of: [.images])
                configuration.preferredAssetRepresentationMode = .automatic
                configuration.selection = .ordered
                configuration.selectionLimit = 0
                let picker = PHPickerViewController(configuration: configuration)
                let size = MainViewController.shared.view.frame.size
                picker.view.frame.size = CGSize(width: max(600, size.width - 100), height: max(400, size.height - 100))
                picker.delegate = self
                self.controller.present(picker, animated: true)
            }
        }
    }
    
    func addImagesFromFiles(atCenter: Bool, onCompletion: (() -> Void)? = nil) {
        self.atCenter = atCenter
        self.completionHandler = onCompletion
        let documentPickerController = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.image])
        documentPickerController.delegate = self
        controller.present(documentPickerController, animated: true, completion: nil)
    }
    
}

extension ImagePicker: PHPickerViewControllerDelegate{
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        for result in results{
            var location: CLLocation? = nil
            var creationDate : Date? = nil
            if let ident = result.assetIdentifier{
                if let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [ident], options: nil).firstObject{
                    location = fetchResult.location
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
                    if let url = url {
                        let image = ImageItem()
                        if let data = FileManager.default.readFile(url: url), let img = OSImage(data: data){
                            image.originalFileName = url.lastPathComponent
                            image.generateFileName()
                            image.loadMetaData(from: data)
                            if let dateTime = image.metaData!.dateTime{
                                image.creationDate = dateTime
                            }
                            else if let date = creationDate{
                                image.creationDate = date
                            }
                            if self.atCenter{
                                image.coordinate = MapStatus.shared.centerCoordinate
                                image.metaData?.latitude = image.coordinate.latitude
                                image.metaData?.longitude = image.coordinate.longitude
                                if let data = image.updateData(data), image.saveImageAndCreatePreview(data: data){
                                    AppData.shared.addItem(image)
                                    AppData.shared.sortItemsByDate(ascending: ViewFilter.shared.defaultSortAscending)
                                    AppData.shared.save()
                                    DispatchQueue.main.async {
                                        self.completionHandler?()
                                    }
                                }
                            }
                            else if let coordinate = location?.coordinate{
                                image.coordinate = coordinate
                                image.metaData?.latitude = image.coordinate.latitude
                                image.metaData?.longitude = image.coordinate.longitude
                                if image.copyImageAndCreatePreview(from: url, original: img){
                                    AppData.shared.addItem(image)
                                    AppData.shared.sortItemsByDate(ascending: ViewFilter.shared.defaultSortAscending)
                                    AppData.shared.save()
                                    DispatchQueue.main.async {
                                        MainViewController.shared.updateItemLayer()
                                    }
                                }
                            }
                        }
                    }
                    else{
                        Log.error("invalid image, not imported")
                    }
                }
            }
        }
        picker.dismiss(animated: false)
        completionHandler?()
        Self.shared = nil
    }
    
}

extension ImagePicker : UIDocumentPickerDelegate{
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first{
            if url.startAccessingSecurityScopedResource(){
                if let data = FileManager.default.readFile(url: url){
                    let image = ImageItem()
                    if atCenter{
                        image.coordinate = MapStatus.shared.centerCoordinate
                    }
                    image.originalFileName = url.lastPathComponent
                    image.generateFileName()
                    image.loadMetaData(from: data)
                    image.creationDate = image.metaData!.dateTime ?? Date()
                    if image.hasValidCoordinate{
                        image.metaData!.latitude = image.coordinate.latitude
                        image.metaData!.longitude = image.coordinate.longitude
                    }
                    if let newData = image.updateData(data), image.saveImageAndCreatePreview(data: newData){
                        AppData.shared.addItem(image)
                        AppData.shared.sortItemsByDate(ascending: ViewFilter.shared.defaultSortAscending)
                        AppData.shared.save()
                        DispatchQueue.main.async {
                            MainViewController.shared.updateItemLayer()
                        }
                    }
                }
                url.stopAccessingSecurityScopedResource()
            }
        }
        completionHandler?()
        Self.shared = nil
    }
    
}






