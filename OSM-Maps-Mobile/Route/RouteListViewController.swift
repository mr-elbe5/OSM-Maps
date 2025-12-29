/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers
import CoreLocation

class RouteListViewController: ItemListViewController{
    
    var routes: RouteItemList{
        items as! RouteItemList
    }
    
    init(){
        super.init(title: "routes".localize())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func getTrailingBarButtos() -> Array<UIBarButtonItem>{
        var items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "importRoute".localize(), image: UIImage(systemName: "square.and.arrow.down"), primaryAction: UIAction(){ action in
            self.importRoute()
        }))
        items.append(UIBarButtonItem(title: "sort".localize(), image: UIImage(systemName: "arrow.up.arrow.down"), primaryAction: UIAction(){ action in
            self.toggleSorting()
        }))
        items.append(UIBarButtonItem(title: "selectAll".localize(), image: UIImage(systemName: "checkmark.square"), primaryAction: UIAction(){ action in
            self.toggleSelectAll()
        }))
        return items
    }
    
    func loadItems(){
        if ViewFilter.shared.isActive{
            items = ViewFilter.shared.filteredRoutes(routes: AppData.shared.routes)
        }
        else{
            items = AppData.shared.routes
        }
        setupData()
        self.tableView.reloadData()
    }
    
    override func exportSelected(){
        var exportList = [URL]()
        for i in 0..<routes.count{
            let item = routes[i]
            if item.selected{
                if let url = GPXCreator.createTemporaryFile(route: item.route){
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
    
    func importRoute(){
        let filePicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType(filenameExtension: "gpx")!])
        filePicker.title = "route".localize()
        filePicker.allowsMultipleSelection = false
        filePicker.delegate = self
        filePicker.modalPresentationStyle = .fullScreen
        self.present(filePicker, animated: true)
    }
    
}

extension RouteListViewController : UIDocumentPickerDelegate{
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first{
            if url.pathExtension == "gpx"{
                importGPXFile(url: url)
            }
        }
    }
    
    private func importGPXFile(url: URL){
        if url.startAccessingSecurityScopedResource(){
            if let gpxData = GPXParser.parseFile(url: url), !gpxData.isEmpty{
                let route = Route(gpx: gpxData)
                if route.name.isEmpty{
                    let ext = url.pathExtension
                    var name = url.lastPathComponent
                    name = String(name[name.startIndex...name.index(name.endIndex, offsetBy: -ext.count)])
                    Log.debug(name)
                    route.name = name
                }
                let item = RouteItem()
                item.route = route
                AppData.shared.addItem(item)
                AppData.shared.save()
                DispatchQueue.main.async {
                    MainViewController.shared.updateItemLayer()
                    self.loadItems()
                    
                }
            }
            url.stopAccessingSecurityScopedResource()
        }
    }
    
}
    
    
