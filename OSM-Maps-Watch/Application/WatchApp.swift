/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import SwiftUI
import WatchKit

class WatchAppDelegate: NSObject, WKApplicationDelegate {
    
    override init(){
        BasePaths.initializeDirs()
        AppStatus.load()
        AppStatus.shared.updateVersion()
        World.scrollWidthFactor = 1.0
        MapDefaults.startZoom = 14
        Preferences.shared.followLocation = true
        WatchMapStatus.shared.zoom = MapDefaults.startZoom
        TrackRecorder.shared.delegate = TrackStatus.shared
        RouteStatus.loadStatus()
        //TileProvider.shared?.dumpTiles()
    }
    
    func applicationDidFinishLaunching() {
        Log.error("app did finish launching")
        LocationService.shared.start()
        LocationService.shared.delegate = WatchMapStatus.shared
        WatchHealthStatus.shared.startMonitoring()
    }

    func applicationDidBecomeActive(){
        Log.debug("app did become active")
        LocationService.shared.start()
    }
    
    func applicationWillResignActive(){
        Log.debug("app will resign active")
        if !TrackRecorder.shared.isTracking {
            LocationService.shared.stop()
        }
    }
    
    func applicationDidEnterBackground() {
        Log.debug("app did enter background")
        if !TrackRecorder.shared.isTracking {
            LocationService.shared.stop()
        }
    }
    
    func applicationWillEnterForeground() {
        Log.debug("app will enter foreground")
        LocationService.shared.start()
    }

}

@main
struct Watch_App: App {
    
    @WKApplicationDelegateAdaptor var appDelegate: WatchAppDelegate
    
    @State var phoneConnector = PhoneConnector.shared
    var body: some Scene {
        WindowGroup {
            NavigationStack() {
                WatchMainView()
            }
            .onAppear(){
                WatchMapStatus.shared.screenSize = WKInterfaceDevice.current().screenBounds
                WatchMapStatus.shared.locationChanged(to: LocationStatus.shared.location)
                LocationService.shared.delegate = WatchMapStatus.shared
                WatchMapStatus.shared.updateTiles()
            }
        }
        
    }
}
