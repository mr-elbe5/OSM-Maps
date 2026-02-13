/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class ScrollViewController: UIViewController{
    
    var scrollView = UIScrollView()
    var contentView = UIView()
    
    func setupScrollView() {
        scrollView.scrollsToTop = false
        scrollView.alwaysBounceVertical = true
        scrollView.addSubviewWithAnchors(contentView, top: scrollView.topAnchor, leading: scrollView.leadingAnchor, bottom: scrollView.bottomAnchor)
            .width(scrollView.widthAnchor)
    }
    
    func addScrollViewFillingWithKeyboard() {
        view.addSubviewFillingSafeAreaWithKeyboard(scrollView, insets: .zero)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name:UIResponder.keyboardDidShowNotification, object: nil)
    }
        
    @objc func keyboardDidShow(notification:NSNotification){
        scrollForKeyboard()
    }
    
    func scrollForKeyboard(){
    }
    
    func scrollToTop(){
        let contentHeight = contentView.frame.height
        let scrollViewHeight = scrollView.frame.height
        if contentHeight > scrollViewHeight {
            scrollView.setContentOffset(CGPoint(x: 0, y: contentHeight - scrollViewHeight), animated: true)
        }
    }

}
