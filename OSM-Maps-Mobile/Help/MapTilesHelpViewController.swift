/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers

class MapTilesHelpViewController: ScrollViewController{
    
    
    override func loadView() {
        title = "helpMapTiles".localize(table: "Help")
        super.loadView()
        view.addSubviewFillingSafeArea(scrollView, insets: .zero)
        scrollView.backgroundColor = .systemBackground
        setupScrollView()
        loadScrollableSubviews()
    }
    
    func loadScrollableSubviews() {
        
        let header = HelpText(icon: "map", headerKey: "helpMapTiles")
        contentView.addSubviewBelow(header)
        let text = HelpText(key: "helpMapTilesText")
        contentView.addSubviewBelow(text, upperView: header)
        
    }
    
}
