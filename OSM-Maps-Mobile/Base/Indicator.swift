/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

import UIKit

class Indicator{
    
    var indicatorView = UIView()
    var activityIndicator = UIActivityIndicatorView()

    class var shared: Indicator {
        struct Static {
            static let instance: Indicator = Indicator()
        }
        return Static.instance
    }

    func show(in window: UIWindow) {
        indicatorView.frame = CGRect(x:0, y:0, width:80, height:80)
        indicatorView.center = CGPoint(x: window.frame.width / 2.0, y: window.frame.height / 2.0)
        indicatorView.backgroundColor = .white
        indicatorView.clipsToBounds = true
        indicatorView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0, y:0, width: 40, height: 40)
        activityIndicator.style = .large
        activityIndicator.center = CGPoint(x: indicatorView.bounds.width / 2, y: indicatorView.bounds.height / 2)
        
        indicatorView.addSubview(activityIndicator)
        window.addSubview(indicatorView)
        activityIndicator.startAnimating()
    }
    
    func hide() {
        activityIndicator.stopAnimating()
        indicatorView.removeFromSuperview()
    }
    
}

