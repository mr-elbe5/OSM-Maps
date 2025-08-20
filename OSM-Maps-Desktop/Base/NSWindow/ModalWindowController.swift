/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

import AppKit

protocol ModalResponder{
    var responseCode: NSApplication.ModalResponse{get set}
}

class ModalWindowController: NSWindowController, NSWindowDelegate{
    
    convenience init(title: String, viewController: NSViewController, outerWindow: NSWindow, minSize: CGSize){
        let window = ModalWindow(
            contentRect: .zero,
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false)
        window.minSize = minSize
        window.title = title
        window.level = .modalPanel
        window.outerWindow = outerWindow
        self.init(window: window)
        window.delegate = self
        contentViewController = viewController
    }
    
    func windowWillClose(_ notification: Notification) {
        if let responder = contentViewController as? ModalResponder{
            NSApp.stopModal(withCode: responder.responseCode)
        }
        else{
            NSApp.stopModal()
        }
    }
    
}
