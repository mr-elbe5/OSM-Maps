/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers
import CoreLocation

class RouteViewController: ScrollViewController{
    
    var route: Route
    
    var nameEditField = UITextField()
    
    var timeLabel = UILabel(text: "")
    var distanceLabel = UILabel(text: "\("distance".localize()): 0 m")
    var upDistanceLabel = UILabel(text: "\("upDistance".localize()): 0 m")
    var downDistanceLabel = UILabel(text: "\("downDistance".localize()): 0 m")
    var durationLabel = UILabel(text: "\("duration".localize()): 00:00")
    var trackpointsLabel = UILabel(text: "\("trackpoints".localize()): 0")
    
    init(route: Route){
        self.route = route
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "track".localize()
        super.loadView()
        view.addSubviewFillingSafeArea(scrollView, insets: .zero)
        scrollView.backgroundColor = .systemBackground
        setupScrollView()
        loadScrollableSubviews()
        setupKeyboard()
    }
    
    func setupNavigationItems() {
        setNavigationBackButton()
        var groups = Array<UIBarButtonItemGroup>()
        var items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "export", image: UIImage(systemName: "square.and.arrow.up"), primaryAction: UIAction(){ action in
            self.exportRoute()
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(items: items))
        navigationItem.trailingItemGroups = groups
    }
    
    func loadScrollableSubviews() {
        contentView.removeAllSubviews()
            var header = UILabel(header: "startLocation".localize())
            contentView.addSubviewWithAnchors(header, top: contentView.topAnchor, leading: contentView.leadingAnchor)
            
            let coordinateLabel = UILabel(text: route.startCoordinate!.asString)
            contentView.addSubviewWithAnchors(coordinateLabel, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor,insets: OSInsets.flatInsets)
            
            contentView.addSubviewWithAnchors(timeLabel, top: coordinateLabel.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor,insets: OSInsets.flatInsets)
            
            header = UILabel(header: "distances".localize())
            contentView.addSubviewWithAnchors(header, top: nameEditField.bottomAnchor, leading: contentView.leadingAnchor)
            contentView.addSubviewWithAnchors(distanceLabel, top: header.bottomAnchor, leading: contentView.leadingAnchor,insets: OSInsets.flatInsets)
            contentView.addSubviewWithAnchors(upDistanceLabel, top: distanceLabel.bottomAnchor, leading: contentView.leadingAnchor,insets: OSInsets.flatInsets)
        contentView.addSubviewWithAnchors(downDistanceLabel, top: upDistanceLabel.bottomAnchor, leading: contentView.leadingAnchor,insets: OSInsets.flatInsets)
        contentView.addSubviewWithAnchors(durationLabel, top: downDistanceLabel.bottomAnchor, leading: contentView.leadingAnchor, insets: OSInsets.flatInsets)
        contentView.addSubviewWithAnchors(trackpointsLabel, top: durationLabel.bottomAnchor, leading: contentView.leadingAnchor, insets: OSInsets.flatInsets)
        
            .bottom(contentView.bottomAnchor)
        
    }
    
    func exportRoute() {
        
    }
    
}

