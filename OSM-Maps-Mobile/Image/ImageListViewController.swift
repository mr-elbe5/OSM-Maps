/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import PhotosUI

class ImageListViewController: ItemListViewController{
    
    var images: ImageItemList{
        items as! ImageItemList
    }
    
    init(){
        super.init(title: "images".localize())
        loadItems()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func getTrailingBarButtos() -> Array<UIBarButtonItem>{
        var items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "importImages".localize(), image: UIImage(systemName: "square.and.arrow.down"), primaryAction: UIAction(){ action in
            self.importImages()
        }))
        items.append(UIBarButtonItem(title: "sort".localize(), image: UIImage(systemName: "arrow.up.arrow.down"), primaryAction: UIAction(){ action in
            self.toggleSorting()
        }))
        items.append(UIBarButtonItem(title: "selectAll".localize(), image: UIImage(systemName: "checkmark.square"), primaryAction: UIAction(){ action in
            self.toggleSelectAll()
        }))
        items.append(UIBarButtonItem(title: "exportSelected".localize(), image: UIImage(systemName: "square.and.arrow.up"), primaryAction: UIAction(){ action in
            self.exportSelected()
        }))
        items.append(UIBarButtonItem(title: "deleteSelected".localize(), image: UIImage(systemName: "trash.square")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal), primaryAction: UIAction(){ action in
            self.deleteSelected()
        }))
        return items
    }
    
    func loadItems(){
        if ViewFilter.shared.isActive{
            items = ViewFilter.shared.filteredImages(images: AppData.shared.images)
        }
        else{
            items = AppData.shared.images
        }
        setupData()
        self.tableView.reloadData()
    }
    
    func exportSelected(){
        var exportList = [URL]()
        for i in 0..<images.count{
            let image = images[i]
            if image.selected, FileManager.default.fileExists(url: image.url){
                exportList.append(image.url)
            }
        }
        if exportList.isEmpty{
            return
        }
        let picker = UIDocumentPickerViewController(forExporting: exportList)
        picker.delegate = nil
        picker.title = "exportSelected".localize()
        present(picker, animated: true)
    }
    
    func importImages() {
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
    
}

extension ImageListViewController: PHPickerViewControllerDelegate{
    
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
                    if let url = url, let img = OSImage(contentsOfFile: url.path) {
                        let image = ImageItem(coordinate: location?.coordinate ?? .zero)
                        image.creationDate = creationDate ?? Date()
                        if image.hasValidCoordinate{
                            image.updateLocation()
                        }
                        image.originalFileName = url.lastPathComponent
                        image.generateFileName()
                        if image.copyImageAndCreatePreview(originalURL: url, original: img){
                            AppData.shared.addItem(image)
                            AppData.shared.sortItemsByDate(ascending: ViewFilter.shared.defaultSortAscending)
                            DispatchQueue.main.async {
                                MainViewController.shared.updateItemLayer()
                                self.loadItems()
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
    }
    
}
    
    
