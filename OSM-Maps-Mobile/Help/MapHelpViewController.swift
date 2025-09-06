/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers

class MapHelpViewController: ScrollViewController{
    
    
    override func loadView() {
        title = "helpMap".localize(table: "Help")
        super.loadView()
        view.addSubviewFillingSafeArea(scrollView, insets: .zero)
        scrollView.backgroundColor = .systemBackground
        setupScrollView()
        loadScrollableSubviews()
    }
    
    func loadScrollableSubviews() {
        
        let text = HelpText(key: "helpMapText")
        contentView.addSubviewBelow(text)
            .connectToBottom(of: contentView)
        
    }
    
}
