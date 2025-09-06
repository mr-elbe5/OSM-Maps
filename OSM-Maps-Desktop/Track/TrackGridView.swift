/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

import UniformTypeIdentifiers

class TrackGridView: GridView{
    
    var items = Array<TrackItem>()
    
    var menuView = TrackGridMenuView()
    
    deinit{
        items.deselectAll()
    }
    
    override func setupView() {
        addSubviewWithAnchors(menuView, top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor)
            .width(40)
        menuView.setupView()
        menuView.delegate = self
        addSubviewWithAnchors(scrollView, top: topAnchor, leading: menuView.trailingAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
        setupCollectionView()
        collectionView.dataSource = self
        items.append(contentsOf: AppData.shared.tracks)
        collectionView.reloadData()
    }
    
    func updateView(){
        collectionView.removeAllSubviews()
        updateData()
    }
    
    func updateData(){
        items.removeAll()
        items.append(contentsOf: AppData.shared.tracks)
        collectionView.reloadData()
    }
    
    func getSelectedTracks() -> TrackItemList{
        var arr = TrackItemList()
        for path in collectionView.selectionIndexPaths{
            arr.append(items[path.item])
        }
        arr.sortByDate(ascending: true)
        return arr
    }
    
}

extension TrackGridView: NSCollectionViewDataSource{
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let track = items[indexPath.item]
        if track.selected{
            collectionView.selectionIndexPaths.insert(indexPath)
        }
        let item = TrackGridItem(track: track)
        item.delegate = self
        return item
    }
    
}

extension TrackGridView: TrackGridItemDelegate{
    
    func editTrack(_ track: TrackItem) {
        MainViewController.shared.editTrack(track)
    }
    
    func exportTrack(_ track: TrackItem) {
        MainViewController.shared.exportTrack(track)
    }
    
    func deleteTrack(_ track: TrackItem) {
        items.remove(obj: track)
        AppData.shared.deleteItem(track)
        AppData.shared.save()
        collectionView.reloadData()
    }
    
}

extension TrackGridView: TrackGridMenuDelegate{
    
    func importTrack() {
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
                            MainViewController.shared.updateItemLayer()
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
                self.updateData()
            }
        }
    }
    
}





