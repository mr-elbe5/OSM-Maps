/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers

class TrackHelpViewController: ScrollViewController{
    
    
    override func loadView() {
        title = "helpTracks".localize(table: "Help")
        super.loadView()
        view.addSubviewFillingSafeArea(scrollView, insets: .zero)
        scrollView.backgroundColor = .systemBackground
        setupScrollView()
        loadScrollableSubviews()
    }
    
    func loadScrollableSubviews() {
        
        let iconText = HelpText(icon: "figure.walk", key: "tracksList")
        contentView.addSubviewBelow(iconText)
        let text = HelpText(key: "helpTracksText")
        contentView.addSubviewBelow(text, upperView: iconText)
            .connectToBottom(of: contentView)
        
    }
    
}
