/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

class CloudStatus{
    
    var cloudItems: Int = 0
    var updatedCloudItems: Int = 0
    var extraCloudItems: Int = 0
    var localItems: Int = 0
    var updatedLocalItems: Int = 0
    var extraLocalItems: Int = 0
    
    var text: String{
        """
            \("cloudStatusRemoteItems".localize()): \(cloudItems)
            \("cloudStatusUpdatedRemoteItems".localize()): \(updatedCloudItems)
            \("cloudStatusExtraRemoteItems".localize()): \(extraCloudItems)
            \("cloudStatusLocalItems".localize()): \(localItems)
            \("cloudStatusUpdatedLocalItems".localize()): \(updatedLocalItems)
            \("cloudStatusExtraLocalItems".localize()): \(extraLocalItems)
        """
    }
    
}
