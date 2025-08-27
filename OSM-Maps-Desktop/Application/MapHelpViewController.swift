/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit


class MapHelpViewController: NSTabViewController, ModalResponder {
    
    var generalViewController = GeneralHelpViewController()
    var mapViewController = MapHelpViewController()
    var imageGridViewController = ImageGridHelpViewController()
    var trackGridViewController = TrackGridHelpViewController()
    
    var responseCode: NSApplication.ModalResponse = .cancel
    
    override func loadView() {
        super.loadView()
        
        let generalHelpItem = NSTabViewItem(viewController: generalViewController)
        generalHelpItem.label = "helpGeneral".localize(table: "Help")
        addTabViewItem(generalHelpItem)
        let mapHelpItem = NSTabViewItem(viewController: mapViewController)
        mapHelpItem.label = "helpMap".localize(table: "Help")
        addTabViewItem(mapHelpItem)
        let gridHelpItem = NSTabViewItem(viewController: imageGridViewController)
        gridHelpItem.label = "helpImageGrid".localize(table: "Help")
        addTabViewItem(gridHelpItem)
        let imageHelpItem = NSTabViewItem(viewController: trackGridViewController)
        imageHelpItem.label = "helpTrackGrid".localize(table: "Help")
        addTabViewItem(imageHelpItem)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

class GeneralHelpViewController: NSViewController{
    
    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = .black
        let font = NSFont.systemFont(ofSize: 14)
        let field = NSTextField(wrappingLabelWithString: "helpGeneralText".localize(table: "Help"))
        field.lineBreakMode = .byWordWrapping
        field.font = font
        view.addSubviewFilling(field, insets: OSInsets.defaultInsets)
    }
    
}

class MapHelpViewController: NSViewController{
    
    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        let font = NSFont.systemFont(ofSize: 14)
        let field = NSTextField(wrappingLabelWithString: "helpMapText".localize(table: "Help"))
        field.lineBreakMode = .byWordWrapping
        field.font = font
        view.addSubviewFilling(field, insets: OSInsets.defaultInsets)
    }
    
}

class ImageGridHelpViewController: NSViewController{
    
    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = .black
        let font = NSFont.systemFont(ofSize: 14)
        let field = NSTextField(wrappingLabelWithString: "helpImageGridText".localize(table: "Help"))
        field.lineBreakMode = .byWordWrapping
        field.font = font
        view.addSubviewFilling(field, insets: OSInsets.defaultInsets)
    }
    
}

class TrackGridHelpViewController: NSViewController{
    
    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = .black
        let font = NSFont.systemFont(ofSize: 14)
        let field = NSTextField(wrappingLabelWithString: "helpTrackGridText".localize(table: "Help"))
        field.lineBreakMode = .byWordWrapping
        field.font = font
        view.addSubviewFilling(field, insets: OSInsets.defaultInsets)
    }
    
}
