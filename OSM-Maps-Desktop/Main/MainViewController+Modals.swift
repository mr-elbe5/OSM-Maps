/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import AVFoundation
import CoreLocation
import PhotosUI

extension MainViewController {
    
    func openHelp(at button: NSButton) {
        let controller = MapHelpViewController()
        ModalWindow.run(title: "help".localize(), viewController: controller, outerWindow: self.view.window!, minSize: CGSize(width: 300, height: 200))
    }
    
    func openViewSettings(at button: NSButton) {
        let controller = ViewSettingsViewController()
        if ModalWindow.run(title: "viewSettings".localize(), viewController: controller, outerWindow: MainWindowController.instance.window!, minSize: CGSize(width: 300, height: 200)) == .OK{
            
        }
    }
    
    func openICloud(at button: NSButton) {
        let controller = ICloudViewController()
        if ModalWindow.run(title: "iCloud".localize(), viewController: controller, outerWindow: MainWindowController.instance.window!, minSize: CGSize(width: 300, height: 200)) == .OK{
            
        }
    }
    
    func openPreferences(at button: NSButton) {
        let controller = PreferencesViewController()
        controller.popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
    }
    
    func openBackup(at button: NSButton) {
        let controller = BackupViewController()
        if ModalWindow.run(title: "backup".localize(), viewController: controller, outerWindow: MainWindowController.instance.window!, minSize: CGSize(width: 300, height: 200)) == .OK{
            
        }
    }
    
    func openSearch(){
        let controller = SearchViewController()
        if ModalWindow.run(title: "search".localize(), viewController: controller, outerWindow: MainWindowController.instance.window!, minSize: CGSize(width: 300, height: 100)) == .OK{
            
        }
    }
    
    func addNoteAtCenter(text: String) {
        let note = NoteItem(coordinate: MapStatus.shared.centerCoordinate)
        note.updateLocation()
        note.name = text
        let controller = EditNoteViewController(item: note)
        if ModalWindow.run(title: "editNote".localize(), viewController: controller, outerWindow: MainWindowController.instance.window!, minSize: CGSize(width: 300, height: 200)) == .OK{
            AppData.shared.addItem(note)
            AppData.shared.save()
            mapView.updateItemLayer()
        }
    }
    
    func editNote(_ note: NoteItem, onCompletion: (() -> Void)? = nil) {
        let controller = EditNoteViewController(item: note)
        if ModalWindow.run(title: "editNote".localize(), viewController: controller, outerWindow: MainWindowController.instance.window!, minSize: CGSize(width: 300, height: 200)) == .OK{
                onCompletion?()
        }
    }
    
    func addImagesFromPhotos(onCompletion: (() -> Void)? = nil) {
        ImagePicker.shared = ImagePicker(controller: self)
        ImagePicker.shared!.addImagesFromPhotos(atCenter: false, onCompletion: onCompletion)
    }
    
    func addImagesFromFiles(onCompletion: (() -> Void)? = nil) {
        ImagePicker.shared = ImagePicker(controller: self)
        ImagePicker.shared!.addImagesFromFiles(atCenter: false, onCompletion: onCompletion)
    }
    
    func addImagesFromPhotosAtCenter(onCompletion: (() -> Void)? = nil) {
        ImagePicker.shared = ImagePicker(controller: self)
        ImagePicker.shared!.addImagesFromPhotos(atCenter: true, onCompletion: onCompletion)
    }
    
    func addImagesFromFilesAtCenter(onCompletion: (() -> Void)? = nil) {
        ImagePicker.shared = ImagePicker(controller: self)
        ImagePicker.shared!.addImagesFromFiles(atCenter: true, onCompletion: onCompletion)
    }
    
    func addVideosFromPhotos(onCompletion: (() -> Void)? = nil) {
        VideoPicker.shared = VideoPicker(controller: self)
        VideoPicker.shared!.addVideosFromPhotos(atCenter: false, onCompletion: onCompletion)
    }
    
    func addVideosFromFiles(onCompletion: (() -> Void)? = nil) {
        VideoPicker.shared = VideoPicker(controller: self)
        VideoPicker.shared!.addVideosFromFiles(atCenter: false, onCompletion: onCompletion)
    }
    
    func addVideosFromPhotosAtCenter(onCompletion: (() -> Void)? = nil) {
        VideoPicker.shared = VideoPicker(controller: self)
        VideoPicker.shared!.addVideosFromPhotos(atCenter: true, onCompletion: onCompletion)
    }
    
    func addVideosFromFilesAtCenter(onCompletion: (() -> Void)? = nil) {
        VideoPicker.shared = VideoPicker(controller: self)
        VideoPicker.shared!.addVideosFromFiles(atCenter: true, onCompletion: onCompletion)
    }
    
    func editImage(_ image: ImageItem) {
        let controller = EditImageViewController(item: image)
        if ModalWindow.run(title: "editImage".localize(), viewController: controller, outerWindow: MainWindowController.instance.window!, minSize: CGSize(width: 300, height: 200)) == .OK{
            
        }
    }
    
    func editAudio(_ audio: AudioItem) {
        let controller = EditAudioViewController(item: audio)
        if ModalWindow.run(title: "editAudio".localize(), viewController: controller, outerWindow: MainWindowController.instance.window!, minSize: CGSize(width: 300, height: 200)) == .OK{
        }
    }
    
    func editVideo(_ video: VideoItem) {
        let controller = EditVideoViewController(item: video)
        if ModalWindow.run(title: "editVideo".localize(), viewController: controller, outerWindow: MainWindowController.instance.window!, minSize: CGSize(width: 300, height: 200)) == .OK{
        }
    }
    
    func editTrack(_ track: TrackItem) {
        let controller = EditTrackViewController(item: track)
        if ModalWindow.run(title: "editTrack".localize(), viewController: controller, outerWindow: MainWindowController.instance.window!, minSize: CGSize(width: 300, height: 200)) == .OK{
            
        }
    }
    
    func exportTrack(_ item: TrackItem) {
        if let url = GPXCreator.createTemporaryFile(track: item.track){
            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = UTType.types(tag: "gpx", tagClass: UTTagClass.filenameExtension, conformingTo: nil)
            savePanel.nameFieldStringValue = "track_\(item.fileName)_\(item.track.startTime.fileDate()).gpx"
            savePanel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
            if savePanel.runModal() == .OK{
                let spinner = startSpinner()
                DispatchQueue.main.async {
                    if let targetUrl = savePanel.url, FileManager.default.copyFile(fromURL: url, toURL: targetUrl){
                        self.showSuccess(title: "success".localize(), text: "trackExported".localize())
                    }
                    self.stopSpinner(spinner)
                }
            }
        }
    }
    
}






