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
        if tile.exists, let fileData = FileManager.default.contents(atPath: tile.fileUrl.path){
            Log.debug("got local tile")
            tile.imageData = fileData
            result(true)
        } else {
            Log.debug("loading tile")
            loadTileImage(tile: tile){ success in
                result(success)
            }
        }
    }
    
    func getTileOverlayImage(tile: MapTile, result: @escaping (Bool) -> Void) {
        if !tile.valid {
            return
        }
        if tile.overlayExists, let url = tile.overlayFileUrl, let fileData = FileManager.default.contents(atPath: url.path){
            Log.debug("got local overlay tile")
            tile.overlayImageData = fileData
            result(true)
        } else {
            Log.debug("loading overlay tile")
            loadTileOverlayImage(tile: tile){ success in
                result(success)
            }
        }
    }
    
    func loadTileImage(tile: MapTile, result: @escaping (Bool) -> Void) {
        if !tile.valid {
            result(false)
            return
        }
        let request = URLRequest(url: tile.tileUrl(template: Settings.shared.mapSource.templateUrl), cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30.0)
        let task = getDownloadTask(request: request){ data in
            if let data = data{
                Log.debug("got remote tile in first try")
                self.setImageData(data, to: tile)
            }
            else{
                self.retryLoadTileImage(tile: tile, tries: 1){ success in
                    result(success)
                }
            }
        }
        DispatchQueue.global(qos: .userInitiated).async{
            Log.debug("loading remote tile")
            task.resume()
        }
    }
    
    func loadTileOverlayImage(tile: MapTile, result: @escaping (Bool) -> Void) {
        if !tile.valid {
            result(false)
            return
        }
        if let templateUrl = Settings.shared.mapOverlaySource?.templateUrl {
            let request = URLRequest(url: tile.tileUrl(template: templateUrl), cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30.0)
            let task = getDownloadTask(request: request){ data in
                if let data = data{
                    Log.debug("got remote overlay tile in first try")
                    self.setOverlayImageData(data, to: tile)
                }
                else{
                    self.retryLoadOverlayTileImage(tile: tile, tries: 1){ success in
                        result(success)
                    }
                }
            }
            DispatchQueue.global(qos: .userInitiated).async{
                Log.debug("loading remote overlay tile")
                task.resume()
            }
        }
        else{
            result(false)
        }
    }
    
    private func setImageData(_ data: Data, to tile: MapTile){
        tile.imageData = data
        Log.debug("saving tile to \(tile.fileUrl)")
        if !self.saveTile(fileUrl: tile.fileUrl, data: data){
            Log.error("TileProvider could not save tile \(tile.shortDescription)")
        }
    }
    
    private func setOverlayImageData(_ data: Data, to tile: MapTile){
        if let url = tile.overlayFileUrl{
            tile.overlayImageData = data
            Log.debug("saving overlay tile to \(tile.fileUrl)")
            if !self.saveTile(fileUrl: url, data: data){
                Log.error("TileProvider could not save overlay tile \(tile.shortDescription)")
            }
        }
    }
    
    private func retryLoadTileImage(tile: MapTile, tries: Int, result: @escaping (Bool) -> Void) {
        let request = URLRequest(url: tile.tileUrl(template: Settings.shared.mapSource.templateUrl), cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 20.0)
        Log.debug("retrying remote loading tile, try \(tries)")
        let task = getDownloadTask(request: request){ data in
            if let data = data{
                Log.debug("got remote tile, try \(tries)")
                self.setImageData(data, to: tile)
                result(true)
            }
            else if tries <= TileProvider.maxTries{
                self.retryLoadTileImage(tile: tile, tries: tries + 1){ success in
                    result(success)
                }
            }
        }
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 5){
            task.resume()
        }
    }
    
    private func retryLoadOverlayTileImage(tile: MapTile, tries: Int, result: @escaping (Bool) -> Void) {
        let request = URLRequest(url: tile.tileUrl(template: Settings.shared.mapSource.templateUrl), cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 20.0)
        Log.debug("retrying remote loading overlay tile, try \(tries)")
        let task = getDownloadTask(request: request){ data in
            if let data = data{
                Log.debug("got remote overlay tile, try \(tries)")
                self.setOverlayImageData(data, to: tile)
                result(true)
            }
            else if tries <= TileProvider.maxTries{
                self.retryLoadOverlayTileImage(tile: tile, tries: tries + 1){ success in
                    result(success)
                }
            }
        }
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 5){
            task.resume()
        }
    }
    
    private func getDownloadTask(request: URLRequest, result: @escaping (Data?) -> Void) -> URLSessionDataTask{
        URLSession.shared.dataTask(with: request) { (data, response, err) in
            var statusCode = 0
            if let urlError = err as? URLError{
                if urlError.code == .timedOut {
                    print("tile request timed out ...")
                }
                result(nil)
                return
            }
            if (response != nil && response is HTTPURLResponse){
                let httpResponse = response! as! HTTPURLResponse
                statusCode = httpResponse.statusCode
            }
            if statusCode == 200, let data = data{
                result(data)
            }
            else{
                result(nil)
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
    
    func deleteCurrentTiles(){
        let count = FileManager.default.deleteAllFiles(dirURL: Settings.shared.tileDirURL)
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

