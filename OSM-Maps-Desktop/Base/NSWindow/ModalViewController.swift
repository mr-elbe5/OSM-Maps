/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

import AppKit

class ModalViewController: ViewController, ModalResponder{
    
    var responseCode: NSApplication.ModalResponse = .cancel
    
}


