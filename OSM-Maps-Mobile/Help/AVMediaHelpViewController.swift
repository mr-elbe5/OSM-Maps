/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers

class AVMediaHelpViewController: ScrollViewController{
    
    
    override func loadView() {
        title = "helpAVMedia".localize(table: "Help")
        super.loadView()
        view.addSubviewFillingSafeArea(scrollView, insets: .zero)
        scrollView.backgroundColor = .systemBackground
        setupScrollView()
        loadScrollableSubviews()
    }
    
    func loadScrollableSubviews() {
        
        let iconText = HelpText(icon: "video.badge.waveform", key: "avMediaList")
        contentView.addSubviewBelow(iconText)
        var text = HelpText(key: "helpAVMediaText")
        contentView.addSubviewBelow(text, upperView: iconText)
            .connectToBottom(of: contentView)
        
    }
    
}
