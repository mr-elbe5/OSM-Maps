/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */


import AppKit

extension NSScrollView{
    
    var clipView: NSClipView{
        contentView
    }
    
    var contentRect: CGRect{
        clipView.documentRect
    }
    
    var contentOffset: CGPoint{
        documentVisibleRect.origin
    }
    
    var visibleContentRect: CGRect{
        clipView.documentVisibleRect
    }
    
    // positive value!
    var scrollOrigin: CGPoint{
        documentVisibleRect.origin
    }
    
    func addFlippedClipView(){
        contentView = FlippedClipView()
        addSubviewFilling(contentView, insets: .zero)
    }
    
    func addClipView(){
        contentView = NSClipView()
        addSubviewFilling(contentView, insets: .zero)
    }
    
    var maxScrollX: CGFloat{
        contentRect.width - visibleContentRect.width
    }
    
    var maxScrollY: CGFloat{
        contentRect.height - visibleContentRect.height
    }
    
    func getSafeScrollPoint(contentPoint: CGPoint) -> CGPoint{
        CGPoint(x: min(max(0, contentPoint.x - visibleContentRect.width/2), maxScrollX) ,
                                  y: min(max(0, contentPoint.y - visibleContentRect.height/2), maxScrollY))
    }
    
    func scrollTo(_ scrollPoint: CGPoint){
        scroll(clipView, to: scrollPoint)
    }
    
    func scrollBy(dx: CGFloat, dy: CGFloat){
        scroll(clipView, to: CGPoint(x: contentOffset.x + dx, y: contentOffset.y + dy))
    }
    
}

final class FlippedClipView: NSClipView {
    
    override var isFlipped: Bool {
        return true
    }
    
}

extension NSScrollView{
    
    var screenCenter : CGPoint{
        CGPoint(x: bounds.width/2, y: bounds.height/2)
    }
    
    func asVerticalScrollView(contentView: NSView, insets : OSInsets = .defaultInsets){
        self.hasVerticalScroller = true
        self.hasHorizontalScroller = false
        let clipView = FlippedClipView()
        self.contentView = clipView
        self.documentView = contentView
        contentView.setAnchors(top:clipView.topAnchor, leading: clipView.leadingAnchor, trailing: clipView.trailingAnchor)
    }
    
    func asScrollView(contentView: NSView, insets : OSInsets = .defaultInsets){
        self.hasVerticalScroller = true
        self.hasHorizontalScroller = true
        let clipView = FlippedClipView()
        self.contentView = clipView
        self.documentView = contentView
        contentView.setAnchors(top:clipView.topAnchor, leading: clipView.leadingAnchor)
    }
    
    func addScrollNotifications(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(scrollViewDidScroll),
            name: NSScrollView.didLiveScrollNotification,
            object: self
        )
    }
    
    func addZoomNotifications(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(scrollViewDidZoom),
            name: NSScrollView.didEndLiveMagnifyNotification,
            object: self
        )
    }
    
    @objc func scrollViewDidScroll(){
    }
    
    @objc func scrollViewDidZoom(){
    }
    
}

