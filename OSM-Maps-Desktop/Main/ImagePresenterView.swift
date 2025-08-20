/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import AVFoundation
import AVKit


class ImagePresenterView: NSView {
    
    var items = ImageItemList()
    var currentIdx = 0
    
    var imageView = NSImageView()
    var nextButton: NSButton!
    var previousButton: NSButton!
    var closeButton: NSButton!
    
    override func setupView(){
        backgroundColor = .black
        imageView.autoresizingMask = [.height, .width]
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubviewFilling(imageView)
        
        let config = NSImage.SymbolConfiguration(textStyle: .headline, scale: .large)
        let closeConfig = NSImage.SymbolConfiguration(textStyle: .headline, scale: .large)
        nextButton = NSButton(image: NSImage(systemSymbolName: "chevron.right", accessibilityDescription: nil)!
            .withSymbolConfiguration(config)!, target: self, action: #selector(nextImage))
        nextButton.bezelStyle = .inline
        nextButton.keyEquivalent = NSString(characters: [unichar(NSRightArrowFunctionKey)], length: 1) as String
        addSubview(nextButton)
        nextButton.setAnchors().trailing(trailingAnchor, inset: -20)
            .centerY(centerYAnchor)
        previousButton = NSButton(image: NSImage(systemSymbolName: "chevron.left", accessibilityDescription: nil)!
            .withSymbolConfiguration(config)!, target: self, action: #selector(previousImage))
        previousButton.bezelStyle = .inline
        previousButton.keyEquivalent = NSString(characters: [unichar(NSLeftArrowFunctionKey)], length: 1) as String
        addSubview(previousButton)
        previousButton.setAnchors().leading(leadingAnchor, inset: 20)
            .centerY(centerYAnchor)
        closeButton = NSButton(image: NSImage(systemSymbolName: "xmark.circle.fill", accessibilityDescription: nil)!.withTintColor(.systemRed)
            .withSymbolConfiguration(closeConfig)!, target: self, action: #selector(close))
        closeButton.bezelStyle = .inline
        closeButton.keyEquivalent = "\u{1b}"
        addSubview(closeButton)
        closeButton.setAnchors().top(topAnchor, inset: 20).leading(leadingAnchor, inset: 10)
        checkButtons()
    }
    
    func show(_ flag: Bool) {
        isHidden = !flag
    }
    
    func setImages(_ items: ImageItemList){
        self.items = items
        setImageView(item: items.first)
        currentIdx = 0
        checkButtons()
    }
    
    func setImage(item: ImageItem){
        var arr = ImageItemList()
        arr.append(item)
        setImages(arr)
        checkButtons()
    }
    
    func setImageView(item: ImageItem?){
        imageView.image = nil
        imageView.isHidden = true
        if let item = item, let img = item.image{
            imageView.isHidden = false
            imageView.image = img
        }
    }
    
    @objc func nextImage(){
        if currentIdx < items.count - 1{
            currentIdx += 1
            setImageView(item: items[currentIdx])
            checkButtons()
        }
    }
    
    @objc func previousImage(){
        if currentIdx > 0{
            currentIdx -= 1
            setImageView(item: items[currentIdx])
            checkButtons()
        }
    }
    
    @objc func close(){
        MainViewController.shared.closePresenter()
    }
    
    private func checkButtons(){
        previousButton.isHidden = currentIdx <= 0
        nextButton.isHidden = currentIdx >= items.count - 1
    }
    
}




