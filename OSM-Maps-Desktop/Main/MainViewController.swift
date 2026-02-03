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
    case routeGrid
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
    var mapDetailView = MapDetailView()
    var imageGridView = ImageGridView()
    var videoGridView = VideoGridView()
    var trackGridView = TrackGridView()
    var routeGridView = RouteGridView()
    
    var imagePresenterView = ImagePresenterView()
    var videoPresenterView = VideoPresenterView()
    
    var viewType: MainViewType = .map
    
    var currentView: NSView{
        switch viewType{
        case .map:
            return mapSplitView
        case .imageGrid:
            return imageGridView
        case .avGrid:
            return videoGridView
        case.trackGrid:
            return trackGridView
        case.routeGrid:
            return routeGridView
        }
    }
    
    var mapScrollView: MapScrollView{
        mapView.scrollView
    }
    
    var mapMenuView: MapMenuView{
        mapView.menuView
    }
    
    var itemListView: ItemListView{
        mapDetailView.itemListView
    }
    
    var routeControlView: RouteControlView{
        mapDetailView.routeControlView
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
        routeControlView.setup()
        imageGridView.setupView()
        view.addSubviewBelow(imageGridView, upperView: mainMenu, insets: .zero)
            .connectToBottom(of: view, inset: .zero)
        imageGridView.isHidden = true
        videoGridView.setupView()
        view.addSubviewBelow(videoGridView, upperView: mainMenu, insets: .zero)
            .connectToBottom(of: view, inset: .zero)
        videoGridView.isHidden = true
        trackGridView.setupView()
        view.addSubviewBelow(trackGridView, upperView: mainMenu, insets: .zero)
            .connectToBottom(of: view, inset: .zero)
        trackGridView.isHidden = true
        routeGridView.setupView()
        view.addSubviewBelow(routeGridView, upperView: mainMenu, insets: .zero)
            .connectToBottom(of: view, inset: .zero)
        routeGridView.isHidden = true
        view.addSubviewFilling(imagePresenterView, insets: .zero)
        view.addSubviewFilling(videoPresenterView, insets: .zero)
        imagePresenterView.setupView()
        imagePresenterView.isHidden = true
        videoPresenterView.setupView()
        videoPresenterView.isHidden = true
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        mapView.setDefaultLocation()
        mapScrollView.updateItemLayerContent()
    }
    
    func showItemDetails(item: MapItem){
        itemListView.setItems([item])
    }
    
    func showGroupDetails(group: MapItemGroup){
        itemListView.setItems(group.items)
    }
    
    func setView(_ type: MainViewType){
        switch type{
        case .map:
            mapSplitView.isHidden = false
            imageGridView.isHidden = true
            videoGridView.isHidden = true
            trackGridView.isHidden = true
            routeGridView.isHidden = true
        case .imageGrid:
            mapSplitView.isHidden = true
            imageGridView.isHidden = false
            videoGridView.isHidden = true
            trackGridView.isHidden = true
            routeGridView.isHidden = true
        case .avGrid:
            mapSplitView.isHidden = true
            imageGridView.isHidden = true
            videoGridView.isHidden = false
            trackGridView.isHidden = true
            routeGridView.isHidden = true
        case .trackGrid:
            mapSplitView.isHidden = true
            imageGridView.isHidden = true
            videoGridView.isHidden = true
            trackGridView.isHidden = false
            routeGridView.isHidden = true
        case .routeGrid:
            mapSplitView.isHidden = true
            imageGridView.isHidden = true
            videoGridView.isHidden = true
            trackGridView.isHidden = true
            routeGridView.isHidden = false
        }
        viewType = type
        mainMenu.centerMenu.selectedSegment = type.rawValue
    }
    
    // map
    
    func refreshMap() {
        showTrackOnMap(nil)
        showRouteOnMap(nil)
        mapView.refreshMap()
    }
    
    func updateMapLayersScale(){
        mapScrollView.updateItemLayerScale()
        mapScrollView.updateTrackLayerScale()
        mapScrollView.updateRouteLayerScale()
    }
    
    func zoomIn(){
        mapView.zoomIn()
        updateMapLayersScale()
    }
    
    func zoomOut(){
        mapView.zoomOut()
        updateMapLayersScale()
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
            mapScrollView.zoomAndScrollTo(zoom, coordinate)
        }
        else{
            mapScrollView.scrollToScreenCenter(coordinate: coordinate)
        }
        updateMapLayersScale()
    }
    
    func itemsChanged(){
        mapScrollView.updateItemLayerContent()
        mapScrollView.updateTrackLayerContent()
        mapScrollView.updateRouteLayerContent()
        updateImageGrid()
        updateVideoGrid()
        updateTrackGrid()
    }
    
    // images
    
    func showImage(_ image: ImageItem){
        imagePresenterView.setImage(item: image)
        imagePresenterView.isHidden = false
    }
    
    func showImages(_ images: [ImageItem]){
        imagePresenterView.setImages(images)
        imagePresenterView.isHidden = false
    }
    
    func showFilteredImageGrid(selectedImages: [ImageItem]){
        //AppData.shared.select
        
    }
    
    func updateImageGrid(){
        imageGridView.updateData()
    }
    
    //videos
    
    func showVideo(_ video: VideoItem){
        videoPresenterView.setVideo(item: video)
        videoPresenterView.isHidden = false
    }
    
    func showVideos(_ videos: [VideoItem]){
        videoPresenterView.setVideos(videos)
        videoPresenterView.isHidden = false
    }
    
    func updateVideoGrid(){
        videoGridView.updateData()
    }
    
    // tracks
    
    func showTrackOnMap(_ item: TrackItem?){
        setView(.map)
        if let item = item{
            VisibleTrack.shared.setTrack(item.track)
            mapScrollView.showTrackLayer(true)
            if item.track.coordinateRegion == nil{
                item.track.updateCoordinateRegion()
            }
            if let coordinateRegion = item.coordinateRegion{
                mapView.showMapRectOnMap(worldRect: coordinateRegion.worldRect)
            }
            else{
                mapView.showLocationOnMap(coordinate: item.coordinate)
            }
        }
        else{
            VisibleTrack.shared.reset()
            mapScrollView.showTrackLayer(false)
        }
    }
    
    func updateTrackGrid(){
        trackGridView.updateData()
    }
    
    //route
    
    func showRouteOnMap(_ item: RouteItem?){
        setView(.map)
        if let item = item{
            VisibleRoute.shared.setRoute(item.route)
            mapMenuView.updateButtons()
            mapScrollView.routeLayerView.setRoute(route: item.route)
            mapScrollView.showRouteLayer(true)
            routeControlView.isHidden = false
            if item.route.coordinateRegion == nil{
                item.route.updateCoordinateRegion()
            }
            if let coordinateRegion = item.coordinateRegion{
                mapView.showMapRectOnMap(worldRect: coordinateRegion.worldRect)
            }
            else{
                mapView.showLocationOnMap(coordinate: item.coordinate)
            }
        }
        else{
            VisibleRoute.shared.reset()
            routeControlView.isHidden = true
            mapScrollView.showRouteLayer(false)
        }
        mapMenuView.updateState()
        routeControlView.setupStatusPanel()
    }
    
    func markerButtonPressed(_ idx: Int){
        Log.info("marker pressed \(idx)")
        VisibleRoute.shared.setIndex(idx)
        mapMenuView.updateState()
    }
    
    func addRoutePoint(){
        if VisibleRoute.shared.navigationPoints.count < VisibleRoute.MAX_NAVIGATION_POINTS{
            VisibleRoute.shared.addRoutePoint()
            routePointsChanged()
        }
    }
    
    func removeRoutePoint(){
        if VisibleRoute.shared.navigationPoints.count > 2{
            VisibleRoute.shared.removeRoutePoint(){ isComplete in
                DispatchQueue.main.async {
                    self.routeChanged()
                }
            }
            routePointsChanged()
        }
    }
    
    private func routePointsChanged(){
        mapMenuView.updateButtons()
        mapScrollView.routeLayerView.setupNavigationMarkers()
        mapScrollView.updateRouteLayerContent()
        routeControlView.setupStatusPanel()
    }
    
    func setRouteCoordinate(idx: Int, coordinate: CLLocationCoordinate2D){
        Log.info("coordinate for \(idx) is \(coordinate)")
        mapScrollView.routeLayerView.setMarkerCoordinate(idx: idx, coordinate: coordinate)
        VisibleRoute.shared.selectedIndex = -1
        mapMenuView.updateState()
        VisibleRoute.shared.setCoordinateForRoutePoint(idx, coordinate){ isComplete in
            DispatchQueue.main.async {
                self.routeChanged()
            }
        }
    }
    
    func setRouteType(_ routeType: RouteType){
        Preferences.shared.routeType = routeType
        Preferences.shared.save()
        VisibleRoute.shared.setRouteType(routeType){ isComplete in
            DispatchQueue.main.async {
                self.routeChanged()
            }
        }
    }
    
    private func routeChanged(){
        mapScrollView.routeLayerView.setRoute(route: VisibleRoute.shared.route)
        mapScrollView.updateRouteLayerContent()
        routeControlView.isHidden = false
        routeControlView.setupStatusPanel()
    }
    
    func saveRoute(){
        if VisibleRoute.shared.isComplete{
            VisibleRoute.shared.saveRoute(){ success in
                if success{
                    DispatchQueue.main.async {
                        NSAlert.showMessage(message: "routeSaved".localize())
                    }
                }
            }
        }
    }
    
    func cancelRoute(){
        VisibleRoute.shared.reset()
        mapScrollView.routeLayerView.reset()
        routeControlView.setupStatusPanel()
        routeControlView.isHidden = true
        mapView.menuView.updateState()
    }
    
    // presenter
    
    func closeImagePresenter(){
        imagePresenterView.isHidden = true
    }
    
    func closeVideoPresenter(){
        videoPresenterView.isHidden = true
    }
   
}





