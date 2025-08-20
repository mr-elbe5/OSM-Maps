/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

import AppKit

extension NSViewController{
    
    func showSuccess(title: String, text: String){
        NSAlert.showSuccess(title: title, message: text)
    }
    
    func showError(text: String){
        NSAlert.showError(message: text)
    }
    
    func showDestructiveApprove(title: String, text: String, onApprove: (() -> Void)? = nil){
        if NSAlert.acceptWarning(title: title, message: text){
            onApprove?()
        }
    }
    
    func showApprove(title: String, text: String, onApprove: (() -> Void)? = nil){
        if NSAlert.acceptInfo(title: title, message: text){
            onApprove?()
        }
    }
    
    func showInfo(text: String){
        NSAlert.showMessage(message: text)
    }
    
    func startSpinner() -> NSProgressIndicator{
        let spinner = NSProgressIndicator()
        spinner.style = .spinning
        spinner.controlSize = .regular
        view.addSubview(spinner)
        spinner.setAnchors(centerX: view.centerXAnchor, centerY: view.centerYAnchor)
        spinner.startAnimation(nil)
        return spinner
    }
    
    func stopSpinner(_ spinner: NSProgressIndicator?) {
        if let spinner = spinner{
            spinner.stopAnimation(nil)
            self.view.removeSubview(spinner)
        }
    }
    
}

