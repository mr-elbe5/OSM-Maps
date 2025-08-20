/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import AppKit

protocol TrackGridItemDelegate{
    func editTrack(_ track: TrackItem)
    func exportTrack(_ track: TrackItem)
    func deleteTrack(_ track: TrackItem)
}

class TrackGridItem: NSCollectionViewItem, TrackGridItemViewDelegate{
    
    var track: TrackItem
    
    var delegate: TrackGridItemDelegate? = nil
    
    init(track: TrackItem) {
        self.track = track
        super.init(nibName: "", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let itemView = TrackGridItemView()
        itemView.delegate = self
        
        view = itemView
        view.wantsLayer = true
        view.setGrayRoundedBorders()
        
        let dateView = NSTextField(labelWithString: track.creationDate.dateTimeString())
        view.addSubviewWithAnchors(dateView, top: view.topAnchor, insets: OSInsets.smallInsets).centerX(view.centerXAnchor)
        
        let imgView = NSImageView(image: track.getPreview() ?? NSImage(named: "gear.grey")!)
        view.addSubviewFilling(imgView, insets: NSEdgeInsets(top: 25, left: 5, bottom: 25, right: 5))
        
        let iconView = NSView()
        view.addSubviewWithAnchors(iconView, bottom: view.bottomAnchor, insets: OSInsets.smallInsets).centerX(view.centerXAnchor)
        
        let showOnMapButton = NSButton(image: NSImage(systemSymbolName: "map", accessibilityDescription: nil)!, target: itemView, action: #selector(itemView.showTrackOnMap))
        showOnMapButton.bezelStyle = .smallSquare
        iconView.addSubviewWithAnchors(showOnMapButton, top: iconView.topAnchor, leading: iconView.leadingAnchor, bottom: iconView.bottomAnchor, insets: OSInsets.flatInsets)
        let editButton = NSButton(image: NSImage(systemSymbolName: "pencil", accessibilityDescription: nil)!, target: itemView, action: #selector(itemView.editTrack))
        editButton.bezelStyle = .smallSquare
        iconView.addSubviewWithAnchors(editButton, top: iconView.topAnchor, leading: showOnMapButton.trailingAnchor, bottom: iconView.bottomAnchor, insets: OSInsets.flatInsets)
        let exportButton = NSButton(image: NSImage(systemSymbolName: "square.and.arrow.up", accessibilityDescription: nil)!, target: itemView, action: #selector(itemView.exportTrack))
        exportButton.bezelStyle = .smallSquare
        iconView.addSubviewWithAnchors(exportButton, top: iconView.topAnchor, leading: editButton.trailingAnchor, bottom: iconView.bottomAnchor, insets: OSInsets.flatInsets)
        let deleteButton = NSButton(image: NSImage(systemSymbolName: "trash", accessibilityDescription: nil)!, target: itemView, action: #selector(itemView.deleteTrack))
        deleteButton.bezelStyle = .smallSquare
        iconView.addSubviewWithAnchors(deleteButton, top: iconView.topAnchor, leading: exportButton.trailingAnchor, trailing: iconView.trailingAnchor, bottom: iconView.bottomAnchor, insets: OSInsets.flatInsets)
    }
    
    func editTrack() {
        delegate?.editTrack(track)
    }
    
    func exportTrack() {
        delegate?.exportTrack(track)
    }
    
    func showTrackOnMap() {
        MainViewController.shared.showTrackOnMap(track)
    }
    
    func deleteTrack() {
        delegate?.deleteTrack(track)
    }

}

fileprivate protocol TrackGridItemViewDelegate{
    func showTrackOnMap()
    func exportTrack()
    func editTrack()
    func deleteTrack()
}

fileprivate class TrackGridItemView: NSView{
    
    var delegate: TrackGridItemViewDelegate? = nil
    
    @objc func showTrackOnMap(){
        delegate?.showTrackOnMap()
    }
    
    @objc func exportTrack(){
        delegate?.exportTrack()
    }
    
    @objc func editTrack(){
        delegate?.editTrack()
    }
    
    @objc func deleteTrack(){
        delegate?.deleteTrack()
    }
    
}



