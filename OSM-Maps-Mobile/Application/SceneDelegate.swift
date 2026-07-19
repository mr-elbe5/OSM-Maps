/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import OSLog

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        Logger.debug("Scene will connect")
        BasePaths.initializeDirs()
        AppStatus.load()
        AppStatus.shared.updateVersion()
        MapDefaults.startZoom = 14
        TileSources.load()
        OverlayTileSources.load()
        Settings.load()
        Settings.shared.assertInitialTileDir()
        ViewFilter.load()
        MapStatus.load()
        AppData.load()
        Logger.info("current UTC offset: \(UTCOffset.current.value)")
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        let navViewController = UINavigationController(rootViewController: MainViewController.shared)
        window?.rootViewController = navViewController
        window?.makeKeyAndVisible()
        
        LocationService.shared.start()
        WatchConnector.shared.start()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        Logger.debug("Scene did disconnect")
        let count = FileManager.default.deleteTemporaryFiles()
        if count > 0{
            Logger.debug("\(count) temporary file(s) deleted")
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        Logger.debug("Scene did become active")
        assertLocationService()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        Logger.debug("Scene will resign active, saving state, settings and data")
        TileSources.shared.save()
        OverlayTileSources.shared.save()
        Settings.shared.save()
        MapStatus.shared.save()
        AppData.shared.save()
        pauseLocationServiceIfNotRecording()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        Logger.debug("SceneDelegate entering foreground")
        assertLocationService()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        Logger.debug("SceneDelegate entering background")
        pauseLocationServiceIfNotRecording()
    }

    private func assertLocationService(){
        if !LocationService.shared.running{
            LocationService.shared.start()
        }
    }
    
    private func pauseLocationServiceIfNotRecording(){
        if TrackRecorder.shared.isRecording{
            if !LocationService.shared.authorizedForTracking{
                LocationService.shared.requestAlwaysAuthorization()
            }
        }
        else{
            LocationService.shared.stop()
        }
    }

}
