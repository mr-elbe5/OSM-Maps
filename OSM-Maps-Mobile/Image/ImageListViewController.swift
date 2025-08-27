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
        items.append(UIBarButtonItem(title: "importImages".localize(), image: UIImage(systemName: "square.and.arrow.down"), menu: getImagesMenu()))
        items.append(UIBarButtonItem(title: "sort".localize(), image: UIImage(systemName: "arrow.up.arrow.down"), primaryAction: UIAction(){ action in
            self.toggleSorting()
        }))
        items.append(UIBarButtonItem(title: "selectAll".localize(), image: UIImage(systemName: "checkmark.square"), primaryAction: UIAction(){ action in
            self.toggleSelectAll()
        }))
        
        return items
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
    
    override func exportSelected(){
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
    
    func importImagesFromPhotoLibrary() {
        ImagePicker.shared = ImagePicker(controller: self)
        ImagePicker.shared?.addImagesFromPhotos(atCenter: false){
            self.loadItems()
        }
    }
    
    func importImagesFromFiles() {
        ImagePicker.shared = ImagePicker(controller: self)
        ImagePicker.shared?.addImagesFromFiles(atCenter: false){
            self.loadItems()
        }
    }
    
}

    
