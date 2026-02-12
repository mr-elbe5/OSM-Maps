/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers
import CoreLocation

class RouteViewController: ScrollViewController{
    
    var item: RouteItem
    
    var nameEditField = UITextField()
    
    init(route: RouteItem){
        self.item = route
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "route".localize()
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
        var lastView: UIView = header
        contentView.addSubviewBelow(header)
        var text = UILabel(text: item.address)
        contentView.addSubviewBelow(text, upperView: lastView,insets: .flatInsets)
        lastView = text
        header = UILabel(header: "endLocation".localize())
        contentView.addSubviewBelow(header, upperView: lastView)
        lastView=header
        text = UILabel(text: item.endLocation?.address ?? "")
        contentView.addSubviewBelow(text, upperView: lastView,insets: .flatInsets)
        lastView = text
        if let image = item.getPreview(){
            let imageView = UIImageView()
            imageView.withDefaults()
            imageView.setRoundedBorders()
            imageView.image = image
            imageView.setAspectRatioConstraint()
            imageView.contentMode = .scaleAspectFit
            contentView.addSubviewBelow(imageView, upperView: lastView)
            lastView = imageView
        }
        header = UILabel(header: "waypoints".localize())
        contentView.addSubviewBelow(header, upperView: lastView)
        lastView=header
        var lastDistance = 0
        for i in 0..<item.route.routepoints.count{
            let routepoint = item.route.routepoints[i]
            if i > 0 {
                text = UILabel(text: "\("after".localize()) \(lastDistance)m:")
                contentView.addSubviewBelow(text, upperView: lastView)
                lastView = text
            }
            lastDistance = routepoint.distance
            let iconName = routepoint.iconName
            var str = routepoint.directionString
            if !routepoint.name.isEmpty {
                str += "\("on".localize()) \(routepoint.name)"
            }
            if iconName.isEmpty {
                text = UILabel(text: str)
                contentView.addSubviewBelow(text, upperView: lastView)
                lastView = text
            }
            else{
                let line = IconText()
                line.setupView(icon: iconName, text: str)
                contentView.addSubviewBelow(line, upperView: lastView)
                lastView = line
            }
        }
        lastView.connectToBottom(of: contentView)
    }
    
    func exportRoute() {
        
    }
    
}

