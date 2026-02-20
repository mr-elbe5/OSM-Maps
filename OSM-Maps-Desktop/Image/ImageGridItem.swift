/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import AppKit

protocol ImageGridItemDelegate{
    func showImageFullSize(_ image: ImageItem)
    func deleteImage(_ image: ImageItem)
}

class ImageGridItem: GridItem, ImageGridItemViewDelegate{
    
    var imageItem: ImageItem{
        item as! ImageItem
    }
    
    var delegate: ImageGridItemDelegate? = nil
    
    init(image: ImageItem) {
        super.init(item: image)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let itemView = ImageGridItemView()
        itemView.delegate = self
        
        view = itemView
        view.wantsLayer = true
        view.setGrayRoundedBorders()
        
        let dateView = NSTextField(labelWithString: imageItem.creationDate.dateTimeString())
        view.addSubviewWithAnchors(dateView, top: view.topAnchor, insets: OSInsets.smallInsets).centerX(view.centerXAnchor)
        
        let imgView = NSImageView(image: imageItem.preview ?? NSImage(named: "gear.grey")!)
        view.addSubviewFilling(imgView, insets: NSEdgeInsets(top: 25, left: 5, bottom: 25, right: 5))
        
        let iconView = NSView()
        view.addSubviewWithAnchors(iconView, bottom: view.bottomAnchor, insets: OSInsets.smallInsets).centerX(view.centerXAnchor)
        
        let showFullSizeButton = NSButton(image: NSImage(systemSymbolName: "magnifyingglass", accessibilityDescription: nil)!, target: itemView, action: #selector(itemView.showImageFullSize))
        showFullSizeButton.bezelStyle = .smallSquare
        iconView.addSubviewToRight(showFullSizeButton, insets: OSInsets.flatInsets)
        let showOnMapButton = NSButton(image: NSImage(systemSymbolName: "map", accessibilityDescription: nil)!, target: itemView, action: #selector(itemView.showImageOnMap))
        showOnMapButton.bezelStyle = .smallSquare
        iconView.addSubviewToRight(showOnMapButton, leftView: showFullSizeButton, insets: OSInsets.flatInsets)
        showOnMapButton.isHidden = !imageItem.hasValidCoordinate
        let showDetailButton = NSButton(image: NSImage(systemSymbolName: "list.bullet", accessibilityDescription: nil)!, target: itemView, action: #selector(itemView.showImageDetail))
        showDetailButton.bezelStyle = .smallSquare
        iconView.addSubviewToRight(showDetailButton, leftView: showOnMapButton, insets: OSInsets.flatInsets)
            .connectToRight(of: iconView)
        
        setHighlightState()
    }
    
    override func mouseDown(with event: NSEvent) {
        if event.clickCount > 1{
            delegate?.showImageFullSize(imageItem)
        }
        else{
            super.mouseDown(with: event)
        }
    }
    
    func showImageFullSize(){
        delegate?.showImageFullSize(imageItem)
    }
    
    func showImageOnMap(){
        MainViewController.shared.showItemOnMap(imageItem)
    }
    
    func showImageDetail(){
        let controller = ImageGridDetailViewController(image: imageItem)
        controller.popover.show(relativeTo: view.bounds, of: view, preferredEdge: .minY)
    }
    
    func deleteImage(){
        delegate?.deleteImage(imageItem)
    }

}

fileprivate protocol ImageGridItemViewDelegate{
    func showImageFullSize()
    func showImageOnMap()
    func showImageDetail()
    func deleteImage()
}

fileprivate class ImageGridItemView: NSView{
    
    var delegate: ImageGridItemViewDelegate? = nil
    
    @objc func showImageFullSize(){
        delegate?.showImageFullSize()
    }
    
    @objc func showImageOnMap(){
        delegate?.showImageOnMap()
    }
    
    @objc func showImageDetail(){
        delegate?.showImageDetail()
    }
    
}



