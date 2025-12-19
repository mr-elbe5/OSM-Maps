/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import AVKit

class MainViewController: UIViewController {
    
    static var shared: MainViewController = MainViewController()
    
    var mapView = MapView()
    var gpsStatusView = GPSStatusView()
    var topMenuView = TopMenuView()
    var trackMenuView = TrackMenuView()
    var mapMenuView = MapMenuView()
    var trackStatusView = TrackStatusView()
    var statusView = LocationStatusView()
    var licenseView = UIView()
    
    var cancelAlert: UIAlertController? = nil
    
    var startCoordinate: CLLocationCoordinate2D? = nil
    
    var visibleTileRegion: TileRegion{
        mapView.scrollView.tileRegion
    }
    
    override func loadView() {
        super.loadView()
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.backgroundColor = .black
        navigationController?.navigationBar.tintColor = .white
        setupNavigationItems()
        view.setBackground(.black)
        let guide = view.safeAreaLayoutGuide
        setupMapView(guide: guide)
        setupGpsStatusView(guide: guide)
        setupTopMenuView(guide: guide)
        setupTrackMenuView(guide: guide)
        setupMapMenuView(guide: guide)
        setupLicenseView(guide: guide)
        setupStatusView(guide: guide)
        setupTrackStatusView(guide: guide)
        TrackRecorder.shared.delegate = self
    }
    
