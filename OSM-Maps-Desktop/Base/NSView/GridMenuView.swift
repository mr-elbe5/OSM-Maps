/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

protocol GridMenuDelegate{
    func increasePreviewSize()
    func decreasePreviewSize()
    func selectAll()
    func deselectAll()
    func showAllItems()
    func hideUnselectedItems()
    func deleteSelected()
}

class GridMenuView: NSView{
    
    var selectButton: NSButton!
    var showButton: NSButton!
    var increaseSizeButton: NSButton!
    var decreaseSizeButton: NSButton!
    var deleteButton: NSButton!
    
    var selectMenu: NSMenu!
    var showMenu: NSMenu!
    
    var delegate: GridMenuDelegate? = nil
    
    var insets = OSInsets(top: 10, left: 5, bottom: 10, right: 5)
    
    init(){
        super.init(frame: .zero)
        selectButton = NSButton(icon: "checkmark.square", target: self, action: #selector(openSelectMenu))
        selectButton.toolTip = "selection".localize()
        selectMenu = NSMenu(title: "selection".localize())
        selectMenu.items.append(NSMenuItem(title: "selectAll".localize(), target: self, action: #selector(selectAllItems), keyEquivalent: ""))
        selectMenu.items.append(NSMenuItem(title: "deselectAll".localize(), target: self, action: #selector(deselectAllItems), keyEquivalent: ""))
        showButton = NSButton(icon: "eye", target: self, action: #selector(openShowMenu))
        showButton.toolTip = "showFilter".localize()
        showMenu = NSMenu(title: "showFilter".localize())
        showMenu.items.append(NSMenuItem(title: "showAll".localize(), target: self, action: #selector(showAllItems), keyEquivalent: ""))
        showMenu.items.append(NSMenuItem(title: "hideUnselected".localize(), target: self, action: #selector(hideUnselectedItems), keyEquivalent: ""))
        increaseSizeButton = NSButton(icon: "plus", target: self, action: #selector(increasePreviewSize))
        increaseSizeButton.toolTip = "increaseImageSize".localize()
        decreaseSizeButton = NSButton(icon: "minus", target: self, action: #selector(decreasePreviewSize))
        decreaseSizeButton.toolTip = "decreaseImageSize".localize()
        deleteButton = NSButton(icon: "trash.square", color: .systemRed, target: self, action: #selector(deleteSelected))
        deleteButton.toolTip = "deleteSelectedImages".localize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func openSelectMenu(){
        let location = NSPoint(x: selectButton.frame.width - 2, y: 10)
        selectMenu.popUp(positioning: nil, at: location, in: selectButton)
    }
    
    @objc func selectAllItems(){
        delegate?.selectAll()
    }
    
    @objc func deselectAllItems(){
        delegate?.deselectAll()
    }
    
    @objc func openShowMenu(){
        let location = NSPoint(x: showButton.frame.width - 2, y: 10)
        showMenu.popUp(positioning: nil, at: location, in: showButton)
    }
    
    @objc func showAllItems(){
        (delegate as? ImageGridMenuDelegate)?.showAllItems()
    }
    
    @objc func hideUnselectedItems(){
        (delegate as? ImageGridMenuDelegate)?.hideUnselectedItems()
    }
    
    @objc func increasePreviewSize() {
        delegate?.increasePreviewSize()
    }
    
    @objc func decreasePreviewSize() {
        delegate?.decreasePreviewSize()
    }
    
    @objc func deleteSelected(){
        delegate?.deleteSelected()
    }
    
}
    
