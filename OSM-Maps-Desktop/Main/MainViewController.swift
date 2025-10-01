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
    var videoGridView = VideoGridView()
    var trackGridView = TrackGridView()
    
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
        videoGridView.setupView()
        view.addSubviewBelow(videoGridView, upperView: mainMenu, insets: .zero)
            .connectToBottom(of: view, inset: .zero)
        videoGridView.isHidden = true
        trackGridView.setupView()
        view.addSubviewBelow(trackGridView, upperView: mainMenu, insets: .zero)
            .connectToBottom(of: view, inset: .zero)
        trackGridView.isHidden = true
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
            videoGridView.isHidden = true
            trackGridView.isHidden = true
        case .imageGrid:
            mapSplitView.isHidden = true
            imageGridView.isHidden = false
            videoGridView.isHidden = true
            trackGridView.isHidden = true
        case .avGrid:
            mapSplitView.isHidden = true
            imageGridView.isHidden = true
            videoGridView.isHidden = false
            trackGridView.isHidden = true
        case .trackGrid:
            mapSplitView.isHidden = true
            imageGridView.isHidden = true
            videoGridView.isHidden = true
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
    
    //videos
    
    func showVideo(_ video: VideoItem){
        videoPresenterView.setVideo(item: video)
        videoPresenterView.isHidden = false
    }
    
    func showVideos(_ videos: [VideoItem]){
        videoPresenterView.setVideos(videos)
        videoPresenterView.isHidden = false
    }
    
    // tracks
    
    func showTrackOnMap(_ item: TrackItem?){
        setView(.map)
        if let item = item{
            VisibleTrack.shared.setTrack(item.track)
            mapView.scrollView.showTrack(true)
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
            mapView.scrollView.showTrack(false)
        }
    }
    
    // presenter
    
    func closeImagePresenter(){
        imagePresenterView.isHidden = true
    }
    
    func closeVideoPresenter(){
        videoPresenterView.isHidden = true
    }
   
}





