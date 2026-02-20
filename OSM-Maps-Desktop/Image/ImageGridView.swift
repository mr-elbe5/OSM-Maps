/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

import UniformTypeIdentifiers

class ImageGridView: GridView{
    
    var imageItems: Array<ImageItem>{
        items as!Array<ImageItem>
    }
    
    var menuView = ImageGridMenuView()
    
    init(){
        super.init(idx: 1)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        items.deselectAll()
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
        items.append(contentsOf: AppData.shared.images)
        collectionView.reloadData()
    }
    
    func getSelectedImages() -> Array<ImageItem>{
        var arr = ImageItemList()
        for path in collectionView.selectionIndexPaths{
            arr.append(items[path.item] as! ImageItem)
        }
        arr.sortByDate(ascending: true)
        return arr
    }
    
    override func updateData(){
        items.removeAll()
        items.append(contentsOf: AppData.shared.images)
        collectionView.reloadData()
    }
    
}

extension ImageGridView{
    
    override func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let image = imageItems[indexPath.item]
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

extension ImageGridView: ImageGridMenuDelegate{
    
    func showSelected() {
        let selected = getSelectedItems() as! ImageItemList
        if !selected.isEmpty{
            MainViewController.shared.showImages(selected)
        }
    }
    
    func importImagesFromPhotos() {
        MainViewController.shared.addImagesFromPhotos(){
            MainViewController.shared.itemsChanged()
            self.updateData()
        }
    }
    
    func importImagesFromFiles() {
        MainViewController.shared.addImagesFromFiles(){
            MainViewController.shared.itemsChanged()
            self.updateData()
        }
    }
    
}

extension ImageGridView: ImageGridItemDelegate{
    
    func showImageFullSize(_ image: ImageItem) {
        MainViewController.shared.showImage(image)
    }
    
    func deleteImage(_ image: ImageItem) {
        items.remove(obj: image)
        AppData.shared.deleteItem(image)
        AppData.shared.save()
        collectionView.reloadData()
    }
    
}





