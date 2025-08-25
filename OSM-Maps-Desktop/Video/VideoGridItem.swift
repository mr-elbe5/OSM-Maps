/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import AppKit
import AVKit

protocol VideoGridItemDelegate{
    func showVideoFullSize(_ video: VideoItem)
    func showItemOnMap(_ video: VideoItem)
    func deleteItem(_ video: VideoItem)
}

class VideoGridItem: NSCollectionViewItem, VideoGridItemViewDelegate{
    
    var item: VideoItem
    
    var delegate: VideoGridItemDelegate? = nil
    
    init(item: VideoItem) {
        self.item = item
        super.init(nibName: "", bundle: nil)
        setHighlightState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let itemView = VideoGridItemView()
        itemView.delegate = self
        
        view = itemView
        view.wantsLayer = true
        view.setGrayRoundedBorders()
        
        let dateView = NSTextField(labelWithString: item.creationDate.dateTimeString())
        view.addSubviewWithAnchors(dateView, top: view.topAnchor, insets: OSInsets.smallInsets).centerX(view.centerXAnchor)
        
        let imgView = NSImageView(image: item.preview ?? NSImage(named: "gear.grey")!)
        view.addSubviewFilling(imgView, insets: NSEdgeInsets(top: 25, left: 5, bottom: 25, right: 5))
        
        let iconView = NSView()
        view.addSubviewWithAnchors(iconView, bottom: view.bottomAnchor, insets: OSInsets.smallInsets).centerX(view.centerXAnchor)
        
        let showFullSizeButton = NSButton(image: NSImage(systemSymbolName: "square.resize.up", accessibilityDescription: nil)!, target: itemView, action: #selector(itemView.showVideoFullSize))
        showFullSizeButton.bezelStyle = .smallSquare
        iconView.addSubviewToRight(showFullSizeButton, insets: OSInsets.flatInsets)
        let showOnMapButton = NSButton(image: NSImage(systemSymbolName: "map", accessibilityDescription: nil)!, target: itemView, action: #selector(itemView.showItemOnMap))
        showOnMapButton.bezelStyle = .smallSquare
        iconView.addSubviewToRight(showOnMapButton, leftView: showFullSizeButton, insets: OSInsets.flatInsets)
            .connectToRight(of: iconView)
        setHighlightState()
    }
    
    override func mouseDown(with event: NSEvent) {
        if event.clickCount > 1{
            delegate?.showVideoFullSize(item)
        }
        else{
            super.mouseDown(with: event)
        }
    }
    
    func select(_ flag: Bool){
        isSelected = flag
        item.selected = flag
    }
    
    func showVideoFullSize(){
        delegate?.showVideoFullSize(item)
    }
    
    func showItemOnMap(){
        MainViewController.shared.showItemOnMap(item)
    }
    
    func deleteItem(){
        delegate?.deleteItem(item)
    }
    
    func setHighlightState() {
        view.backgroundColor = isSelected ? NSColor(white: 0.7, alpha: 0.3) : .black
    }

}

protocol VideoGridItemViewDelegate{
    func showVideoFullSize()
    func showItemOnMap()
    func deleteItem()
}

class VideoGridItemView: NSView{
    
    var delegate: VideoGridItemViewDelegate? = nil
    
    @objc func showVideoFullSize(){
        delegate?.showVideoFullSize()
    }
    
    @objc func showItemOnMap(){
        delegate?.showItemOnMap()
    }
    
}

