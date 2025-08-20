/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit


extension UITableView {
    
    func withLayout(backgroundColor: UIColor = .systemBackground) -> UITableView{
        self.backgroundColor = backgroundColor
        allowsSelection = false
        allowsSelectionDuringEditing = false
        separatorStyle = .none
        return self
    }
    
}
