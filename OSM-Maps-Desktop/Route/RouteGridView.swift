/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

import UniformTypeIdentifiers

class RouteGridView: GridView{
    
    var items = Array<RouteItem>()
    
    var menuView = RouteGridMenuView()
    
    init(){
        super.init(idx: 4)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        items.deselectAll()
    }
    
    override func setupView() {
        super.setupView()
        addSubviewWithAnchors(menuView, top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor)
            .width(40)
        menuView.setupView()
        menuView.delegate = self
        addSubviewWithAnchors(scrollView, top: topAnchor, leading: menuView.trailingAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
        setupCollectionView()
        collectionView.dataSource = self
        items.append(contentsOf: AppData.shared.routes)
        collectionView.reloadData()
    }
    
    func updateView(){
        collectionView.removeAllSubviews()
        updateData()
    }
    
    func updateData(){
        items.removeAll()
        items.append(contentsOf: AppData.shared.routes)
        collectionView.reloadData()
    }
    
    func getSelectedRoutes() -> RouteItemList{
        var arr = RouteItemList()
        for path in collectionView.selectionIndexPaths{
            arr.append(items[path.item])
        }
        arr.sortByDate(ascending: true)
        return arr
    }
    
}

extension RouteGridView: NSCollectionViewDataSource{
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let route = items[indexPath.item]
        if route.selected{
            collectionView.selectionIndexPaths.insert(indexPath)
        }
        let item = RouteGridItem(route: route)
        item.delegate = self
        return item
    }
    
}

extension RouteGridView: RouteGridItemDelegate{
    
    func exportRoute(_ route: RouteItem) {
        MainViewController.shared.exportRoute(route)
    }
    
    func deleteRoute(_ route: RouteItem) {
        items.remove(obj: route)
        AppData.shared.deleteItem(route)
        AppData.shared.save()
        collectionView.reloadData()
    }
    
}

extension RouteGridView: RouteGridMenuDelegate{
    
    func importRoute() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = UTType.types(tag: "gpx", tagClass: UTTagClass.filenameExtension, conformingTo: nil)
        openPanel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        if openPanel.runModal() == .OK{
            if let url = openPanel.url{
                if url.startAccessingSecurityScopedResource(){
                    if url.pathExtension == "gpx"{
                        importGPXFile(url: url)
                        DispatchQueue.main.async {
                            MainViewController.shared.itemsChanged()
                            self.updateData()
                        }
                    }
                    url.stopAccessingSecurityScopedResource()
                }
            }
        }
    }
    
    private func importGPXFile(url: URL){
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
                MainViewController.shared.itemsChanged()
                self.updateData()
            }
        }
    }
    
}





