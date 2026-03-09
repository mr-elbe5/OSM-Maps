/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers

class SettingsHelpViewController: ScrollViewController{
    
    
    override func loadView() {
        title = "helpSettings".localize(table: "Help")
        super.loadView()
        view.addSubviewFillingSafeArea(scrollView, insets: .zero)
        scrollView.backgroundColor = .systemBackground
        setupScrollView()
        loadScrollableSubviews()
    }
    
    func loadScrollableSubviews() {
        
        var header = HelpText(icon: "calendar", headerKey: "helpViewFilter")
        contentView.addSubviewBelow(header)
        var text = HelpText(key: "helpViewFilterText")
        contentView.addSubviewBelow(text, upperView: header)
        
        header = HelpText(icon: "gearshape", headerKey: "helpSettings")
        contentView.addSubviewBelow(header, upperView: text)
        text = HelpText(key: "helpSettingsText")
        contentView.addSubviewBelow(text, upperView: header)
            .connectToBottom(of: contentView)
        
    }
    
}
