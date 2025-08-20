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
public typealias OSInsets = NSEdgeInsets
#else
public typealias OSInsets = UIEdgeInsets
#endif

public extension OSInsets {
    
    static var smallInset : CGFloat = 5
    
    static var defaultInset : CGFloat = 10
    
    static var zero = OSInsets(top: 0,left: 0,bottom: 0,right: 0)

    static var smallInsets = OSInsets(top: smallInset, left: smallInset, bottom: smallInset, right: smallInset)
    
    static var defaultInsets = OSInsets(top: defaultInset, left: defaultInset, bottom: defaultInset, right: defaultInset)

    static var flatInsets = OSInsets(top: 0, left: defaultInset, bottom: 0, right: defaultInset)

    static var narrowInsets = OSInsets(top: defaultInset, left: 0, bottom: defaultInset, right: 0)
    
    static var wideInsets = OSInsets(top: defaultInset, left: 2*defaultInset, bottom: defaultInset, right: 2*defaultInset)

    static var reverseInsets = OSInsets(top: -defaultInset, left: -defaultInset, bottom: -defaultInset, right: -defaultInset)

    static var doubleInsets = OSInsets(top: 2 * defaultInset, left: 2 * defaultInset, bottom: 2 * defaultInset, right: 2 * defaultInset)
    
}

#endif
