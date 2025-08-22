/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

#if os(iOS) || os(macOS)

#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS)
public typealias OSColor = NSColor
#else
public typealias OSColor = UIColor
#endif

public extension OSColor {
    
    static var lightColor = OSColor(white: 0.8, alpha: 1.0)
    static var darkColor = OSColor(white: 0.2, alpha: 1.0)
    static var blueColor = OSColor.systemBlue
    static var warnColor = OSColor.systemRed
    
    static var lightBackgroundColor = OSColor(white:0.9, alpha: 1.0)
    
    static var transparentColor = OSColor(white: 1.0, alpha: 0.7)
    
    static var iconViewBackgroundColor = OSColor(white: 0.95, alpha: 1.0)
    
}

#endif
