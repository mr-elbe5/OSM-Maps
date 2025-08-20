/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import AVFoundation

class OrientationStatus {
    
    static let shared = OrientationStatus()
    
    var orientation = UIDeviceOrientation.unknown
    
    var rotationAngle: CGFloat?{
        switch OrientationStatus.shared.orientation {
        case .portrait: return 90
        case .landscapeLeft: return 0
        case .landscapeRight: return 180
        default: return nil
        }
    }
    
}
