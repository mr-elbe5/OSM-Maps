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
    
}

struct Log{
    
    static func debug(_ message: String) {
        Logger.logger.debug("\(message)")
    }
    
    static func debug(_ int: Int) {
        Logger.logger.debug("\(int)")
    }

    static func info(_ message: String) {
        Logger.logger.info("\(message)")
    }

    static func error(_ message: String, _ error: Error) {
        Logger.logger.error("\(message): \(error)")
    }
    
    static func error(_ message: String) {
        Logger.logger.error("\(message)")
    }
    
    static func error(error: Error) {
        Logger.logger.error("\(error)")
    }

}

