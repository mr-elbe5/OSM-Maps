/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS)
public typealias OSViewController = NSViewController
#else
public typealias OSViewController = UIViewController
#endif
