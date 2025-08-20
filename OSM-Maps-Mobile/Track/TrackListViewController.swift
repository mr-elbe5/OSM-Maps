/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers
import CoreLocation

class TrackListViewController: ItemListViewController{
    
    var tracks: TrackItemList{
        items as! TrackItemList
    }
    
    init(){
        super.init(title: "tracks".localize())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func getTrailingBarButtos() -> Array<UIBarButtonItem>{
        var items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "importTrack".localize(), image: UIImage(systemName: "square.and.arrow.down"), primaryAction: UIAction(){ action in
            self.importTrack()
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
            items = ViewFilter.shared.filteredTracks(tracks: AppData.shared.tracks)
        }
        else{
            items = AppData.shared.tracks
        }
        setupData()
        self.tableView.reloadData()
    }
    
    func exportSelected(){
        var exportList = [URL]()
        for i in 0..<tracks.count{
            let item = tracks[i]
            if item.selected{
                if let url = GPXCreator.createTemporaryFile(track: item.track){
                    exportList.append(url)
                }
            }
        }
        if exportList.isEmpty{
            return
        }
        let picker = UIDocumentPickerViewController(forExporting: exportList, asCopy: false)
        picker.delegate = nil
        picker.title = "exportSelected".localize()
        present(picker, animated: true)
    }
    
    func importTrack(){
        let filePicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType(filenameExtension: "gpx")!])
        filePicker.title = "track".localize()
        filePicker.allowsMultipleSelection = false
        filePicker.delegate = self
        filePicker.modalPresentationStyle = .fullScreen
        self.present(filePicker, animated: true)
    }
    
}

extension TrackListViewController : UIDocumentPickerDelegate{
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first{
            if url.pathExtension == "gpx"{
                importGPXFile(url: url)
            }
        }
    }
    
    private func importGPXFile(url: URL){
        if let gpxData = GPXParser.parseFile(url: url), !gpxData.isEmpty{
            let track = Track(gpx: gpxData)
            if track.name.isEmpty{
                let ext = url.pathExtension
                var name = url.lastPathComponent
                name = String(name[name.startIndex...name.index(name.endIndex, offsetBy: -ext.count)])
                Log.debug(name)
                track.name = name
            }
            let item = TrackItem()
            item.track = track
            AppData.shared.addItem(item)
            AppData.shared.save()
            DispatchQueue.main.async {
                MainViewController.shared.updateItemLayer()
                self.loadItems()
                
            }
        }
    }
    
}
    
    
