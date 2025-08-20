/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import PhotosUI

extension PHPhotoLibrary{
    
    static func checkAuthorization(result: @escaping (Bool) -> Void){
        PHPhotoLibrary.requestAuthorization { status in
            result(status == .authorized)
        }
    }
    
}
