/*
 OSM Maps (Mac)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        BasePaths.initializeDirs()
        World.setMaxZoom(18)
        World.scrollWidthFactor = 1
        MapDefaults.startZoom = 8
        Preferences.load()
        ViewFilter.load()
        AppStatus.load()
        MapStatus.load()
        AppData.load()
        MapDefaults.startZoom = 14
        //FileManager.default.logFileInfo()
        NSApp.appearance = NSAppearance(named: .darkAqua)
        MainWindowController.instance.showWindow(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        Preferences.shared.save()
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