    func setupNavigationItems() {
        view.backgroundColor = .black
        // left
        var groups = Array<UIBarButtonItemGroup>()
        var items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "notes".localize(), image: UIImage(systemName: "note.text"), primaryAction: UIAction(){ action in
            let controller = NoteListViewController()
            controller.loadItems()
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        items.append(UIBarButtonItem(title: "images".localize(), image: UIImage(systemName: "photo"), primaryAction: UIAction(){ action in
            let controller = ImageListViewController()
            controller.loadItems()
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        items.append(UIBarButtonItem(title: "avMedia".localize(), image: UIImage(systemName: "video.badge.waveform"), primaryAction: UIAction(){ action in
            let controller = AVMediaListViewController()
            controller.loadItems()
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        items.append(UIBarButtonItem(title: "tracks".localize(), image: UIImage(systemName: "figure.walk"), primaryAction: UIAction(){ action in
            let controller = TrackListViewController()
            controller.loadItems()
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        items.append(UIBarButtonItem(title: "route".localize(), image: UIImage(systemName: "point.topright.arrow.triangle.backward.to.point.bottomleft.scurvepath"), primaryAction: UIAction(){ action in
            if VisibleRoute.shared.route == nil { return }
            let controller = RouteViewController(route: VisibleRoute.shared.route!)
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(items: items))
        navigationItem.leadingItemGroups = groups
        
        //right
        groups = Array<UIBarButtonItemGroup>()
        items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "settings".localize(), image: UIImage(systemName: "gearshape"), primaryAction: UIAction(){ action in
            let controller = SettingsViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        items.append(UIBarButtonItem(title: "help".localize(), image: UIImage(systemName: "questionmark.circle"), primaryAction: UIAction(){ action in
            let controller = HelpViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(items: items))
        navigationItem.trailingItemGroups = groups
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startCoordinate = MapStatus.shared.centerCoordinate
        LocationService.shared.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let coord = startCoordinate{
            MapStatus.shared.centerCoordinate = coord
            mapView.setStartLocation()
            startCoordinate = nil
        }
        if TrackRecorder.shared.interrupted{
            showDecide(title: "interruptedTrackFound".localize(), text: "shouldResumeInterruptedTrack".localize(), onYes: {
                TrackRecorder.shared.resumeRecording()
                TrackRecorder.shared.interrupted = false
            }, onNo:{
                TrackRecorder.shared.cancelTracking()
                TrackRecorder.shared.interrupted = false
            })
        }
    }
    
    func setupMapView(guide: UILayoutGuide){
        view.addSubviewWithAnchors(mapView, top: guide.topAnchor, leading: guide.leadingAnchor, trailing: guide.trailingAnchor, bottom: guide.bottomAnchor, insets: .zero)
        mapView.setup()
    }
    
    func setupGpsStatusView(guide: UILayoutGuide){
        view.addSubviewWithAnchors(gpsStatusView, top: guide.topAnchor, leading: guide.leadingAnchor, insets: UIEdgeInsets(top: 10, left: 5, bottom: 0, right: 0))
        gpsStatusView.setup()
    }
    
    func setupTopMenuView(guide: UILayoutGuide){
        view.addSubviewWithAnchors(topMenuView, top: guide.topAnchor)
            .centerX(guide.centerXAnchor)
        topMenuView.setup()
    }
    
    func setupTrackMenuView(guide: UILayoutGuide){
        view.addSubviewWithAnchors(trackMenuView, top: guide.topAnchor, leading: guide.leadingAnchor, insets: UIEdgeInsets(top: 40, left: 10, bottom: 0, right: 0))
        trackMenuView.setup()
    }
    
    func setupMapMenuView(guide: UILayoutGuide){
        view.addSubviewWithAnchors(mapMenuView, top: guide.topAnchor, trailing: guide.trailingAnchor, insets: UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 10))
        mapMenuView.setup()
    }
    
    func setupLicenseView(guide: UILayoutGuide){
        view.addSubviewWithAnchors(licenseView, trailing: guide.trailingAnchor, bottom: guide.bottomAnchor, insets: UIEdgeInsets(top: 0, left: 0, bottom: OSInsets.smallInset, right: OSInsets.defaultInset))
        
        var label = UILabel()
        label.textColor = .darkGray
        label.font = .preferredFont(forTextStyle: .footnote)
        licenseView.addSubviewToRight(label, insets: .zero)
        label.text = "© "
        
        let link = UIButton()
        link.setTitleColor(.systemBlue, for: .normal)
        link.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
        licenseView.addSubviewToRight(link, leftView: label, insets: .zero)
        link.setTitle("OpenStreetMap", for: .normal)
        link.addAction(UIAction(){ action in
            UIApplication.shared.open(URL(string: "https://www.openstreetmap.org/copyright")!)
        }, for: .touchDown)
        
        label = UILabel()
        label.textColor = .darkGray
        label.font = .preferredFont(forTextStyle: .footnote)
        licenseView.addSubviewToRight(label, leftView: link, insets: .zero)
            .connectToRight(of: licenseView, inset: 0)
        label.text = " contributors"
    }
    
    func setupStatusView(guide: UILayoutGuide){
        statusView.setBackground(.transparentColor)
        statusView.setup()
        view.addSubviewWithAnchors(statusView, leading: guide.leadingAnchor, trailing: guide.trailingAnchor, bottom: licenseView.topAnchor, insets: UIEdgeInsets(top: 0, left: OSInsets.defaultInset, bottom: 0, right: OSInsets.defaultInset))
    }
    
    func setupTrackStatusView(guide: UILayoutGuide){
        trackStatusView.setBackground(.transparentColor)
        trackStatusView.setup()
        view.addSubviewWithAnchors(trackStatusView, leading: guide.leadingAnchor, trailing: guide.trailingAnchor, bottom: statusView.topAnchor, insets: UIEdgeInsets(top: 0, left: OSInsets.defaultInset, bottom: OSInsets.smallInset, right: OSInsets.defaultInset))
        trackStatusView.isHidden = true
    }
    
    //data
    
    func updateItemLayer(){
        mapView.updateItemLayer()
    }
    
    // map view
    
    func toggleCross() {
        Preferences.shared.showCenterButton = !Preferences.shared.showCenterButton
        Preferences.shared.save()
        mapView.crossButton.isHidden = !Preferences.shared.showCenterButton
    }
    
    func focusUserLocation() {
        mapView.focusUserLocation()
        Preferences.shared.followLocation = true
    }
    
    func refreshMap() {
        hideTrackOnMap()
        mapView.refresh()
    }
    
    func zoomIn() {
        if MapStatus.shared.zoom < World.maxZoom{
            MapStatus.shared.zoomIn()
            mapView.zoomTo(MapStatus.shared.zoom, animated: true)
        }
    }
    
    func zoomOut() {
        if MapStatus.shared.zoom > World.minZoom{
            MapStatus.shared.zoomOut()
            mapView.zoomTo(MapStatus.shared.zoom, animated: true)
        }
    }
    
    func toggleMapPins() {
        Preferences.shared.showMapPins = !Preferences.shared.showMapPins
        mapView.itemLayerView.isHidden = !Preferences.shared.showMapPins
    }
    
    // map items
    
    func showItemOnMap(item: MapItem){
        Preferences.shared.followLocation = false
        mapView.scrollTo(item.coordinate)
    }
    
    // notes
    
    func addNote(item: NoteItem){
        item.updateLocation()
        AppData.shared.addItem(item)
    }
    
    // track
    
    func startTracking() {
        if !TrackRecorder.shared.isTracking{
            TrackRecorder.shared.startTrack()
            trackStatusView.startTrackInfo()
        }
    }
    
    func saveTrack(result: @escaping (Bool) -> Void) {
        if TrackRecorder.shared.isTracking{
            TrackRecorder.shared.saveTrack(result: result)
            trackStatusView.stopTrackInfo()
        }
    }
    
    func cancelTrack() {
        if TrackRecorder.shared.isTracking{
            TrackRecorder.shared.cancelTracking()
            trackStatusView.stopTrackInfo()
        }
    }
    
    func togglePauseTracking() {
        if TrackRecorder.shared.isTracking{
            if TrackRecorder.shared.isRecording{
                TrackRecorder.shared.stopRecording()
            }else{
                TrackRecorder.shared.resumeRecording()
            }
        }
    }
    
    func showTrackOnMap(item: TrackItem){
        VisibleTrack.shared.setTrack(item.track)
        Preferences.shared.followLocation = false
        if item.track.coordinateRegion == nil{
            item.track.updateCoordinateRegion()
        }
        if let worldRect = item.track.worldRect{
            let zoom = World.getZoomToFit(worldRect: worldRect, scaledSize: mapView.bounds.size)
            mapView.zoomAndScrollTo(zoom, item.track.centerCoordinate ?? item.coordinate)
        }
        else{
            mapView.scrollTo(item.coordinate)
        }
        mapView.trackLayerView.setNeedsDisplay()
    }
    
    func hideTrackOnMap(){
        VisibleTrack.shared.reset()
        mapView.updateTrackLayer()
    }
    
    // route
    
    func setRouteStart(coordinate: CLLocationCoordinate2D){
        VisibleRoute.shared.setStartCoordinate(coordinate){
            self.updateRouteLayer()
        }
    }
    
    func setRouteEnd(coordinate: CLLocationCoordinate2D){
        VisibleRoute.shared.setEndCoordinate(coordinate){
            self.updateRouteLayer()
        }
    }
    
    func updateRouteLayer(){
        DispatchQueue.main.async {
            self.mapView.updateRouteLayer()
        }
    }
    
    func cancelRoute(){
        VisibleRoute.shared.reset()
        self.mapView.updateRouteLayer()
    }
    
    // camera
    
    func openCamera() {
        AVCaptureDevice.askCameraAuthorization(){ result in
            switch result{
            case .success(()):
                DispatchQueue.main.async {
                    let controller = CameraViewController()
                    controller.modalPresentationStyle = .fullScreen
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                return
            case .failure:
                DispatchQueue.main.async {
                    self.showAlert(title: "error".localize(), text: "cameraNotAuthorized".localize())
                }
                return
            }
        }
    }
    
    func photoCaptured(data: Data) {
        let imageItem = ImageItem(coordinate: LocationStatus.shared.location.coordinate)
        imageItem.altitude = LocationStatus.shared.location.altitude
        imageItem.generateFileName()
        var imageData = data
        if let dataWithCoordinates = data.setImageProperties(altitude: imageItem.altitude, latitude: imageItem.coordinate.latitude, longitude: imageItem.coordinate.longitude, utType: imageItem.url.utType!){
            imageData = dataWithCoordinates
        }
        imageItem.saveImageAndCreatePreview(data: imageData)
        Log.info("photo saved locally as \(imageItem.fileName)")
        AppData.shared.addItem(imageItem)
        AppData.shared.sortItemsByDate(ascending: ViewFilter.shared.defaultSortAscending)
        AppData.shared.save()
        mapView.updateItemLayer()
    }
    
    func videoCaptured(data: Data) {
        let video = VideoItem(coordinate: LocationStatus.shared.location.coordinate)
        video.altitude = LocationStatus.shared.location.altitude
        if video.saveVideoAndCreatePreview(data: data){
            AppData.shared.addItem(video)
            AppData.shared.sortItemsByDate(ascending: ViewFilter.shared.defaultSortAscending)
            AppData.shared.save()
            mapView.updateItemLayer()
        }
    }
    
    // audio
    
    func openAudioRecorder(){
        let controller = AudioRecorderViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func audioCaptured(audio: AudioItem){
        mapView.updateItemLayer()
    }
    
    // video
    
    func showVideo(item: VideoItem){
        let controller = VideoViewController()
        controller.videoURL = item.url
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //search
    
    func openSearch() {
        let controller = SearchViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func getCurrentRegion() -> CoordinateRegion?{
        return MapStatus.shared.getCoordinateRegion()
    }
    
    func getCurrentCenter() -> CLLocationCoordinate2D?{
        return MapStatus.shared.centerCoordinate
    }
    
    func showSearchResult(coordinate: CLLocationCoordinate2D, worldRect: CGRect?){
        Preferences.shared.followLocation = false
        if let worldRect = worldRect{
            let zoom = World.getZoomToFit(worldRect: worldRect, scaledSize: mapView.bounds.size)
            mapView.zoomAndScrollTo(zoom, coordinate)
        }
        else{
            mapView.scrollTo(coordinate)
        }
    }
    
}

extension MainViewController: LocationServiceDelegate {
    
    func locationChanged(to location: CLLocation){
        if Preferences.shared.followLocation{
            MapStatus.shared.centerCoordinate = location.coordinate
            mapView.scrollTo(location.coordinate)
        }
        if TrackRecorder.shared.isRecording{
            TrackRecorder.shared.locationChanged(to: location)
        }
        mapView.updateCurrentLocationView()
        gpsStatusView.update(accuracy: location.horizontalAccuracy)
        statusView.updateLocationInfo(location: location)
    }
    
    func directionChanged(to direction: CLLocationDirection){
        mapView.updateCurrentDirection()
        statusView.updateDirection(direction: direction)
    }
    
}

extension MainViewController: TrackRecorderDelegate {
    func trackStarted() {
        VisibleTrack.shared.reset()
    }
    
    func trackRecordingChanged() {
        trackStatusView.updateTrackInfo()
    }
    
    func addTrackpoint(_ trackpoint: Trackpoint) {
        VisibleTrack.shared.addTrackpoint(trackpoint)
    }
    
    func saveTrack(_ track: Track, result: @escaping (Bool) -> Void){
        if let tp = track.trackpoints.first{
            let item = TrackItem()
            item.track = track
            item.track.updateFromTrackpoints()
            item.coordinate = tp.coordinate
            item.altitude = tp.altitude
            AppData.shared.addItem(item)
            TrackImageCreator.createPreview(item: item)
            result(true)
        }
        else{
            result(false)
        }
        
    }
    
}






