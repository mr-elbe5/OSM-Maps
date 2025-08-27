/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers

class ImageHelpViewController: ScrollViewController{
    
    
    override func loadView() {
        title = "helpImage".localize(table: "Help")
        super.loadView()
        view.addSubviewFillingSafeArea(scrollView, insets: .zero)
        scrollView.backgroundColor = .systemBackground
        setupScrollView()
        loadScrollableSubviews()
    }
    
    func loadScrollableSubviews() {
        
        var text = HelpText(key: "helpImages")
        contentView.addSubviewBelow(text)
            .connectToBottom(of: contentView)
        
        let iconText = HelpText(icon: "photo", key: "imagesList")
        contentView.addSubviewBelow(iconText)
        text = HelpText(key: "helpImagesText")
        contentView.addSubviewBelow(text, upperView: iconText)
            .connectToBottom(of: contentView)
        
    }
    
}
