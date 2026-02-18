/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

import UniformTypeIdentifiers

class VideoGridView: GridView{
    
    var menuView = VideoGridMenuView()
    
    var videoItems: Array<VideoItem>{
        items as!Array<VideoItem>
    }
    
    init(){
        super.init(idx: 2)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView() {
        super.setupView()
        addSubviewWithAnchors(menuView, top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, insets: .zero)
            .width(40)
        menuView.setupView()
        menuView.delegate = self
        addSubviewWithAnchors(scrollView, top: topAnchor, leading: menuView.trailingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: .smallInsets)
        setupCollectionView()
        collectionView.delegate = self
        collectionView.dataSource = self
        items.append(contentsOf: AppData.shared.videos)
        collectionView.reloadData()
    }
    
}

extension VideoGridView{
    
    override func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = videoItems[indexPath.item]
        if item.selected{
            collectionView.selectionIndexPaths.insert(indexPath)
        }
        let gridItem = VideoGridItem(video: item)
        gridItem.isSelected = item.selected
        gridItem.setHighlightState()
        gridItem.delegate = self
        return gridItem
    }
    
}

extension VideoGridView: VideoGridMenuDelegate{
    
    func showSelected() {
        let selected = getSelectedItems() as! VideoItemList
        if !selected.isEmpty{
            MainViewController.shared.showVideos(selected)
        }
    }
    
    func importVideosFromPhotos() {
        MainViewController.shared.addVideosFromPhotos(){
            MainViewController.shared.itemsChanged()
            self.updateData()
        }
    }
    
    func importVideosFromFiles() {
        MainViewController.shared.addVideosFromFiles(){
            MainViewController.shared.itemsChanged()
            self.updateData()
        }
    }
    
}

extension VideoGridView: VideoGridItemDelegate{
    
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





