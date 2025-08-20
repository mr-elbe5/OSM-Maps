/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import Photos
import Zip
import OSLog

class Backup{
    
    static func createBackupFile(at url: URL) -> Bool{
        do {
            let count = FileManager.default.deleteTemporaryFiles()
            if count > 0{
                Log.debug("\(count) temporary file(s) deleted before backup")
            }
            var paths = Array<URL>()
            paths.append(BasePaths.imageDirURL)
            if let url = AppData.shared.saveAsFile(){
                paths.append(url)
            }
            else{
                Log.debug("could not create zip file: could not save json")
                return false
            }
            try Zip.zipFiles(paths: paths, zipFilePath: url, password: nil, progress: { (progress) -> () in
                //Log.debug(progress)
            })
            return true
        }
        catch let err {
            Log.error("could not create zip file", err)
        }
        return false
    }
    
    static func unzipBackupFile(zipFileURL: URL) -> Bool{
        do {
            let count = FileManager.default.deleteTemporaryFiles()
            if count > 0{
                Log.debug("\(count) temporary file(s) deleted before restore")
            }
            try FileManager.default.createDirectory(at: BasePaths.tempURL, withIntermediateDirectories: true)
            try Zip.unzipFile(zipFileURL, destination: BasePaths.tempURL, overwrite: true, password: nil, progress: { (progress) -> () in
                //Log.debug(progress)
            })
            return true
        }
        catch (let err){
            Log.error("could not read zip file: \(err.localizedDescription)")
        }
        return false
    }
    
    static func restoreBackupFile() -> Bool{
        if !FileManager.default.fileExists(url: BasePaths.tempURL.appendingPathComponent("images")){
            Log.error("wrong zip file")
            FileManager.default.deleteTemporaryFiles()
            return false
        }
        var count = FileManager.default.deleteAllFiles(dirURL: BasePaths.imageDirURL)
        if count > 0{
            Log.debug("\(count) image file(s) deleted before restore")
        }
        count = FileManager.default.deleteAllFiles(dirURL: BasePaths.previewDirURL)
        if count > 0{
            Log.debug("\(count) preview file(s) deleted before restore")
        }
        let fileNames = FileManager.default.listAllFiles(dirPath: BasePaths.tempURL.appendingPathComponent("images").path)
        for name in fileNames{
            FileManager.default.copyFile(fromURL: BasePaths.tempURL.appendingPathComponent("images").appendingPathComponent(name), toURL: BasePaths.imageDirURL.appendingPathComponent(name), replace: true)
        }
        let url = BasePaths.tempURL.appendingPathComponent(AppData.storeKey + ".json")
        AppData.shared.loadFromFile(url: url)
        AppData.shared.removeAllDeletedIds()
        AppData.shared.save()
        for item in AppData.shared.images{
            if let image = item.image{
                item.createPreviewFile(original: image)
            }
        }
        count = FileManager.default.deleteTemporaryFiles()
        if count > 0{
            Log.debug("\(count) temporary file(s) deleted after restore")
        }
        return true
    }
    
    static func importfromMapsForOSMFile() -> Bool{
        if !FileManager.default.fileExists(url: BasePaths.tempURL.appendingPathComponent("media")){
            Log.error("wrong zip file")
            FileManager.default.deleteTemporaryFiles()
            return false
        }
        var count = FileManager.default.deleteAllFiles(dirURL: BasePaths.imageDirURL)
        if count > 0{
            Log.debug("\(count) image files deleted before restore")
        }
        count = FileManager.default.deleteAllFiles(dirURL: BasePaths.previewDirURL)
        if count > 0{
            Log.debug("\(count) preview file(s) deleted before restore")
        }
        let url = BasePaths.tempURL.appendingPathComponent("locations.json")
        let oldMapItems = OldMapItems()
        let locationList = oldMapItems.loadFromFile(url: url)
        Log.debug(locationList.count)
        oldMapItems.convert(from: locationList)
        AppData.shared.replaceItems(oldMapItems.items)
        AppData.shared.removeAllDeletedIds()
        AppData.shared.save()
        count = FileManager.default.deleteTemporaryFiles()
        if count > 0{
            Log.debug("\(count) temporary files deleted after restore")
        }
        return true
    }
    
}
