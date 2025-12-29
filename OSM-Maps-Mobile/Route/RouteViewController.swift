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
        let startLabel = UILabel(text: item.address)
        contentView.addSubviewWithAnchors(startLabel, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor,insets: OSInsets.flatInsets)
        header = UILabel(header: "endLocation".localize())
        contentView.addSubviewWithAnchors(header, top: startLabel.bottomAnchor, leading: contentView.leadingAnchor)
            .bottom(contentView.bottomAnchor)
    }
    
    func exportRoute() {
        
    }
    
}

