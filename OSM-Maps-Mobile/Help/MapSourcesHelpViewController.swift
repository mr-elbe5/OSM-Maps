/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers

class MapSourcesHelpViewController: ScrollViewController{
    
    
    override func loadView() {
        title = "helpMapSources".localize(table: "Help")
        super.loadView()
        view.addSubviewFillingSafeArea(scrollView, insets: .zero)
        scrollView.backgroundColor = .systemBackground
        setupScrollView()
        loadScrollableSubviews()
    }
    
    func loadScrollableSubviews() {
        
        let header = HelpText(icon: "map", headerKey: "helpMapSources")
        contentView.addSubviewBelow(header)
        let text = HelpText(key: "helpMapSourcesText")
        contentView.addSubviewBelow(text, upperView: header)
        
    }
    
}
