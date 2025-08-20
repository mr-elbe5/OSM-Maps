/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation

class SearchViewController: ModalViewController, SearchResultCellDelegate {
    
    var contentView = SearchView()
    
    override func loadView() {
        super.loadView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: 350, height: 0))
        view.addSubviewFilling(contentView)
        contentView.setupView()
        contentView.delegate = self
    }
    
    func showLocation(location: NominatimLocation){
        MainViewController.shared.showSearchResult(coordinate: location.coordidate, worldRect: location.mapRect)
        view.window?.close()
    }
    
}

class SearchView: NSView{
    
    var searchField = NSTextField()
    var targetControl: NSSegmentedControl!
    var regionControl: NSSegmentedControl!
    var radiusSlider = RadiusSlider()
    var searchButton: NSButton!
    var scrollView: NSScrollView!
    var contentView = NSView()
    
    var delegate: SearchResultCellDelegate? = nil
    
    init() {
        super.init(frame: .zero)
        searchField = NSTextField()
        searchField.placeholderString = "searchPlaceholder".localize()
        targetControl = NSSegmentedControl(labels: SearchQuery.SearchTarget.names, trackingMode: .selectOne, target: self, action: #selector(targetChanged))
        regionControl = NSSegmentedControl(labels: SearchQuery.SearchRegion.names, trackingMode: .selectOne, target: self, action: #selector(regionChanged))
        searchButton = NSButton(title: "search".localize(), target: self, action: #selector(search))
        scrollView = NSScrollView()
        scrollView.asVerticalScrollView(contentView: contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView() {
        
        let header = NSTextField(labelWithString: "search".localize())
        addSubviewCenteredBelow(header)
        addSubviewBelow(searchField, upperView: header)
        targetControl.selectedSegment = 0
        addSubviewBelow(targetControl, upperView: searchField)
        regionControl.selectedSegment = 0
        addSubviewBelow(regionControl, upperView: targetControl)
        radiusSlider.setup()
        addSubviewBelow(radiusSlider, upperView: regionControl)
        addSubviewBelow(searchButton, upperView: radiusSlider)
        addSubviewBelow(scrollView, upperView: searchButton)
            .height(200)
            .connectToBottom(of: self)
    }
    
    @objc func targetChanged(){
        SearchStatus.shared.searchTarget = SearchQuery.SearchTarget(rawValue: targetControl.selectedSegment)!
        SearchStatus.shared.save()
    }
    
    @objc func regionChanged(){
        SearchStatus.shared.searchRegion = SearchQuery.SearchRegion(rawValue: regionControl.selectedSegment)!
        SearchStatus.shared.save()
    }
    
    @objc func search(){
        let text = searchField.stringValue
        if !text.isEmpty{
            SearchStatus.shared.searchString = text
            SearchStatus.shared.searchTarget = SearchQuery.SearchTarget(rawValue: targetControl.selectedSegment)!
            SearchStatus.shared.searchRegion = SearchQuery.SearchRegion(rawValue: regionControl.selectedSegment)!
            SearchStatus.shared.searchRadius = radiusSlider.slider.doubleValue
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
                DispatchQueue.main.async{
                    self.contentView.removeAllSubviews()
                    if let locations = locations{
                        var lastView: NSView? = nil
                        for location in locations{
                            let cell = SearchResultCell()
                            cell.location = location
                            cell.setup()
                            cell.delegate = self.delegate
                            self.contentView.addSubviewBelow(cell, upperView: lastView)
                            lastView = cell
                        }
                        lastView?.connectToBottom(of: self.contentView)
                    }
                }
            }
        }
    }
    
}

protocol SearchResultCellDelegate{
    func showLocation(location: NominatimLocation)
}

class SearchResultCell: NSControl {
    
    var location : NominatimLocation? = nil
    
    var delegate: SearchResultCellDelegate? = nil
    
    func setup(){
        if let location = location{
            let locationLabel = NSTextField(labelWithString: location.name)
            addSubviewFilling(locationLabel)
        }
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        delegate?.showLocation(location: location!)
    }
    
}

class RadiusSlider : NSView{
    
    var slider = NSSlider()
    
    func setup(){
        slider.minValue = 1.0
        slider.maxValue = 100.0
        addSubviewWithAnchors(slider, top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor)
        let leftLabel = NSTextField(labelWithString: "0km")
        addSubviewWithAnchors(leftLabel, top: slider.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor)
        let rightLabel = NSTextField(labelWithString: "100km")
        addSubviewWithAnchors(rightLabel, top: slider.bottomAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
    }
    
}

