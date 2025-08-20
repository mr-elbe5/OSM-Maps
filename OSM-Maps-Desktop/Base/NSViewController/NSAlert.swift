/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import AppKit

extension NSAlert{

    // returns true if ok was pressed
    static func acceptWarning(message: String) -> Bool{
        let alert = NSAlert()
        alert.icon = NSImage(systemSymbolName: "exclamationmark.triangle", accessibilityDescription: nil)
        alert.alertStyle = .warning
        alert.messageText = message
        alert.addButton(withTitle: "ok".localize())
        alert.addButton(withTitle: "cancel".localize())
        let result = alert.runModal()
        return result == NSApplication.ModalResponse.alertFirstButtonReturn
    }
    
    // returns true if ok was pressed
    static func acceptWarning(title: String, message: String) -> Bool{
        let alert = NSAlert()
        alert.icon = NSImage(systemSymbolName: "exclamationmark.triangle", accessibilityDescription: nil)
        alert.alertStyle = .warning
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: "ok".localize())
        alert.addButton(withTitle: "cancel".localize())
        let result = alert.runModal()
        return result == NSApplication.ModalResponse.alertFirstButtonReturn
    }
    
    static func acceptInfo(title: String, message: String) -> Bool{
        let alert = NSAlert()
        alert.icon = NSImage(systemSymbolName: "checkmark", accessibilityDescription: nil)
        alert.alertStyle = .informational
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: "ok".localize())
        alert.addButton(withTitle: "cancel".localize())
        let result = alert.runModal()
        return result == NSApplication.ModalResponse.alertFirstButtonReturn
    }
    
    static func showSuccess(message: String){
        let alert = NSAlert()
        alert.icon = NSImage(systemSymbolName: "checkmark", accessibilityDescription: nil)
        alert.alertStyle = .informational
        alert.messageText = message
        alert.addButton(withTitle: "ok".localize())
        alert.runModal()
    }
    
    static func showSuccess(title: String, message: String){
        let alert = NSAlert()
        alert.icon = NSImage(systemSymbolName: "checkmark", accessibilityDescription: nil)
        alert.alertStyle = .informational
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: "ok".localize())
        alert.runModal()
    }
    
    static func showError(message: String){
        let alert = NSAlert()
        alert.icon = NSImage(systemSymbolName: "exclamationmark.triangle", accessibilityDescription: nil)
        alert.alertStyle = .critical
        alert.messageText = message
        alert.addButton(withTitle: "ok".localize())
        alert.runModal()
    }
    
    static func showMessage(message: String){
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = message
        alert.addButton(withTitle: "ok".localize())
        alert.runModal()
    }

}

