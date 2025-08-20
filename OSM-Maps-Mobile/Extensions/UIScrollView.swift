/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

extension UIScrollView{
    
    func setupVertical(){
        self.isScrollEnabled = true
        let scflg = self.contentLayoutGuide
        let svflg = self.frameLayoutGuide
        scflg.widthAnchor.constraint(equalTo: svflg.widthAnchor).isActive = true
    }
    
}

