/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import AVFoundation
import CoreLocation

enum MainViewType: Int{
    case map
    case imageGrid
    case avGrid
    case trackGrid
}

class MainViewController: ViewController {
    
    static var shared: MainViewController{
        get{
            MainWindowController.instance.mainViewController
        }
    }
    
    var mainMenu = MainMenuView()
    var mapSplitView: SplitView!
    var mapView = MapView()
    var mapDetailView = ItemListView()
    var imageGridView = ImageGridView()
    var avGridView = VideoGridView()
    var trackGridView = TrackGridView()
    
    var presenterView = ImagePresenterView()
    
    var viewType: MainViewType = .map
    
    var currentView: NSView{
        switch viewType{
        case .map:
            return mapSplitView
        case .imageGrid:
            return imageGridView
        case .avGrid:
            return avGridView
        case.trackGrid:
            return trackGridView
        }
    }
    
    override func loadView(){
        view = NSView()
        view.backgroundColor = .black
        mainMenu.setupView()
        view.addSubviewBelow(mainMenu, insets: .zero)
        let separator = NSView()
        separator.backgroundColor = .darkGray
        view.addSubviewBelow(separator, upperView: mainMenu, insets: .zero)
            .height(3)
        mapView.setupView()
        mapDetailView.setupView()
        mapSplitView = SplitView(mainView: mapView, sideView: mapDetailView)
        mapSplitView.setupView()
        view.addSubviewBelow(mapSplitView, upperView: separator, insets: .zero)
            .connectToBottom(of: view, inset: .zero)
        imageGridView.setupView()
        view.addSubviewBelow(imageGridView, upperView: mainMenu, insets: .zero)
            .connectToBottom(of: view, inset: .zero)
        imageGridView.isHidden = true
        avGridView.setupView()
        view.addSubviewBelow(avGridView, upperView: mainMenu, insets: .zero)
            .connectToBottom(of: view, inset: .zero)
        avGridView.isHidden = true
        trackGridView.setupView()
        view.addSubviewBelow(trackGridView, upperView: mainMenu, insets: .zero)
            .connectToBottom(of: view, inset: .zero)
        trackGridView.isHidden = true
        view.addSubviewFilling(presenterView, insets: .zero)
        presenterView.setupView()
        presenterView.isHidden = true
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        mapView.setDefaultLocation()
        mapView.updateItemLayer()
    }
    
    func showItemDetails(item: MapItem){
        mapDetailView.setItems([item])
    }
    
    func showGroupDetails(group: MapItemGroup){
        mapDetailView.setItems(group.items)
    }
    
    func setView(_ type: MainViewType){
        switch type{
        case .map:
            mapSplitView.isHidden = false
            imageGridView.isHidden = true
            avGridView.isHidden = true
            trackGridView.isHidden = true
        case .imageGrid:
            mapSplitView.isHidden = true
            imageGridView.isHidden = false
            avGridView.isHidden = true
            trackGridView.isHidden = true
        case .avGrid:
            mapSplitView.isHidden = true
            imageGridView.isHidden = true
            avGridView.isHidden = false
            trackGridView.isHidden = true
        case .trackGrid:
            mapSplitView.isHidden = true
            imageGridView.isHidden = true
            avGridView.isHidden = true
            trackGridView.isHidden = false
        }
        viewType = type
        mainMenu.centerMenu.selectedSegment = type.rawValue
    }
    
    // map
    
    func refreshMap() {
        showTrackOnMap(nil)
        mapView.refreshMap()
    }
    
    func updateItemLayer(){
        mapView.updateItemLayer()
    }
    
    func updateTrackLayer(){
        mapView.updateTrackLayer()
    }
    
    func zoomIn(){
        mapView.zoomIn()
        updateItemLayer()
        updateTrackLayer()
    }
    
    func zoomOut(){
        mapView.zoomOut()
        updateItemLayer()
        updateTrackLayer()
    }
    
    func toggleCross() {
        mapView.toggleCross()
    }
    
    func showItemOnMap(_ item: MapItem){
        setView(.map)
        mapView.showLocationOnMap(coordinate: item.coordinate)
    }
    
    func showSearchResult(coordinate: CLLocationCoordinate2D, worldRect: CGRect?){
        if let worldRect = worldRect{
            let zoom = World.getZoomToFit(worldRect: worldRect, scaledSize: mapView.bounds.size)
            mapView.scrollView.zoomAndScrollTo(zoom, coordinate)
        }
        else{
            mapView.scrollView.scrollToScreenCenter(coordinate: coordinate)
        }
        mapView.updateItemLayer()
        mapView.updateTrackLayer()
    }
    
    // images
    
    func showImage(_ image: ImageItem){
        presenterView.setImage(item: image)
        presenterView.isHidden = false
    }
    
    func showImages(_ images: [ImageItem]){
        presenterView.setImages(images)
        presenterView.isHidden = false
    }
    
    //videos
    
    func showVideo(_ video: VideoItem){
        
    }
    
    // tracks
    
    func showTrackOnMap(_ item: TrackItem?){
        setView(.map)
        if let item = item{
            VisibleTrack.shared.setTrack(item.track)
            mapView.scrollView.showTrack(true)
            if let coordinateRegion = item.coordinateRegion{
                mapView.showMapRectOnMap(worldRect: coordinateRegion.worldRect)
            }
            else{
                mapView.showLocationOnMap(coordinate: item.coordinate)
            }
        }
        else{
            VisibleTrack.shared.reset()
            mapView.scrollView.showTrack(false)
        }
    }
    
    // presenter
    
    func closePresenter(){
        presenterView.isHidden = true
    }
   
}





