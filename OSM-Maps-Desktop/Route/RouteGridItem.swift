/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import AppKit

protocol RouteGridItemDelegate{
    func exportRoute(_ route: RouteItem)
    func deleteRoute(_ route: RouteItem)
}

class RouteGridItem: NSCollectionViewItem, RouteGridItemViewDelegate{
    
    var route: RouteItem
    
    var delegate: RouteGridItemDelegate? = nil
    
    init(route: RouteItem) {
        self.route = route
        super.init(nibName: "", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let itemView = RouteGridItemView()
        itemView.delegate = self
        
        view = itemView
        view.wantsLayer = true
        view.setGrayRoundedBorders()
        
        let dateView = NSTextField(labelWithString: route.creationDate.dateTimeString())
        view.addSubviewWithAnchors(dateView, top: view.topAnchor, insets: OSInsets.smallInsets).centerX(view.centerXAnchor)
        
        let imgView = NSImageView(image: route.getPreview() ?? NSImage(named: "gear.grey")!)
        view.addSubviewFilling(imgView, insets: NSEdgeInsets(top: 25, left: 5, bottom: 25, right: 5))
        
        let iconView = NSView()
        view.addSubviewWithAnchors(iconView, bottom: view.bottomAnchor, insets: OSInsets.smallInsets).centerX(view.centerXAnchor)
        
        let showOnMapButton = NSButton(image: NSImage(systemSymbolName: "map", accessibilityDescription: nil)!, target: itemView, action: #selector(itemView.showRouteOnMap))
        showOnMapButton.bezelStyle = .smallSquare
        iconView.addSubviewWithAnchors(showOnMapButton, top: iconView.topAnchor, leading: iconView.leadingAnchor, bottom: iconView.bottomAnchor, insets: OSInsets.flatInsets)
        let exportButton = NSButton(image: NSImage(systemSymbolName: "square.and.arrow.up", accessibilityDescription: nil)!, target: itemView, action: #selector(itemView.exportRoute))
        exportButton.bezelStyle = .smallSquare
        iconView.addSubviewWithAnchors(exportButton, top: iconView.topAnchor, leading: showOnMapButton.trailingAnchor, bottom: iconView.bottomAnchor, insets: OSInsets.flatInsets)
        let deleteButton = NSButton(image: NSImage(systemSymbolName: "trash", accessibilityDescription: nil)!, target: itemView, action: #selector(itemView.deleteRoute))
        deleteButton.bezelStyle = .smallSquare
        iconView.addSubviewWithAnchors(deleteButton, top: iconView.topAnchor, leading: exportButton.trailingAnchor, trailing: iconView.trailingAnchor, bottom: iconView.bottomAnchor, insets: OSInsets.flatInsets)
    }
    
    func exportRoute() {
        delegate?.exportRoute(route)
    }
    
    func showRouteOnMap() {
        MainViewController.shared.showRouteOnMap(route)
    }
    
    func deleteRoute() {
        delegate?.deleteRoute(route)
    }

}

fileprivate protocol RouteGridItemViewDelegate{
    func showRouteOnMap()
    func exportRoute()
    func deleteRoute()
}

fileprivate class RouteGridItemView: NSView{
    
    var delegate: RouteGridItemViewDelegate? = nil
    
    @objc func showRouteOnMap(){
        delegate?.showRouteOnMap()
    }
    
    @objc func exportRoute(){
        delegate?.exportRoute()
    }
    
    @objc func deleteRoute(){
        delegate?.deleteRoute()
    }
    
}



