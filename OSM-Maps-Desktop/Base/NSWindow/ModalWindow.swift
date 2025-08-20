/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

import AppKit

class ModalWindow: NSWindow{
    
    static var defaultMinSize = CGSize(width: 300, height: 200)
    
    @discardableResult
    static func run(title: String, viewController: NSViewController, outerWindow: NSWindow, minSize: CGSize) -> NSApplication.ModalResponse{
        let controller = ModalWindowController(title: title, viewController: viewController, outerWindow: outerWindow, minSize: minSize)
        controller.window?.minSize = minSize
        return NSApp.runModal(for: controller.window!)
    }
    
    var outerWindow: NSWindow? = nil
    
    override func center(){
        if let outerFrame = outerWindow?.frame{
            let newOrigin = CGPoint(x: outerFrame.minX + (outerFrame.width - frame.width)/2, y: outerFrame.minY + outerFrame.height - frame.height - 100)
            self.setFrameOrigin(newOrigin)
        }
        else{
            super.center()
        }
    }
    
}
