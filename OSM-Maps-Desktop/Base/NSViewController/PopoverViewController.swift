/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */


import AppKit

class PopoverViewController: ViewController {
    
    static var backgroundColor: NSColor = NSColor(red: 48.0/255.0, green: 50.0/255.0, blue: 53.0/255.0, alpha: 1.0)
    static var bezelColor: NSColor = NSColor(red: 100.0/255.0, green: 101.0/255.0, blue: 104.0/255.0, alpha: 1.0)
    
    var popover = NSPopover()
    
    var contentView: NSView? = nil
    
    override init(){
        super.init()
        popover.contentViewController = self
        popover.behavior = .semitransient
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        if let contentView = contentView{
            view.addSubviewFilling(contentView, insets: .smallInsets)
            contentView.setupView()
        }
    }
    
    func close(){
        popover.performClose(nil)
    }
    
}

