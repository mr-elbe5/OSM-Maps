/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation


class MapDetailView: NSView{
    
    var itemListView = ItemListView()
    var routeControlView = RouteControlView()
    
    override func setupView(){
        itemListView.setupView()
        addSubviewFilling(itemListView, insets: .zero)
        routeControlView.setupView()
        addSubviewFilling(routeControlView, insets: .zero)
        //routeControlView.isHidden = true
    }
    
    
    
}



