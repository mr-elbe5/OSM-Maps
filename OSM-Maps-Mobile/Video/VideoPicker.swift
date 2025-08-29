/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import AVFoundation
import CoreLocation
import PhotosUI

class VideoPicker: NSObject  {
    
    static var shared: VideoPicker?
    
    var controller: UIViewController
    var atCenter: Bool = false
    var completionHandler: (() -> Void)?
    
    init(controller: UIViewController){
        self.controller = controller
    }
    
    func addVideosFromPhotos(atCenter: Bool, onCompletion: (() -> Void)? = nil) {
        self.atCenter = atCenter
        self.completionHandler = onCompletion
        PHPhotoLibrary.checkAuthorization() { success in
            DispatchQueue.main.async {
                var configuration = PHPickerConfiguration(photoLibrary: .shared())
                configuration.filter = PHPickerFilter.any(of: [.videos])
                configuration.preferredAssetRepresentationMode = .automatic
                configuration.selection = .ordered
                configuration.selectionLimit = 0
                let picker = PHPickerViewController(configuration: configuration)
                let size = MainViewController.shared.view.frame.size
                picker.view.frame.size = CGSize(width: max(600, size.width - 100), height: max(400, size.height - 100))
                picker.delegate = self
                self.controller.present(picker, animated: false)
            }
        }
    }
    
    func addVideosFromFiles(atCenter: Bool, onCompletion: (() -> Void)? = nil) {
        self.atCenter = atCenter
        self.completionHandler = onCompletion
        let documentPickerController = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.movie, UTType.video])
        documentPickerController.delegate = self
        controller.present(documentPickerController, animated: true, completion: nil)
    }
    
}

extension VideoPicker: PHPickerViewControllerDelegate{
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        for result in results{
            var asset: PHAsset? = nil
            if let ident = result.assetIdentifier{
                asset = PHAsset.fetchAssets(withLocalIdentifiers: [ident], options: nil).firstObject
                if asset?.mediaType != .video{
                    continue
                }
            }
            let itemProvider = result.itemProvider
            if itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier){
                itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier){ (url, error) in
                    self.addVideo(url: url, asset: asset)
                }
            }
            if itemProvider.hasItemConformingToTypeIdentifier(UTType.video.identifier){
                itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.video.identifier){ (url, error) in
                    self.addVideo(url: url, asset: asset)
                }
            }
        }
        picker.dismiss(animated: false)
        completionHandler?()
        Self.shared = nil
    }
    
    func addVideo(url: URL?, asset: PHAsset?){
        if let url = url, FileManager.default.fileExists(url: url){
            let video = VideoItem()
            video.fileName = url.lastPathComponent
            if video.copyFile(from: url), video.createPreviewFile(){
                if self.atCenter{
                    video.coordinate = MapStatus.shared.centerCoordinate
                }
                else{
                    video.coordinate = asset?.location?.coordinate ?? .zero
                }
                video.creationDate = asset?.creationDate ?? Date()
                AppData.shared.addItem(video)
                AppData.shared.sortItemsByDate(ascending: ViewFilter.shared.defaultSortAscending)
                AppData.shared.save()
                DispatchQueue.main.async {
                    self.completionHandler?()
                }
            }
        }
    }
    
}

extension VideoPicker : UIDocumentPickerDelegate{
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first{
            if url.startAccessingSecurityScopedResource(){
                if FileManager.default.fileExists(url: url){
                    let video = VideoItem()
                    if atCenter{
                        video.coordinate = MapStatus.shared.centerCoordinate
                    }
                    video.fileName = url.lastPathComponent
                    if video.copyFile(from: url), video.createPreviewFile(){
                        if self.atCenter{
                            video.coordinate = MapStatus.shared.centerCoordinate
                        }
                        else{
                            video.coordinate = .zero
                        }
                        AppData.shared.addItem(video)
                        AppData.shared.sortItemsByDate(ascending: ViewFilter.shared.defaultSortAscending)
                        AppData.shared.save()
                        DispatchQueue.main.async {
                            self.completionHandler?()
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






