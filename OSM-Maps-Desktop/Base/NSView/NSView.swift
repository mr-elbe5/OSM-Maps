/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */


import AppKit

extension NSView{
    
    var backgroundColor: NSColor? {
        get {
            guard let color = layer?.backgroundColor else { return nil }
            return NSColor(cgColor: color)
        }
        set {
            wantsLayer = true
            layer?.backgroundColor = newValue?.cgColor
        }
    }
    
    func setRoundedBorders(){
        if let layer = layer{
            layer.borderWidth = 0.5
            layer.cornerRadius = 5
        }
    }

    func setGrayRoundedBorders(){
        if let layer = layer{
            layer.borderColor = NSColor.lightGray.cgColor
            layer.borderWidth = 0.5
            layer.cornerRadius = 10
        }
    }
    
    @discardableResult
    func compressable() -> NSView{
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return self
    }
    
    @objc func setupView(){
    }

}

class FlippedView: NSView{
    
    override var isFlipped: Bool {
        return true
    }
    
}

