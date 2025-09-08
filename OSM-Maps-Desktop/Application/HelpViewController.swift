/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit


class HelpViewController: PopoverViewController {
    
    var contentView: HelpView{
        view as! HelpView
    }
    
    override func loadView() {
        view = HelpView(controller: self)
        view.frame = CGRect(origin: .zero, size: CGSize(width: 500, height: 0))
        contentView.setupView(height: MainViewController.shared.view.frame.height - 100)
    }
    
}

class HelpView: PopoverView{
    
    func setupView(height: CGFloat) {
        let scrollView = NSScrollView()
        let contentView = NSView()
        scrollView.asVerticalScrollView(contentView: contentView)
        addSubviewFilling(scrollView)
            .height(height)
        var header = NSTextField(labelWithString: "helpGeneral".localize(table: "Help")).asHeadline()
        contentView.addSubviewBelow(header)
        var text = NSTextField(wrappingLabelWithString: "helpGeneralText".localize(table: "Help"))
        contentView.addSubviewBelow(text, upperView: header)
        header = NSTextField(labelWithString: "helpMap".localize(table: "Help")).asHeadline()
        contentView.addSubviewBelow(header, upperView: text)
        text = NSTextField(wrappingLabelWithString: "helpMapText".localize(table: "Help"))
        contentView.addSubviewBelow(text, upperView: header)
        header = NSTextField(labelWithString: "helpImageGrid".localize(table: "Help")).asHeadline()
        contentView.addSubviewBelow(header, upperView: text)
        text = NSTextField(wrappingLabelWithString: "helpImageGridText".localize(table: "Help"))
        contentView.addSubviewBelow(text, upperView: header)
        header = NSTextField(labelWithString: "helpTrackGrid".localize(table: "Help")).asHeadline()
        contentView.addSubviewBelow(header, upperView: text)
        text = NSTextField(wrappingLabelWithString: "helpTrackGridText".localize(table: "Help"))
        contentView.addSubviewBelow(text, upperView: header)
            .connectToBottom(of: contentView)
    }
    
}
