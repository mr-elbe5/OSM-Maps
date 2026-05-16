/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import OSLog

extension FileManager{
    
    static let documentsURL : URL = FileManager.default.urls(for: .documentDirectory,in: FileManager.SearchPathDomainMask.userDomainMask).first!
    static let imagesURL : URL = FileManager.default.urls(for: .picturesDirectory,in: FileManager.SearchPathDomainMask.userDomainMask).first!
    static let movieLibraryURL : URL = FileManager.default.urls(for: .moviesDirectory,in: FileManager.SearchPathDomainMask.userDomainMask).first!
    
    static func initializeAppDirs() {
        Logger.info("document folder is \(FileManager.documentsURL.path())")
        Logger.info("image folder is \(FileManager.imagesURL.path())")
    }
    
}
