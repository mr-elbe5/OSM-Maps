/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import AppKit
import AVKit

protocol AudioGridItemDelegate{
    func showItemOnMap(_ audio: AudioItem)
    func deleteItem(_ audio: AudioItem)
}

class AudioGridItem: NSCollectionViewItem, AudioGridItemViewDelegate{
    
    var item: AudioItem
    
    var delegate: AudioGridItemDelegate? = nil
    
    let videoPlayerView = AVPlayerView()
    
    init(item: AudioItem) {
        self.item = item
        super.init(nibName: "", bundle: nil)
        setHighlightState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        videoPlayerView.player = nil
    }
    
    override func loadView() {
        let itemView = AudioGridItemView()
        itemView.delegate = self
        
        view = itemView
        view.wantsLayer = true
        view.setGrayRoundedBorders()
        
        let dateView = NSTextField(labelWithString: item.creationDate.dateTimeString())
        view.addSubviewWithAnchors(dateView, top: view.topAnchor, insets: OSInsets.smallInsets).centerX(view.centerXAnchor)
        let audioView = AudioPlayerView()
        audioView.setupView()
        audioView.url = item.url
        audioView.enablePlayer()
        view.addSubviewWithAnchors(audioView, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: view.bottomAnchor, insets: NSEdgeInsets(top: 25, left: 5, bottom: 25, right: 5))
            .height(80)
        let iconView = NSView()
        view.addSubviewWithAnchors(iconView, bottom: view.bottomAnchor, insets: OSInsets.smallInsets).centerX(view.centerXAnchor)
        
        let showOnMapButton = NSButton(image: NSImage(systemSymbolName: "map", accessibilityDescription: nil)!, target: itemView, action: #selector(itemView.showItemOnMap))
        showOnMapButton.bezelStyle = .smallSquare
        iconView.addSubviewToRight(showOnMapButton, insets: OSInsets.flatInsets)
        
        setHighlightState()
    }
    
    func select(_ flag: Bool){
        isSelected = flag
        item.selected = flag
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

protocol AudioGridItemViewDelegate{
    func showItemOnMap()
    func deleteItem()
}

class AudioGridItemView: NSView{
        
    var delegate: AudioGridItemViewDelegate? = nil
    
    @objc func showItemOnMap(){
        delegate?.showItemOnMap()
    }
    
    @objc func deleteItem(){
        delegate?.deleteItem()
    }
    
}




