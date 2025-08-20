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

class ImageGridItem: NSCollectionViewItem, ImageGridItemViewDelegate{
    
    var image: ImageItem
    
    var delegate: ImageGridItemDelegate? = nil
    
    init(image: ImageItem) {
        self.image = image
        super.init(nibName: "", bundle: nil)
        setHighlightState()
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
        
        let dateView = NSTextField(labelWithString: image.creationDate.dateTimeString())
        view.addSubviewWithAnchors(dateView, top: view.topAnchor, insets: OSInsets.smallInsets).centerX(view.centerXAnchor)
        
        let imgView = NSImageView(image: image.preview ?? NSImage(named: "gear.grey")!)
        view.addSubviewFilling(imgView, insets: NSEdgeInsets(top: 25, left: 5, bottom: 25, right: 5))
        
        let iconView = NSView()
        view.addSubviewWithAnchors(iconView, bottom: view.bottomAnchor, insets: OSInsets.smallInsets).centerX(view.centerXAnchor)
        
        let showFullSizeButton = NSButton(image: NSImage(systemSymbolName: "square.resize.up", accessibilityDescription: nil)!, target: itemView, action: #selector(itemView.showImageFullSize))
        showFullSizeButton.bezelStyle = .smallSquare
        iconView.addSubviewToRight(showFullSizeButton, insets: OSInsets.flatInsets)
        let showOnMapButton = NSButton(image: NSImage(systemSymbolName: "map", accessibilityDescription: nil)!, target: itemView, action: #selector(itemView.showImageOnMap))
        showOnMapButton.bezelStyle = .smallSquare
        iconView.addSubviewToRight(showOnMapButton, leftView: showFullSizeButton, insets: OSInsets.flatInsets)
        let showDetailButton = NSButton(image: NSImage(systemSymbolName: "list.bullet", accessibilityDescription: nil)!, target: itemView, action: #selector(itemView.showImageDetail))
        showDetailButton.bezelStyle = .smallSquare
        iconView.addSubviewToRight(showDetailButton, leftView: showOnMapButton, insets: OSInsets.flatInsets)
            .connectToRight(of: iconView)
        
        setHighlightState()
    }
    
    override func mouseDown(with event: NSEvent) {
        if event.clickCount > 1{
            delegate?.showImageFullSize(image)
        }
        else{
            super.mouseDown(with: event)
        }
    }
    
    func select(_ flag: Bool){
        isSelected = flag
        image.selected = flag
    }
    
    func showImageFullSize(){
        delegate?.showImageFullSize(image)
    }
    
    func showImageOnMap(){
        MainViewController.shared.showItemOnMap(image)
    }
    
    func showImageDetail(){
        let detailView = ImageGridDetailViewController(image: image)
        detailView.popover.show(relativeTo: view.bounds, of: view, preferredEdge: .minY)
    }
    
    func deleteImage(){
        delegate?.deleteImage(image)
    }
    
    func setHighlightState() {
        view.backgroundColor = isSelected ? NSColor(white: 0.7, alpha: 0.3) : .black
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
    
    @objc func deleteImage(){
        delegate?.deleteImage()
    }
    
}



