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
    
    override init(){
        super.init()
        popover.contentViewController = self
        popover.behavior = .semitransient
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = PopoverView(controller: self)
    }
    
    func close(){
        popover.performClose(nil)
    }
    
}

class PopoverView: NSView{
    
    var controller: PopoverViewController
    
    init(controller: PopoverViewController){
        self.controller = controller
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func close(){
        controller.close()
    }
    
}

