/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import AppKit

class GridItem: NSCollectionViewItem{
    
    var item: MapItem
    
    init(item: MapItem) {
        self.item = item
        super.init(nibName: "", bundle: nil)
        setHighlightState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func select(_ flag: Bool){
        isSelected = flag
        item.selected = flag
    }
    
    func setHighlightState() {
        view.backgroundColor = isSelected ? NSColor(white: 0.7, alpha: 0.3) : .black
    }

}
