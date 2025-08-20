/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit

extension CKAsset{
    
    var data: Data? {
        if let url = fileURL {
            return FileManager.default.readFile(url: url)
        }
        return nil
    }
    
}
