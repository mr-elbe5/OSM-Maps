/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

struct BasePaths {
    
    static let tempURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    static let privateURL : URL = FileManager.default.urls(for: .applicationSupportDirectory,in: FileManager.SearchPathDomainMask.userDomainMask).first!
    static var tileDirURL : URL = privateURL.appendingPathComponent("tiles")
    static var statusDirURL : URL = privateURL.appendingPathComponent("status")
    static var imageDirURL : URL = BasePaths.privateURL.appendingPathComponent("images")
    static var previewDirURL : URL = BasePaths.privateURL.appendingPathComponent("previews")
    static var cloudTokenURL : URL = BasePaths.privateURL.appendingPathComponent("cloudToken.bin")
    
    static func initializeDirs() {
        try! FileManager.default.createDirectory(at: privateURL, withIntermediateDirectories: true, attributes: nil)
        Log.debug("base dir is: \(privateURL.path)")
        try! FileManager.default.createDirectory(at: statusDirURL, withIntermediateDirectories: true, attributes: nil)
        //Log.debug("status dir is: \(statusDirURL.path)")
        try! FileManager.default.createDirectory(at: tileDirURL, withIntermediateDirectories: true, attributes: nil)
        //Log.debug("tile dir is: \(tileDirURL.path)")
        try! FileManager.default.createDirectory(at: imageDirURL, withIntermediateDirectories: true, attributes: nil)
        //Log.debug("image dir is: \(imageDirURL.path)")
        try! FileManager.default.createDirectory(at: previewDirURL, withIntermediateDirectories: true, attributes: nil)
        //Log.debug("preview dir is: \(previewDirURL.path)")
    }
    
}
