/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

import UniformTypeIdentifiers

class ImageGridView: GridView{
    
    var images = Array<ImageItem>()
    
    var menuView = ImageGridMenuView()
    
    var hideUnselected: Bool = false
    
    override func setupView() {
        addSubviewWithAnchors(menuView, top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, insets: .zero)
            .width(40)
        menuView.setupView()
        menuView.delegate = self
        addSubviewWithAnchors(scrollView, top: topAnchor, leading: menuView.trailingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: .smallInsets)
        setupCollectionView()
        collectionView.delegate = self
        collectionView.dataSource = self
        images.append(contentsOf: AppData.shared.images)
        collectionView.reloadData()
    }
    
    func updateView(){
        collectionView.removeAllSubviews()
        updateData()
    }
    
    func updateData(){
        images.removeAll()
        images.append(contentsOf: hideUnselected ? AppData.shared.selectedImages : AppData.shared.images)
        collectionView.reloadData()
    }
    
    func getSelectedImages() -> Array<ImageItem>{
        var arr = ImageItemList()
        for path in collectionView.selectionIndexPaths{
            arr.append(images[path.item])
        }
        arr.sortByDate(ascending: true)
        return arr
    }
    
}

extension ImageGridView: NSCollectionViewDataSource{
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let image = images[indexPath.item]
        if image.selected{
            collectionView.selectionIndexPaths.insert(indexPath)
        }
        let item = ImageGridItem(image: image)
        item.isSelected = image.selected
        item.setHighlightState()
        item.delegate = self
        return item
    }
    
}

extension ImageGridView: NSCollectionViewDelegate{
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        for indexPath in indexPaths{
            if let item = collectionView.item(at: indexPath) as? ImageGridItem{
                item.select(true)
                print("selected \(item.item.fileName)")
                item.setHighlightState()
            }
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        for indexPath in indexPaths{
            if let item = collectionView.item(at: indexPath) as? ImageGridItem{
                item.select(false)
                print("deselected \(item.item.fileName)")
                item.setHighlightState()
            }
        }
    }
    
}

extension ImageGridView: ImageGridMenuDelegate{
    
    func selectAll() {
        images.selectAll()
        collectionView.reloadData()
    }
    
    func deselectAll() {
        images.deselectAll()
        collectionView.reloadData()
    }
    
    func showAllItems() {
        hideUnselected = false
        updateData()
    }
    
    func hideUnselectedItems() {
        hideUnselected = true
        updateData()
    }
    
    func showSelected() {
        let selected = getSelectedImages()
        if !selected.isEmpty{
            MainViewController.shared.showImages(selected)
        }
    }
    
    func importImagesFromPhotos() {
        MainViewController.shared.addImagesFromPhotos(){
            MainViewController.shared.mapView.updateItemLayer()
            self.updateData()
        }
    }
    
    func importImagesFromFiles() {
        MainViewController.shared.addImagesFromFiles(){
            MainViewController.shared.mapView.updateItemLayer()
            self.updateData()
        }
    }
    
    func deleteSelected() {
        let selected = getSelectedImages()
        if !selected.isEmpty{
            if NSAlert.acceptWarning(message: "deleteItemsWarning".localize()){
                AppData.shared.deleteItems(selected)
                for image in selected{
                    images.remove(obj: image)
                }
                collectionView.reloadData()
            }
        }
    }
    
}

extension ImageGridView: ImageGridItemDelegate{
    
    func showImageFullSize(_ image: ImageItem) {
        MainViewController.shared.showImage(image)
    }
    
    func deleteImage(_ image: ImageItem) {
        images.remove(obj: image)
        AppData.shared.deleteItem(image)
        AppData.shared.save()
        collectionView.reloadData()
    }
    
}





