/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

import CoreLocation

class ImageCell: MapItemCell{
    
    var item : ImageItem
    
    var selectedButton: NSButton!
    
    init(image: ImageItem){
        self.item = image
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateIconView(){
        iconView.removeAllSubviews()
        selectedButton = NSButton(icon: item.selected ? "checkmark.square" : "square", color: .lightColor, backgroundColor: .darkColor, target: self, action: #selector(toggleSelection))
        iconView.addSubviewToLeft(selectedButton, insets: iconInsets)
        let editButton = NSButton(icon: "pencil", color: .lightColor, backgroundColor: .darkColor, target: self, action: #selector(editImage))
        iconView.addSubviewToLeft(editButton, rightView: selectedButton, insets: iconInsets)
        let showButton = NSButton(icon: "magnifyingglass", color: .lightColor, backgroundColor: .darkColor, target: self, action: #selector(showImage))
        iconView.addSubviewToLeft(showButton, rightView: editButton, insets: iconInsets)
            .connectToLeft(of: iconView)
    }
    
    override func setupTimeLabel(){
        timeLabel.stringValue = item.creationDate.dateTimeString()
    }
    
    override func setupMapIcon() {
        mapIconView.image = NSImage(systemSymbolName: item.hasValidCoordinate ? "mappin" : "mappin.slash", accessibilityDescription: nil)!.withTintColor(.red)
    }
    
    override func updateItemView(){
        itemView.removeAllSubviews()
        let imageView = NSImageView()
        imageView.setRoundedBorders()
        imageView.image = item.preview
        imageView.setAspectRatioConstraint()
        itemView.addSubviewFilling(imageView, insets: .zero)
    }
    
    @objc func toggleSelection(){
        item.selected = !item.selected
        selectedButton.image = NSImage(systemSymbolName: item.selected ? "checkmark.square" : "square", accessibilityDescription: nil)
    }
    
    @objc func showImage(){
        MainViewController.shared.showImage(item)
    }
    
    @objc func editImage(){
        MainViewController.shared.editImage(item)
    }
    
}



