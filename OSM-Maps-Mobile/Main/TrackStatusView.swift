/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

class TrackStatusView : UIView{
    
    var distanceLabel = UILabel(text: "0 m")
    var distanceUpLabel = UILabel(text: "0 m")
    var distanceDownLabel = UILabel(text: "0 m")
    var timeLabel = UILabel()
    
    func setup(){
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        let distanceIcon = UIImageView(image: UIImage(systemName: "arrow.right"))
        distanceIcon.tintColor = .darkText
        addSubviewWithAnchors(distanceIcon, top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, insets: OSInsets.smallInsets)
        distanceLabel.textColor = .darkText
        addSubviewWithAnchors(distanceLabel, top: topAnchor, leading: distanceIcon.trailingAnchor, bottom: bottomAnchor, insets: OSInsets.smallInsets)
        
        let distanceUpIcon = UIImageView(image: UIImage(systemName: "arrow.up"))
        distanceUpIcon.tintColor = .darkText
        addSubviewWithAnchors(distanceUpIcon, top: topAnchor, leading: distanceLabel.trailingAnchor, bottom: bottomAnchor, insets: OSInsets.smallInsets)
        distanceUpLabel.textColor = .darkText
        addSubviewWithAnchors(distanceUpLabel, top: topAnchor, leading: distanceUpIcon.trailingAnchor, bottom: bottomAnchor, insets: OSInsets.smallInsets)
        
        let distanceDownIcon = UIImageView(image: UIImage(systemName: "arrow.down"))
        distanceDownIcon.tintColor = .darkText
        addSubviewWithAnchors(distanceDownIcon, top: topAnchor, leading: distanceUpLabel.trailingAnchor, bottom: bottomAnchor, insets: OSInsets.smallInsets)
        distanceDownLabel.textColor = .darkText
        addSubviewWithAnchors(distanceDownLabel, top: topAnchor, leading: distanceDownIcon.trailingAnchor, bottom: bottomAnchor, insets: OSInsets.smallInsets)
        
        let timeIcon = UIImageView(image: UIImage(systemName: "stopwatch"))
        timeIcon.tintColor = .darkText
        addSubviewWithAnchors(timeIcon, top: topAnchor, leading: distanceDownLabel.trailingAnchor, bottom: bottomAnchor, insets: OSInsets.smallInsets)
        timeLabel.textColor = .darkText
        addSubviewWithAnchors(timeLabel, top: topAnchor, leading: timeIcon.trailingAnchor, bottom: bottomAnchor, insets: OSInsets.smallInsets)
    }
    
    func startTrackInfo(){
        isHidden = false
        updateTrackInfo()
    }
    
    func updateTrackInfo(){
        if let track = TrackRecorder.shared.track{
            distanceLabel.text = "\(Int(track.distance)) m"
            distanceUpLabel.text = "\(Int(track.upDistance)) m"
            timeLabel.text = track.durationUntilNow.hmsString()
        }
    }
    
    func stopTrackInfo(){
        distanceLabel.text = "0 m"
        distanceUpLabel.text = "0 m"
        timeLabel.text = ""
        isHidden = true
    }
    
}
