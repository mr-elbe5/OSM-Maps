/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

struct GenericError: Error {
    
    var text: String
    
    init(_ text: String){
        self.text = text
    }
    
    var errorDescription: String? {
        return text.localize()
    }
    
}
