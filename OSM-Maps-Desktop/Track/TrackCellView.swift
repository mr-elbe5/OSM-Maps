/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

protocol TrackCellDelegate{
    func editTrack(_ track: TrackItem)
    func showTrackOnMap(_ track: TrackItem)
}

class TrackCellView : MapItemCellView{
    
    var item: TrackItem
    
    var selectedButton: NSButton!
    var itemView = NSView()
    
    var delegate: TrackCellDelegate? = nil
    
    init(track: TrackItem){
        self.item = track
        super.init()
        backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView() {
        removeAllSubviews()
        let titleField = NSTextField(wrappingLabelWithString: "track".localize()).asHeadline()
        addSubviewWithAnchors(titleField, top: topAnchor, leading: leadingAnchor, insets: OSInsets.defaultInsets)
        let iconBar = IconBar()
        addSubviewWithAnchors(iconBar, top: topAnchor, trailing: trailingAnchor, insets: OSInsets.smallInsets)
        let showOnMapButton = NSButton(icon: "map", target: self, action: #selector(showTrackOnMap))
        iconBar.addArrangedSubview(showOnMapButton)
        let editButton = NSButton(icon: "pencil", target: self, action: #selector(editTrack))
        iconBar.addArrangedSubview(editButton)
        selectedButton = NSButton(icon: item.selected ? "checkmark.square" : "square", target: self, action: #selector(selectionChanged))
        iconBar.addArrangedSubview(selectedButton)
        addSubviewWithAnchors(itemView, top: iconBar.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: OSInsets.smallInsets)
        setupItemView()
    }
    
    func setupItemView(){
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
    
    override func updateIconView() {
        selectedButton.image = NSImage(systemSymbolName: item.selected ? "checkmark.square" : "square", accessibilityDescription: .none)
    }
    
    @objc func showTrackOnMap(){
        delegate?.showTrackOnMap(item)
    }
    
    @objc func editTrack(){
        delegate?.editTrack(item)
    }
    
    @objc func selectionChanged(){
        item.selected = !item.selected
        updateIconView()
    }
    
    @objc func loadPreview(){
        _ = item.getPreview()
        setupItemView()
    }
    
}
