/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

class SplitView: NSView{
    
    var mainView: NSView
    var separator = ViewSeparator()
    var sideView: NSView
    var sideViewWidthConstraint = NSLayoutConstraint()
    
    var minSideWidth: CGFloat = 300
    
    var defaultSideWidth: CGFloat{
        minSideWidth
    }
    
    var maxSideWidth: CGFloat{
        bounds.width / 2
    }
    
    init(mainView: NSView, sideView: NSView) {
        self.mainView = mainView
        self.sideView = sideView
        super.init(frame: .zero)
        self.sideViewWidthConstraint = sideView.widthAnchor.constraint(equalToConstant: minSideWidth)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView() {
        addSubviewToRight(mainView, insets: OSInsets(top: 2, left: 0, bottom: 0, right: 0))
        separator.delegate = self
        addSubviewToRight(separator, leftView: mainView, insets: .zero)
            .width(6)
        addSubviewToRight(sideView, leftView: separator, insets: .zero)
            .connectToRight(of: self)
        sideViewWidthConstraint.isActive = true
    }
    
    func setSideWidth(_ width: CGFloat){
        sideViewWidthConstraint.constant = width
    }
    
    func closeSideView(){
        setSideWidth(0)
    }
    
    func openSideView(){
        setSideWidth(defaultSideWidth)
    }
    
    func toggleSideView(){
        if sideViewWidthConstraint.constant <= minSideWidth{
            setSideWidth(defaultSideWidth)
        }
        else{
            setSideWidth(0)
        }
    }
    
}

extension SplitView: ViewSeparatorDelegate{
    
    func dragged(by dx: CGFloat){
        sideViewWidthConstraint.constant = min(max(minSideWidth, sideViewWidthConstraint.constant - dx), maxSideWidth)
    }
    
}
