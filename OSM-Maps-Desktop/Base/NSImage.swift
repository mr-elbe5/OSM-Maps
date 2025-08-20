/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

extension NSImage {
    
    func withTintColor(_ col: NSColor) -> NSImage{
        let config = NSImage.SymbolConfiguration(paletteColors: [col])
        return self.withSymbolConfiguration(config)!
    }
    
    var pixelSize: NSSize {
        guard representations.count > 0 else { return NSSize(width: 0, height: 0) }
        let rep = self.representations[0]
        return NSSize(width: rep.pixelsWide, height: rep.pixelsHigh)
    }
    
}

