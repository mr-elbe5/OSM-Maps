/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers

class RouteHelpViewController: ScrollViewController{
    
    
    override func loadView() {
        title = "helpRoutes".localize(table: "Help")
        super.loadView()
        view.addSubviewFillingSafeArea(scrollView, insets: .zero)
        scrollView.backgroundColor = .systemBackground
        setupScrollView()
        loadScrollableSubviews()
    }
    
    func loadScrollableSubviews() {
        
        let iconText = HelpText(icon: "point.topright.arrow.triangle.backward.to.point.bottomleft.scurvepath", key: "routesList")
        contentView.addSubviewBelow(iconText)
        let text = HelpText(key: "helpRoutesText")
        contentView.addSubviewBelow(text, upperView: iconText)
            .connectToBottom(of: contentView)
        
    }
    
}
