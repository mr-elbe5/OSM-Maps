/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

class SearchViewController: UIViewController{
    
    var topView = UIView()
    var searchField = UITextField()
    var targetControl = UISegmentedControl()
    var regionControl = UISegmentedControl()
    var radiusSlider = RadiusSlider()
    let searchButton = UIButton()
    let clearButton = IconButton(icon: "x.circle", tintColor: .gray)
    
    var target: SearchQuery.SearchTarget = SearchStatus.shared.searchTarget
    var region: SearchQuery.SearchRegion = SearchStatus.shared.searchRegion
    
    var locations = Array<NominatimLocation>()
    
    var tableView = UITableView().withLayout(backgroundColor: .black)
    
    override func loadView() {
        title = "searchLocation".localize()
        super.loadView()
        view.backgroundColor = .systemBackground
        tableView.backgroundColor = .systemBackground
        let guide = view.safeAreaLayoutGuide
        view.addSubviewWithAnchors(topView, top: guide.topAnchor, leading: guide.leadingAnchor, trailing: guide.trailingAnchor)
        topView.setRoundedBorders()
        setupTopView()
        updateTopView()
        view.addSubviewWithAnchors(tableView, top: topView.bottomAnchor, leading: guide.leadingAnchor, trailing: guide.trailingAnchor, bottom: guide.bottomAnchor)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.CELL_IDENT)
    }
    
    func setupTopView(){
        searchField.placeholder = "searchPlaceholder".localize()
        searchField.borderStyle = .roundedRect
        searchField.text = SearchStatus.shared.searchString
        searchField.autocorrectionType = .no
        searchField.autocapitalizationType = .none
        searchField.addTarget(self, action: #selector(search), for: .editingDidEndOnExit)
        clearButton.addAction(UIAction(){ _ in
            self.searchField.text = ""
            SearchStatus.shared.searchString = ""
            SearchStatus.shared.save()
        }, for: .touchDown)
        targetControl.insertSegment(action: UIAction(){_ in
            self.target = .any
        }, at: 0, animated: false)
        targetControl.setTitle("anyTarget".localize(), forSegmentAt: 0)
        targetControl.insertSegment(action: UIAction(){_ in
            self.target = .city
        }, at: 1, animated: false)
        targetControl.setTitle("cityTarget".localize(), forSegmentAt: 1)
        targetControl.insertSegment(action: UIAction(){_ in
            self.target = .street
        }, at: 2, animated: false)
        targetControl.setTitle("streetTarget".localize(), forSegmentAt: 2)
        targetControl.insertSegment(action: UIAction(){_ in
            self.target = .poi
        }, at: 3, animated: false)
        targetControl.setTitle("poiTarget".localize(), forSegmentAt: 3)
        targetControl.selectedSegmentIndex = SearchStatus.shared.searchTarget.rawValue
        
        regionControl.insertSegment(action: UIAction(){_ in
            self.region = .unlimited
        }, at: 0, animated: false)
        regionControl.setTitle("unlimitedRegion".localize(), forSegmentAt: 0)
        regionControl.insertSegment(action: UIAction(){_ in
            self.region = .current
        }, at: 1, animated: false)
        regionControl.setTitle("currentRegion".localize(), forSegmentAt: 1)
        regionControl.insertSegment(action: UIAction(){_ in
            self.region = .radius
        }, at: 2, animated: false)
        regionControl.setTitle("radiusRegion".localize(), forSegmentAt: 2)
        regionControl.selectedSegmentIndex = SearchStatus.shared.searchRegion.rawValue
        regionControl.addAction(UIAction(){ action in
            self.updateTopView()
        }, for: .valueChanged)
        radiusSlider.setup()
        radiusSlider.slider.value = Float(SearchStatus.shared.searchRadius)
        searchButton.setTitle("search".localize(), for: .normal)
        searchButton.setTitleColor(.systemBlue, for: .normal)
        searchButton.addAction(UIAction(){ action in
            self.search()
        }, for: .touchDown)
    }
    
    func updateTopView(){
        topView.removeAllSubviews()
        topView.addSubviewWithAnchors(searchField, top: topView.topAnchor, leading: topView.leadingAnchor)
        topView.addSubviewWithAnchors(clearButton, leading: searchField.trailingAnchor, trailing: topView.trailingAnchor)
            .centerY(searchField.centerYAnchor)
        topView.addSubviewBelow(targetControl, upperView: searchField)
        topView.addSubviewBelow(regionControl, upperView: targetControl)
        var lastView: UIView = regionControl
        if self.region == .radius {
            topView.addSubviewBelow(radiusSlider, upperView: regionControl, insets: OSInsets.flatInsets)
            lastView = radiusSlider
        }
        topView.addSubviewCenteredBelow(searchButton, upperView: lastView)
            .connectToBottom(of: topView)
    }
    
    @objc func search(){
        if let text = searchField.text, !text.isEmpty{
            SearchStatus.shared.searchString = text
            SearchStatus.shared.searchTarget = SearchQuery.SearchTarget(rawValue: targetControl.selectedSegmentIndex)!
            SearchStatus.shared.searchRegion = SearchQuery.SearchRegion(rawValue: regionControl.selectedSegmentIndex)!
            SearchStatus.shared.searchRadius = Double(radiusSlider.slider.value)
            SearchStatus.shared.save()
            let searchQuery = SearchQuery()
            switch SearchStatus.shared.searchRegion{
            case .current:
                let currentRegion = MapStatus.shared.getCoordinateRegion()
                Log.debug("searching in current region \(currentRegion)")
                searchQuery.coordinateRegion = currentRegion
            case .radius:
                let currentCenter = MapStatus.shared.getCenterCoordinate()
                let coordinateRegion = currentCenter.coordinateRegion(radiusMeters: SearchStatus.shared.searchRadius*1000)
                Log.debug("searching in radius region \(coordinateRegion)")
                searchQuery.coordinateRegion = coordinateRegion
            default:
                break
            }
            searchQuery.search(){ (locations: Array<NominatimLocation>?) in
                if let locations = locations{
                    self.locations = locations
                    DispatchQueue.main.async{
                        self.tableView.reloadData()
                    }
                }
                else{
                    DispatchQueue.main.async{
                        self.showError("noValidSearch".localize())
                    }
                }
            }
        }
    }
    
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let location = locations[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell.CELL_IDENT, for: indexPath) as? SearchResultCell{
            cell.location = location
            cell.delegate = self
            cell.updateCell(isEditing: false)
            return cell
        }
        else{
            Log.error("no valid item/cell for serach result")
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}

extension SearchViewController: SearchResultCellDelegate{
    
    func showResult(location: NominatimLocation){
        self.close()
        MainViewController.shared.showSearchResult(coordinate: location.coordidate, worldRect: location.mapRect)
    }
    
}

class RadiusSlider : UIView{
    
    var slider = UISlider()
    
    func setup(){
        slider.minimumValue = 1.0
        slider.maximumValue = 100.0
        addSubviewWithAnchors(slider, top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor)
        let leftLabel = UILabel(text: "0km")
        addSubviewWithAnchors(leftLabel, top: slider.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor)
        let rightLabel = UILabel(text: "100km")
        addSubviewWithAnchors(rightLabel, top: slider.bottomAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
    }
    
}

