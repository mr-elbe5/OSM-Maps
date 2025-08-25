/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

import UniformTypeIdentifiers

class AVGridView: GridView{
    
    var items = Array<AudioItem>()
    
    var menuView = AVGridMenuView()
    
    override func setupView() {
        addSubviewWithAnchors(menuView, top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, insets: .zero)
            .width(40)
        menuView.setupView()
        menuView.delegate = self
        addSubviewWithAnchors(scrollView, top: topAnchor, leading: menuView.trailingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: .smallInsets)
        setupCollectionView()
        collectionView.delegate = self
        collectionView.dataSource = self
        items.append(contentsOf: AppData.shared.avMedia)
        collectionView.reloadData()
    }
    
    func updateView(){
        collectionView.removeAllSubviews()
        updateData()
    }
    
    func updateData(){
        items.removeAll()
        items.append(contentsOf: AppData.shared.avMedia)
        collectionView.reloadData()
    }
    
    func getSelectedItems() -> AVMediaItemList{
        var arr = AVMediaItemList()
        for path in collectionView.selectionIndexPaths{
            arr.append(items[path.item])
        }
        arr.sortByDate(ascending: true)
        return arr
    }
    
}

extension AVGridView: NSCollectionViewDataSource{
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = items[indexPath.item]
        if item.selected{
            collectionView.selectionIndexPaths.insert(indexPath)
        }
        if let audio = item as? AudioItem{
            let item = AudioGridItem(item: audio)
            item.isSelected = audio.selected
            item.setHighlightState()
            item.delegate = self
            return item
        }
        if let video = item as? VideoItem{
            let item = VideoGridItem(item: video)
            item.isSelected = video.selected
            item.setHighlightState()
            item.delegate = self
            return item
        }
        return NSCollectionViewItem()
    }
    
}

extension AVGridView: NSCollectionViewDelegate{
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        for indexPath in indexPaths{
            if let item = collectionView.item(at: indexPath) as? AudioGridItem{
                item.select(true)
                print("selected \(item.item.fileName)")
                item.setHighlightState()
            }
            else if let item = collectionView.item(at: indexPath) as? VideoGridItem{
                item.select(true)
                print("selected \(item.item.fileName)")
                item.setHighlightState()
            }
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        for indexPath in indexPaths{
            if let item = collectionView.item(at: indexPath) as? AudioGridItem{
                item.select(false)
                print("deselected \(item.item.fileName)")
                item.setHighlightState()
            }
            else if let item = collectionView.item(at: indexPath) as? VideoGridItem{
                item.select(false)
                print("deselected \(item.item.fileName)")
                item.setHighlightState()
            }
        }
    }
    
}

extension AVGridView: AVGridMenuDelegate{
    
    func toggleSelectAll() {
        if items.allSelected{
            items.deselectAll()
        }
        else{
            items.selectAll()
        }
        collectionView.reloadData()
    }
    
    func importMediaFromPhotos() {
        MainViewController.shared.addMediaFromPhotos(){
            MainViewController.shared.mapView.updateItemLayer()
            self.updateData()
        }
    }
    
    func importMediaFromFiles() {
        MainViewController.shared.addMediaFromFiles(){
            MainViewController.shared.mapView.updateItemLayer()
            self.updateData()
        }
    }
    
    func deleteSelected() {
        let selected = getSelectedItems()
        if !selected.isEmpty{
            if NSAlert.acceptWarning(message: "deleteItemsWarning".localize()){
                AppData.shared.deleteItems(selected)
                for image in selected{
                    items.remove(obj: image)
                }
                collectionView.reloadData()
            }
        }
    }
    
}

extension AVGridView: AudioGridItemDelegate, VideoGridItemDelegate{
    
    func showVideoFullSize(_ video: VideoItem) {
        MainViewController.shared.showVideo(video)
    }
    
    func showItemOnMap(_ audio: AudioItem) {
        MainViewController.shared.showItemOnMap(audio)
    }
    
    func showItemOnMap(_ video: VideoItem) {
        MainViewController.shared.showItemOnMap(video)
    }
    
    func deleteItem(_ audio: AudioItem) {
        items.remove(obj: audio)
        AppData.shared.deleteItem(audio)
        AppData.shared.save()
        collectionView.reloadData()
    }
    
    func deleteItem(_ video: VideoItem) {
        items.remove(obj: video)
        AppData.shared.deleteItem(video)
        AppData.shared.save()
        collectionView.reloadData()
    }
    
}





