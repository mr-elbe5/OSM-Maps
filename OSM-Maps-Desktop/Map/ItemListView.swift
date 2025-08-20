/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation


class ItemListView: NSView{
    
    let menuView = NSView()
    let scrollView = NSScrollView()
    let contentView = NSView()
    
    var selectAllButton: NSButton!
    var deleteSelectedButton: NSButton!
    
    var items: MapItemList = []
    
    override func setupView(){
        backgroundColor = .black
        setupMenuView()
        addSubviewBelow(menuView, insets: .zero)
        scrollView.asVerticalScrollView(contentView: contentView)
        addSubviewBelow(scrollView, upperView: menuView, insets: .zero)
            .connectToBottom(of: self)
        setupContentView()
    }
    
    func setupMenuView(){
        selectAllButton = NSButton(icon: "checkmark.square", target: self, action: #selector(toggleSelectAll))
        selectAllButton.toolTip = "selectAll".localize()
        menuView.addSubviewToLeft(selectAllButton, insets: OSInsets.narrowInsets)
        deleteSelectedButton = NSButton(icon: "trash.square", color: .systemRed, target: self, action: #selector(deleteSelected))
        deleteSelectedButton.toolTip = "deleteSelected".localize()
        menuView.addSubviewToLeft(deleteSelectedButton, rightView: selectAllButton)
    }
    
    func setupContentView(){
        contentView.removeAllSubviews()
        var lastView: NSView? = nil
        for item in items{
            var itemView: MapItemCellView? = nil
            switch item.itemType{
            case ImageItem.itemType:
                let view = ImageCellView(image: item as! ImageItem)
                view.delegate = self
                itemView = view
            case NoteItem.itemType:
                let view = NoteCellView(note: item as! NoteItem)
                view.delegate = self
                itemView = view
            case TrackItem.itemType:
                let view = TrackCellView(track: item as! TrackItem)
                view.delegate = self
                itemView = view
            default:
                break
            }
            if let itemView = itemView{
                contentView.addSubviewBelow(itemView, upperView: lastView, insets: OSInsets.smallInsets)
                lastView = itemView
                itemView.setupView()
            }
        }
        lastView?.bottom(contentView.bottomAnchor, inset: .zero)
    }
    
    func setItems(_ items: MapItemList){
        self.items = items
        setupContentView()
    }
    
    @objc func toggleSelectAll(){
        if items.allSelected{
            items.deselectAll()
        }
        else{
            items.selectAll()
        }
        for vw in contentView.subviews{
            if let vw = vw as? MapItemCellView{
                vw.updateIconView()
            }
        }
    }
    
    @objc func deleteSelected(){
        var list = MapItemList()
        for i in 0..<items.count{
            let item = items[i]
            if item.selected{
                list.append(item)
            }
        }
        if list.isEmpty{
            return
        }
        if NSAlert.acceptWarning(title: "deleteItemsWarning".localize(i: list.count), message: "deleteHint".localize(table: "Hints")){
            print("deleting \(list.count) items")
            for item in list{
                AppData.shared.deleteItem(withId: item.id)
                self.items.remove(obj: item)
            }
            MainViewController.shared.updateItemLayer()
            self.setupContentView()
        }
    }
    
}

extension ItemListView: MapItemDelegate{
    
    func itemsChanged() {
        MainViewController.shared.updateItemLayer()
    }
    
    func editNote(_ note: NoteItem) {
        MainViewController.shared.editNote(note){
            self.setupContentView()
        }
    }
    
    func editImage(_ image: ImageItem) {
        MainViewController.shared.editImage(image)
    }
    
    func editTrack(_ track: TrackItem) {
        MainViewController.shared.editTrack(track)
    }
    
    func showTrackOnMap(_ track: TrackItem) {
        MainViewController.shared.showTrackOnMap(track)
    }
    
}



