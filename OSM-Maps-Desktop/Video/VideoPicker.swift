/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import AVFoundation
import CoreLocation
import PhotosUI

class VideoPicker: NSObject  {
    
    static var shared: VideoPicker?
    
    var controller: NSViewController
    var atCenter: Bool = false
    var completionHandler: (() -> Void)?
    
    init(controller: NSViewController){
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
                self.controller.presentAsModalWindow(picker)
            }
        }
    }
    
    func addVideosFromFiles(atCenter: Bool, onCompletion: (() -> Void)? = nil) {
        self.atCenter = atCenter
        self.completionHandler = onCompletion
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [.video, .movie]
        panel.directoryURL = FileManager.movieLibraryURL
        if panel.runModal() == .OK{
            for url in panel.urls{
                let video = VideoItem()
                if FileManager.default.fileExists(url: url){
                    video.originalFileName = url.lastPathComponent
                    video.generateFileName()
                    if video.copyFile(from: url), video.createPreviewFile(){
                        if self.atCenter{
                            video.coordinate = MapStatus.shared.centerCoordinate
                        }
                        else{
                            video.coordinate = .zero
                        }
                        video.updateLocation(){
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
        }
        Self.shared = nil
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
        controller.dismiss(picker)
        completionHandler?()
        Self.shared = nil
    }
    
    func addVideo(url: URL?, asset: PHAsset?){
        if let url = url, FileManager.default.fileExists(url: url){
            let video = VideoItem()
            video.originalFileName = url.lastPathComponent
            video.generateFileName()
            if video.copyFile(from: url), video.createPreviewFile(){
                if self.atCenter{
                    video.coordinate = MapStatus.shared.centerCoordinate
                }
                else{
                    video.coordinate = asset?.location?.coordinate ?? .zero
                }
                video.creationDate = asset?.creationDate ?? Date()
                video.updateLocation(){
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
    
}






