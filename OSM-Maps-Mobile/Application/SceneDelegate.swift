/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        Log.debug("Scene will connect")
        BasePaths.initializeDirs()
        MapDefaults.startZoom = 14
        Preferences.load()
        ViewFilter.load()
        MapStatus.load()
        AppData.load()
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        let navViewController = UINavigationController(rootViewController: MainViewController.shared)
        window?.rootViewController = navViewController
        window?.makeKeyAndVisible()
        
        LocationService.shared.start()
        WatchConnector.shared.start()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        Log.debug("Scene did disconnect")
        let count = FileManager.default.deleteTemporaryFiles()
        if count > 0{
            Log.debug("\(count) temporary file(s) deleted")
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        Log.debug("Scene did become active")
        if !LocationService.shared.running{
            LocationService.shared.start()
        }
        //Log.debug("center = \(MapStatus.shared.getCenterCoordinate()), zoom = \(MapStatus.shared.getZoom())")
        
    }

    func sceneWillResignActive(_ scene: UIScene) {
        Log.debug("Scene will resign active, saving state, preferences and data")
        Preferences.shared.save()
        MapStatus.shared.save()
        AppData.shared.save()
        if TrackRecorder.shared.isRecording{
            if !LocationService.shared.authorizedForTracking{
                LocationService.shared.requestAlwaysAuthorization()
            }
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        Log.debug("SceneDelegate entering foreground")
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        Log.debug("SceneDelegate entering background")
    }


}
