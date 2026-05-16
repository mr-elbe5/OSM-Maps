/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import OSLog

extension Logger {
    
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let logger = Logger(subsystem: subsystem, category: "log")
    
    static func debug(_ message: String) {
        logger.debug("\(message)")
    }
    
    static func debug(_ int: Int) {
        logger.debug("\(int)")
    }

    static func info(_ message: String) {
        logger.info("\(message)")
    }

    static func error(_ message: String, _ error: Error) {
        logger.error("\(message): \(error)")
    }
    
    static func error(_ message: String) {
        logger.error("\(message)")
    }
    
    static func error(error: Error) {
        logger.error("\(error)")
    }
    
}


