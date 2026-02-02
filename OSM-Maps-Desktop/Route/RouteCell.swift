/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

import CoreLocation

class RouteCell: MapItemCell{
    
    static var pinColor = NSColor(red: 0.25, green: 0.5, blue: 1.0, alpha: 1.0)
    
    var item : RouteItem
    
    var selectedButton: NSButton!
    
    init(route: RouteItem){
        self.item = route
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateIconView(){
        iconView.removeAllSubviews()
        selectedButton = NSButton(icon: item.selected ? "checkmark.square" : "square", color: .lightColor, backgroundColor: .darkColor, target: self, action: #selector(toggleSelection))
        iconView.addSubviewToLeft(selectedButton, insets: iconInsets)
        let showOnMapButton = NSButton(icon: "map", color: .lightColor, backgroundColor: .darkColor, target: self, action: #selector(showRouteOnMap))
        iconView.addSubviewToLeft(showOnMapButton, rightView: selectedButton, insets: iconInsets)
            .connectToLeft(of: iconView)
        showOnMapButton.isEnabled = item.hasValidCoordinate
    }
    
    override func setupTimeLabel(){
        timeLabel.stringValue = item.creationDate.dateTimeString()
    }
    
    override func setupMapIcon() {
        mapIconView.image = NSImage(systemSymbolName: item.hasValidCoordinate ? "mappin" : "mappin.slash", accessibilityDescription: nil)!.withTintColor(Self.pinColor)
    }
    
    override func updateItemView(){
        itemView.removeAllSubviews()
        let nameLabel = NSTextField(wrappingLabelWithString: item.route.name)
        itemView.addSubviewWithAnchors(nameLabel, top: itemView.topAnchor)
            .centerX(centerXAnchor)
        var rp = item.route.routepoints.isEmpty ? nil : item.route.routepoints.first
        let startLabel = NSTextField(labelWithString: "\("start".localize()): \(rp?.coordinate.asString ?? ""))")
        itemView.addSubviewBelow(startLabel, upperView: nameLabel)
        
        rp = item.route.routepoints.isEmpty ? nil : item.route.routepoints.last
        let endLabel = NSTextField(labelWithString: "\("end".localize()): \(rp?.coordinate.asString ?? ""))")
        itemView.addSubviewBelow(endLabel, upperView: startLabel)
        let distLabel = NSTextField(labelWithString: "\("distance".localize()): \(Int(item.route.distance))m")
        itemView.addSubviewBelow(distLabel, upperView: endLabel)
        let typeLabel = NSTextField(labelWithString: "\("routeType".localize()): \(("routeType_" + item.route.type.rawValue).localize())")
        itemView.addSubviewBelow(typeLabel, upperView: distLabel)
        let durationLabel = NSTextField(labelWithString: "\("duration".localize()): \(item.route.duration.hmString())")
        itemView.addSubviewBelow(durationLabel, upperView: typeLabel)
        
        var lastView: NSView = durationLabel
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
    
    @objc func showRouteOnMap(){
        MainViewController.shared.showRouteOnMap(item)
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



