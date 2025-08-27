/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import PhotosUI

class AVMediaListViewController: ItemListViewController{
    
    init(){
        super.init(title: "avMedia".localize())
        loadItems()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func getTrailingBarButtos() -> Array<UIBarButtonItem>{
        var items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "importVideos".localize(), image: UIImage(systemName: "square.and.arrow.down"), menu: getImportMenu()))
        items.append(UIBarButtonItem(title: "sort".localize(), image: UIImage(systemName: "arrow.up.arrow.down"), primaryAction: UIAction(){ action in
            self.toggleSorting()
        }))
        items.append(UIBarButtonItem(title: "selectAll".localize(), image: UIImage(systemName: "checkmark.square"), primaryAction: UIAction(){ action in
            self.toggleSelectAll()
        }))
        return items
    }
    
    func getImportMenu() -> UIMenu {
        var actions = Array<UIAction>()
        actions.append(UIAction(title: "fromPhotoLibrary".localize(), image: UIImage(systemName: "photo.stack")){ action in
            self.importVideosFromPhotoLibrary()
        })
        actions.append(UIAction(title: "fromFiles".localize(), image: UIImage(systemName: "folder")){ action in
            self.importVideosFromFiles()
        })
        return UIMenu(title: "", children: actions)
    }
    
    func loadItems(){
        if ViewFilter.shared.isActive{
            items = ViewFilter.shared.filteredItems(items: AppData.shared.avMedia)
        }
        else{
            items = AppData.shared.avMedia
        }
        setupData()
        self.tableView.reloadData()
    }
    
    override func exportSelected(){
        var exportList = [URL]()
        for i in 0..<items.count{
            let item = items[i]
            if let audio = item as? AudioItem{
                if audio.selected, FileManager.default.fileExists(url: audio.url){
                    exportList.append(audio.url)
                }
            }
            else if let video = item as? VideoItem{
                if video.selected, FileManager.default.fileExists(url: video.url){
                    exportList.append(video.url)
                }
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
    
    func importVideosFromPhotoLibrary() {
        VideoPicker.shared = VideoPicker(controller: self)
        VideoPicker.shared?.addVideosFromPhotos(atCenter: false){
            self.loadItems()
        }
    }
    
    func importVideosFromFiles() {
        VideoPicker.shared = VideoPicker(controller: self)
        VideoPicker.shared?.addVideosFromFiles(atCenter: false){
            self.loadItems()
        }
    }
    
}

    
    
