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
    
    deinit{
        items.deselectAll()
    }
    
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
            var itemView: MapItemCell? = nil
            switch item.itemType{
            case ImageItem.itemType:
                let view = ImageCell(image: item as! ImageItem)
                itemView = view
            case AudioItem.itemType:
                let view = AudioCell(audio: item as! AudioItem)
                itemView = view
            case VideoItem.itemType:
                let view = VideoCell(video: item as! VideoItem)
                itemView = view
            case NoteItem.itemType:
                let view = NoteCell(note: item as! NoteItem)
                itemView = view
            case TrackItem.itemType:
                let view = TrackCell(track: item as! TrackItem)
                itemView = view
            default:
                break
            }
            if let itemView = itemView{
                itemView.setupView()
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
            if let vw = vw as? MapItemCell{
                vw.setupIconView()
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



