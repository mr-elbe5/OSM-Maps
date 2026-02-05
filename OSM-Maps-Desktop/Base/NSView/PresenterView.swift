/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

class PresenterView: NSView {
    
    var currentIdx = 0
    
    var nextButton: NSButton!
    var previousButton: NSButton!
    var closeButton: NSButton!
    
    var itemCount: Int{
        0
    }
    
    override func setupView(){
        backgroundColor = .black
        
        setupItemView()
        
        let config = NSImage.SymbolConfiguration(textStyle: .headline, scale: .large)
        let closeConfig = NSImage.SymbolConfiguration(textStyle: .headline, scale: .large)
        nextButton = NSButton(image: NSImage(systemSymbolName: "chevron.right", accessibilityDescription: nil)!
            .withSymbolConfiguration(config)!, target: self, action: #selector(nextItem))
        nextButton.bezelStyle = .inline
        nextButton.keyEquivalent = NSString(characters: [unichar(NSRightArrowFunctionKey)], length: 1) as String
        addSubview(nextButton)
        nextButton.setAnchors().trailing(trailingAnchor, inset: -20)
            .centerY(centerYAnchor)
        previousButton = NSButton(image: NSImage(systemSymbolName: "chevron.left", accessibilityDescription: nil)!
            .withSymbolConfiguration(config)!, target: self, action: #selector(previousItem))
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
    
    func setupItemView(){
    }
    
    func setCurrentItem()
    {
    }
    
    func show(_ flag: Bool) {
        isHidden = !flag
    }
    
    @objc func nextItem(){
        if currentIdx < itemCount - 1{
            currentIdx += 1
            setCurrentItem()
            checkButtons()
        }
    }
    
    @objc func previousItem(){
        if currentIdx > 0{
            currentIdx -= 1
            setCurrentItem()
            checkButtons()
        }
    }
    
    @objc func close(){
        removeFromSuperview()
    }
    
    func checkButtons(){
        previousButton.isHidden = currentIdx <= 0
        nextButton.isHidden = currentIdx >= itemCount - 1
    }
    
}




