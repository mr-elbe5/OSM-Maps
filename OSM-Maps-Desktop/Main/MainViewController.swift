/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import AVFoundation
import CoreLocation

class MainViewController: ViewController {
    
    static var shared: MainViewController{
        get{
            MainWindowController.instance.mainViewController
        }
    }
    
    let mainMenu = MainMenuView()
    let separator = NSView()
    var mapSplitView: SplitView!
    var mapView = MapView()
    var mapDetailView = MapDetailView()
    var gridView: GridView?
    
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
    
    var imageGridView: ImageGridView?{
        gridView as? ImageGridView
    }
    
    var videoGridView: VideoGridView?{
        gridView as? VideoGridView
    }
    
    var trackGridView: TrackGridView?{
        gridView as? TrackGridView
    }
    
    var routeGridView: RouteGridView?{
        gridView as? RouteGridView
    }
    
    override func loadView(){
        view = NSView()
        view.backgroundColor = .black
        mainMenu.setupView()
        view.addSubviewBelow(mainMenu, insets: .zero)
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
    
    func setGridView(_ gridView: GridView?){
        self.gridView?.removeFromSuperview()
        if gridView == nil {
            self.gridView = nil
        }
        else{
            self.gridView = gridView
            self.gridView!.setupView()
            view.addSubviewWithAnchors(self.gridView!, top: separator.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: view.bottomAnchor, insets: .zero)
        }
        mainMenu.centerMenu.selectedSegment = gridView?.idx ?? 0
    }
    
    func setViewer(_ viewer: PresenterView){
        viewer.setupView()
        view.addSubviewFilling(viewer, insets: .zero)
    }
    
    // map
    
    func refreshMap() {
        showTrackOnMap(nil)
        showRouteOnMap(nil)
        mapView.refreshMap()
    }
    
    func updateMapLayersScale(){
        mapScrollView.updateItemPositions()
        mapScrollView.updateTrackPosition()
        mapScrollView.updateRoutePosition()
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
    
    func toggleMapPins() {
        mapView.toggleMarkers()
    }
    
    func showItemOnMap(_ item: MapItem){
        setGridView(nil)
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
        let presenterView = ImagePresenterView()
        setViewer(presenterView)
        presenterView.setImage(item: image)
    }
    
    func showImages(_ images: [ImageItem]){
        let presenterView = ImagePresenterView()
        setViewer(presenterView)
        presenterView.setImages(images)
    }
    
    func showFilteredImageGrid(selectedImages: [ImageItem]){
        //AppData.shared.select
        
    }
    
    func updateImageGrid(){
        imageGridView?.updateData()
    }
    
    //videos
    
    func showVideo(_ video: VideoItem){
        let presenterView = VideoPresenterView()
        setViewer(presenterView)
        presenterView.setVideo(item: video)
    }
    
    func showVideos(_ videos: [VideoItem]){
        let presenterView = VideoPresenterView()
        setViewer(presenterView)
        presenterView.setVideos(videos)
    }
    
    func updateVideoGrid(){
        videoGridView?.updateData()
    }
    
    // tracks
    
    func showTrackOnMap(_ item: TrackItem?){
        setGridView(nil)
        if let item = item{
            VisibleTrack.shared.setTrack(item.track)
            mapScrollView.updateTrackLayerContent()
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
            mapScrollView.updateTrackLayerContent()
        }
    }
    
    func updateTrackGrid(){
        trackGridView?.updateData()
    }
    
    //route
    
    func createRoute(){
        VisibleRoute.shared.reset()
        VisibleRoute.shared.routeItem = RouteItem()
        mapScrollView.updateRouteLayerContent()
        routeControlView.update()
    }
    
    func updateRouteLayer(){
        mapScrollView.updateRouteLayerContent()
    }
    
    func showRouteOnMap(_ item: RouteItem?){
        setGridView(nil)
        if let item = item{
            VisibleRoute.shared.reset()
            VisibleRoute.shared.routeItem = item
            mapScrollView.updateRouteLayerContent()
            routeControlView.update()
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
            mapScrollView.updateRouteLayerContent()
        }
        routeControlView.updateStatusPanel()
    }
    
    func markerButtonPressed(_ idx: Int){
        Log.info("marker pressed \(idx)")
        VisibleRoute.shared.setIndex(idx)
        routeControlView.update()
    }
    
    func addRoutePoint(){
        if let route = VisibleRoute.shared.route, route.navigationPoints.count < VisibleRoute.MAX_NAVIGATION_POINTS{
            VisibleRoute.shared.addRoutePoint()
            updateRouteViews()
        }
    }
    
    func removeRoutePoint(){
        VisibleRoute.shared.removeRoutePoint(){
            DispatchQueue.main.async {
                self.routeChanged()
            }
        }
        updateRouteLayer()
        routeControlView.update()
    }
    
    private func updateRouteViews(){
        mapScrollView.updateRouteLayerContent()
        routeControlView.update()
    }
    
    func setRouteCoordinate(idx: Int, coordinate: CLLocationCoordinate2D){
        //Log.info("coordinate for \(idx) is \(coordinate)")
        if let route = VisibleRoute.shared.route{
            route.navigationPoints[idx] = Mappoint(coordinate: coordinate)
            mapScrollView.updateRouteLayerContent()
            VisibleRoute.shared.selectedIndex = -1
            VisibleRoute.shared.requestRoute{
                DispatchQueue.main.async {
                    self.routeChanged()
                }
            }
        }
    }
    
    func setRouteType(_ routeType: RouteType){
        if let route = VisibleRoute.shared.route{
            route.type = routeType
            if route.canBeRequested{
                VisibleRoute.shared.requestRoute {
                    DispatchQueue.main.async {
                        self.routeChanged()
                    }
                }
            }
            else{
                mapScrollView.updateRouteLayerContent()
            }
        }
    }
    
    private func routeChanged(){
        mapScrollView.updateRouteLayerContent()
        routeControlView.update()
    }
    
    func saveRoute(){
        if let route = VisibleRoute.shared.route, route.isComplete{
            VisibleRoute.shared.saveRoute(){
                DispatchQueue.main.async {
                    self.routeControlView.update()
                    NSAlert.showMessage(message: "routeSaved".localize())
                }
            }
        }
    }
    
    func cancelRoute(){
        VisibleRoute.shared.reset()
        mapScrollView.routeLayerView.reset()
        routeControlView.updateStatusPanel()
        routeControlView.isHidden = true
    }
   
}
