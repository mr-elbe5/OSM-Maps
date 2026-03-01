/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

import CoreLocation

class TrackCell: MapItemCell{
    
    static var pinColor = NSColor(red: 0.25, green: 0.5, blue: 1.0, alpha: 1.0)
    
    var item : TrackItem
    
    var selectedButton: NSButton!
    
    init(track: TrackItem){
        self.item = track
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateIconView(){
        iconView.removeAllSubviews()
        selectedButton = NSButton(icon: item.selected ? "checkmark.square" : "square", color: .lightColor, backgroundColor: .darkColor, target: self, action: #selector(toggleSelection))
        iconView.addSubviewToLeft(selectedButton, insets: iconInsets)
        let editButton = NSButton(icon: "pencil", color: .lightColor, backgroundColor: .darkColor, target: self, action: #selector(editTrack))
        iconView.addSubviewToLeft(editButton, rightView: selectedButton, insets: iconInsets)
        let imagesButton = NSButton(icon: "photo.stack", color: .lightColor, backgroundColor: .darkColor, target: self, action: #selector(showTrackImages))
        iconView.addSubviewToLeft(imagesButton, rightView: editButton, insets: iconInsets)
        let showOnMapButton = NSButton(icon: "map", color: .lightColor, backgroundColor: .darkColor, target: self, action: #selector(showTrackOnMap))
        iconView.addSubviewToLeft(showOnMapButton, rightView: imagesButton, insets: iconInsets)
            .connectToLeft(of: iconView)
        showOnMapButton.isEnabled = item.hasValidCoordinate
    }
    
    override func setupTimeLabel(){
        timeLabel.stringValue = item.creationDate.dateTimeString
    }
    
    override func setupMapIcon() {
        mapIconView.image = NSImage(systemSymbolName: item.hasValidCoordinate ? "mappin" : "mappin.slash", accessibilityDescription: nil)!.withTintColor(Self.pinColor)
    }
    
    override func updateItemView(){
        itemView.removeAllSubviews()
        let nameField = NSTextField(wrappingLabelWithString: item.track.name)
        itemView.addSubviewWithAnchors(nameField, top: itemView.topAnchor)
            .centerX(centerXAnchor)
        let durationField = NSTextField(labelWithString: "\("duration".localize()): \(item.track.duration.hmString())")
        itemView.addSubviewWithAnchors(durationField, top: nameField.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor)
        let distField = NSTextField(labelWithString: "\("distance".localize()): \(Int(item.track.distance))m")
        itemView.addSubviewWithAnchors(distField, top: durationField.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor)
        let upField = NSTextField(labelWithString: "\("upDistance".localize()): \(Int(item.track.upDistance))m")
        itemView.addSubviewWithAnchors(upField, top: distField.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor)
        let downField = NSTextField(labelWithString: "\("downDistance".localize()): \(Int(item.track.downDistance))m")
        itemView.addSubviewWithAnchors(downField, top: upField.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor)
        let trackpointsField = NSTextField(labelWithString: "\("numTrackpoints".localize()): \(Int(item.track.trackpoints.count))")
        itemView.addSubviewWithAnchors(trackpointsField, top: downField.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor)
        var lastView: NSView = trackpointsField
        if let img = item.getPreview(){
            let imgView = NSImageView(image: img)
            imgView.setAspectRatioConstraint()
            itemView.addSubviewWithAnchors(imgView, top: lastView.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor)
            lastView = imgView
        }
        else{
            let loadPreviewButton = NSButton(title: "loadPreview".localize(), target: self, action: #selector(loadPreview))
            itemView.addSubviewWithAnchors(loadPreviewButton, top: lastView.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor)
            lastView = loadPreviewButton
        }
        lastView.bottom(itemView.bottomAnchor)
    }
    
    @objc func toggleSelection(){
        item.selected = !item.selected
        selectedButton.image = NSImage(systemSymbolName: item.selected ? "checkmark.square" : "square", accessibilityDescription: nil)
    }
    
    @objc func showTrackOnMap(){
        MainViewController.shared.showTrackOnMap(item)
    }
    
    @objc func showTrackImages(){
        let images = AppData.shared.getImagesOfTrack(item: item)
        MainViewController.shared.showImages(images)
    }
    
    @objc func editTrack(){
        MainViewController.shared.editTrack(item)
    }
    
    @objc func selectionChanged(){
        item.selected = !item.selected
        updateIconView()
    }
    
    @objc func loadPreview(){
        _ = item.getPreview()
        updateItemView()
    }
    
}



