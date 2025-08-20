/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

class GPSStatusView : UIView{
    
    static let radius: CGFloat = 5
    
    var circle1 = CircleView(radius: GPSStatusView.radius)
    var circle2 = CircleView(radius: GPSStatusView.radius)
    var circle3 = CircleView(radius: GPSStatusView.radius)
    var circle4 = CircleView(radius: GPSStatusView.radius)
    
    var accuracy: CGFloat = .infinity
    
    var toggleTrackingButton = UIButton().asIconButton("figure.walk.departure", color: .darkText)
    
    func setup(){
        backgroundColor = .clear
        addSubviewToRight(circle1, insets: OSInsets.smallInsets)
            .width(2*Self.radius).height(2*Self.radius)
        addSubviewToRight(circle2, leftView: circle1, insets: OSInsets.smallInsets)
            .width(2*Self.radius).height(2*Self.radius)
        addSubviewToRight(circle3, leftView: circle2, insets: OSInsets.smallInsets)
            .width(2*Self.radius).height(2*Self.radius)
        addSubviewToRight(circle4, leftView: circle3, insets: OSInsets.smallInsets)
            .width(2*Self.radius).height(2*Self.radius)
            .connectToRight(of: self)
    }
    
    func update(accuracy: CGFloat){
        if accuracy != self.accuracy{
            self.accuracy = accuracy
            circle1.setActive(accuracy < LocationDistance.extraWide.distance)
            circle2.setActive(accuracy < LocationDistance.wide.distance)
            circle3.setActive(accuracy < LocationDistance.medium.distance)
            circle4.setActive(accuracy < LocationDistance.tight.distance)
        }
    }
    
    class CircleView: UIView {
        init(radius: CGFloat) {
            super.init(frame: .zero)
            backgroundColor = .white
            layer.cornerRadius = radius
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setActive(_ active: Bool){
            backgroundColor = active ? .systemBlue : .white
        }
    }
    
}
