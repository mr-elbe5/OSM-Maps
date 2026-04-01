/*
 OSM Maps (Mac)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        BasePaths.initializeDirs()
        AppStatus.load()
        AppStatus.shared.updateVersion()
        World.setMaxZoom(18)
        World.scrollWidthFactor = 1
        MapDefaults.startZoom = 8
        TileSources.load()
        Settings.load()
        Settings.shared.assertInitialTileDir()
        ViewFilter.load()
        MapStatus.load()
        AppData.load()
        MapDefaults.startZoom = 14
        //FileManager.default.logFileInfo()
        NSApp.appearance = NSAppearance(named: .darkAqua)
        MainWindowController.instance.showWindow(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        TileSources.save()
        TileSources.saveOverlays()
        Settings.shared.save()
        AppStatus.shared.save()
        MapStatus.shared.save()
        AppData.shared.save()
        let count = FileManager.default.deleteTemporaryFiles()
        if count > 0{
            Log.debug("\(count) temporary file(s) deleted")
        }
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

