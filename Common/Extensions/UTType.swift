/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UniformTypeIdentifiers

@available(macOS 11.0, iOS 14.0, *)
public extension UTType {
    
    static var gpx: UTType {
        let tags = UTType.types(tag: "gpx", tagClass: .filenameExtension, conformingTo: .xml)
        return tags.first(where: { $0.identifier.contains("topografix") }) ?? tags.first!
    }
    
}
