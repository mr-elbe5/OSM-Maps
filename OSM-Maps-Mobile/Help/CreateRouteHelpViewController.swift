/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers

class CreateRouteHelpViewController: ScrollViewController{
    
    
    override func loadView() {
        title = "helpCreateRoute".localize(table: "Help")
        super.loadView()
        view.addSubviewFillingSafeArea(scrollView, insets: .zero)
        scrollView.backgroundColor = .systemBackground
        setupScrollView()
        loadScrollableSubviews()
    }
    
    func loadScrollableSubviews() {
        
        let iconText = HelpText(icon: "point.topright.arrow.triangle.backward.to.point.bottomleft.scurvepath", key: "helpCreateRoute")
        contentView.addSubviewBelow(iconText)
        let text = HelpText(key: "helpCreateRouteText")
        contentView.addSubviewBelow(text, upperView: iconText)
            .connectToBottom(of: contentView)
        
    }
    
}
