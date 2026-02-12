/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation


class EditTrackpointDetailView: NSView{
    
    var trackpointLabel = NSTextField(labelWithString: "")
    
    override func setupView() {
        backgroundColor = .black
        let label = NSTextField(labelWithString: "selectedTrackpoint".localizeWithColon())
        addSubviewWithAnchors(label, top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor)
        addSubviewWithAnchors(trackpointLabel, top: topAnchor, leading: label.trailingAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
    }
    
    func setTrackPoint(_ trackpoint: Mappoint?){
        if let trackpoint = trackpoint{
            if let altitude = trackpoint.altitude, let timestamp = trackpoint.timestamp{
                trackpointLabel.stringValue = "\(trackpoint.coordinate.asShortString), \(Int(altitude)) m, \(DateFormatter.localizedString(from: timestamp.toUTCDate(), dateStyle: .none, timeStyle: .medium))"
            }
            else{
                trackpointLabel.stringValue = "\(trackpoint.coordinate.asShortString))"
            }
        }
        else{
            trackpointLabel.stringValue = ""
        }
    }
}
