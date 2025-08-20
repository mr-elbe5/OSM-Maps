/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

class LocationStatusView : UIView{
    
    var compassLabel = UILabel(text: "0°").withTextColor(.darkText)
    var heightLabel = UILabel(text: "0 m").withTextColor(.darkText)
    
    func setup(){
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        let compassIcon = UIImageView(image: UIImage(systemName: "safari"))
        compassIcon.tintColor = .darkText
        addSubviewToRight(compassIcon, insets: OSInsets.smallInsets)
        compassLabel = UILabel(text: "0°").withTextColor(.darkText)
        addSubviewToRight(compassLabel, leftView: compassIcon, insets: OSInsets.smallInsets)
        let heightIcon = UIImageView(image: UIImage(systemName: "mountain.2.circle"))
        heightIcon.tintColor = .darkText
        addSubviewToRight(heightIcon, leftView: compassLabel, insets: OSInsets.smallInsets)
        addSubviewToRight(heightLabel, leftView: heightIcon, insets: OSInsets.smallInsets)
    }
    
    func updateLocationInfo(location: CLLocation){
        heightLabel.text = "\(Int(location.altitude)) m"
    }
    
    func updateDirection(direction: CLLocationDirection) {
        compassLabel.text="\(Int(direction))°"
    }
    
}
