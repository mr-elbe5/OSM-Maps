/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

class TileProvider{
    
    static var shared: TileProvider = TileProvider()
    
    static let maxTries: Int = 3
    
    static func logTileFiles(){
        Log.info("tile files:")
        let names = FileManager.default.listAllFiles(dirPath: BasePaths.tileDirURL.path)
        for name in names{
            Log.error(name)
        }
    }
    
    func getTileImage(tile: MapTile, result: @escaping (Bool) -> Void) {
        if !tile.valid {
            return
        }
        //Log.debug("cache has \(tileCache.count) tiles")
        if tile.exists, let fileData = FileManager.default.contents(atPath: tile.fileUrl.path){
            //Log.debug("got local tile")
            tile.imageData = fileData
            result(true)
        } else {
            //Log.debug("loading tile")
            loadTileImage(tile: tile, result: result)
        }
    }
    
    func loadTileImage(tile: MapTile, result: @escaping (Bool) -> Void) {
        if !tile.valid {
            result(false)
            return
        }
        let request = URLRequest(url: tile.tileUrl(template: Preferences.shared.mapSource.templateUrl), cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30.0)
        let task = getDownloadTask(request: request, tile: tile, tries: 1, result: result)
        DispatchQueue.global(qos: .userInitiated).async{
            //Log.debug("loading remote tile")
            task.resume()
        }
    }
    
    private func retryLoadTileImage(tile: MapTile, tries: Int, result: @escaping (Bool) -> Void) {
        let request = URLRequest(url: tile.tileUrl(template: Preferences.shared.mapSource.templateUrl), cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 20.0)
        let task = getDownloadTask(request: request, tile: tile, tries: tries, result: result)
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 5){
            task.resume()
        }
    }
    
    private func getDownloadTask(request: URLRequest, tile: MapTile, tries: Int, result: @escaping (Bool) -> Void) -> URLSessionDataTask{
        URLSession.shared.dataTask(with: request) { (data, response, err) in
            var statusCode = 0
            if let urlError = err as? URLError{
                if urlError.code == .timedOut {
                    print("tile request timed out ...")
                }
                result(false)
                return
            }
            if (response != nil && response is HTTPURLResponse){
                let httpResponse = response! as! HTTPURLResponse
                statusCode = httpResponse.statusCode
            }
            if statusCode == 200, let data = data{
                //Log.debug("TileProvider loaded tile \(tile.shortDescription)")
                if tries > 1{
                    //Log.debug("TileProvider got tile in try \(tries)")
                }
                if !self.saveTile(fileUrl: tile.fileUrl, data: data){
                    Log.error("TileProvider could not save tile \(tile.shortDescription)")
                }
                tile.imageData = data
                result(true)
                return
            }
            if tries <= TileProvider.maxTries{
                self.retryLoadTileImage(tile: tile, tries: tries + 1){ success in
                    result(success)
                }
            }
            else{
                result(false)
            }
        }
    }
    
    func saveTile(fileUrl: URL, data: Data?) -> Bool{
        if let data = data{
            do{
                try data.write(to: fileUrl, options: .atomic)
                //Log.debug("TileProvider file saved to \(fileUrl)")
                return true
            } catch let err{
                Log.debug("TileProvider saving tile: " + err.localizedDescription)
                return false
            }
        }
        return false
    }
    
    func deleteAllTiles(){
        let count = FileManager.default.deleteAllFiles(dirURL: BasePaths.tileDirURL)
        Log.info("TileProvider \(count) tiles cleared")
    }
    
    func dumpTiles(){
        var paths = Array<String>()
        if let subpaths = FileManager.default.subpaths(atPath: BasePaths.tileDirURL.path){
            for path in subpaths{
                paths.append(path)
            }
            paths.sort()
        }
        for path in paths{
            Log.error(path)
        }
    }
    
}

