/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

protocol ImageCellDelegate{
    func editImage(_ image: ImageItem)
}

class ImageCellView : MapItemCellView{
    
    var image: ImageItem
    
    var selectedButton: NSButton!
    
    var delegate: ImageCellDelegate? = nil
    
    init(image: ImageItem){
        self.image = image
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView() {
        super.setupView()
        let titleField = NSTextField(wrappingLabelWithString: "image".localize()).asHeadline()
        addSubviewWithAnchors(titleField, top: topAnchor, leading: leadingAnchor, insets: OSInsets.defaultInsets)
        let iconBar = IconBar()
        addSubviewWithAnchors(iconBar, top: topAnchor, trailing: trailingAnchor, insets: OSInsets.smallInsets)
        let showButton = NSButton(icon: "square.resize.up", target: self, action: #selector(showImage))
        iconBar.addArrangedSubview(showButton)
        let editButton = NSButton(icon: "pencil", target: self, action: #selector(editImage))
        iconBar.addArrangedSubview(editButton)
        selectedButton = NSButton(icon: image.selected ? "checkmark.square" : "square", target: self, action: #selector(selectionChanged))
        iconBar.addArrangedSubview(selectedButton)
        var lastView: NSView = iconBar
        if let image = image.preview{
            let imageView = NSImageView(image: image)
            imageView.compressable()
            imageView.setAspectRatioConstraint()
            addSubviewWithAnchors(imageView, top: lastView.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor)
            lastView = imageView
        }
        lastView.bottom(bottomAnchor)
    }
    
    override func updateIconView() {
        selectedButton.image = NSImage(systemSymbolName: image.selected ? "checkmark.square" : "square", accessibilityDescription: .none)
    }
    
    @objc func showImage(){
        MainViewController.shared.showImage(image)
    }
    
    @objc func editImage(){
        delegate?.editImage(image)
    }
    
    @objc func selectionChanged(){
        image.selected = !image.selected
        updateIconView()
    }
    
}
