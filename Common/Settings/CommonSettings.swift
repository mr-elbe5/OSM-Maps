/*
 OSM Maps (Mac)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import OSLog

class CommonSettings: Identifiable, Codable{
    
    static var storeKey = "preferences"
    
    static var shared = Settings()
    
    static func load(){
        if let prefs : Settings = StatusManager.shared.getCodable(key: CommonSettings.storeKey){
            Settings.shared = prefs
        }
        else{
            Logger.error("no saved data available for settings")
            Settings.shared = Settings()
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case tileSource
        case showOverlay
    }
    
    var tileSource: TileSource = TileSource.defaultTileSource
    var overlayTileSources: [OverlayTileSource]{
        OverlayTileSources.shared.filter { $0.active }.sorted()
    }
    var showOverlay: Bool = false
    
    var hasOverlay: Bool{
        !overlayTileSources.isEmpty
    }
    
    var tileDirURL: URL{
        BasePaths.tileDirURL.appendingPathComponent(tileSource.name)
    }
    
    var overlayTileDirURLs: Array<URL>{
        var urls = Array<URL>()
        for source in overlayTileSources{
            urls.append(BasePaths.tileDirURL.appendingPathComponent(source.name))
        }
        return urls
    }
    
    init(){
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let tileSourceString = try? values.decodeIfPresent(String.self, forKey: .tileSource){
            tileSource = TileSources.shared.first(where: { $0.name == tileSourceString }) ?? TileSource.defaultTileSource
        }
        showOverlay = try values.decodeIfPresent(Bool.self, forKey: .showOverlay) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tileSource.name, forKey: .tileSource)
        try container.encode(showOverlay, forKey: .showOverlay)
    }
    
    func assertInitialTileDir(){
        FileManager.default.assertDirectory(url: tileDirURL)
        let names = FileManager.default.listAllFiles(dirPath: BasePaths.tileDirURL.path())
        for name in names{
            if name.hasSuffix(".png"){
                FileManager.default.moveFile(fromURL: BasePaths.tileDirURL.appendingPathComponent(name), toURL: tileDirURL.appendingPathComponent(name))
                Logger.info("moved file \(name)")
            }
        }
    }
    
    func assertTileDirs(){
        Logger.debug("asserting \(tileDirURL.lastPathComponent)")
        FileManager.default.assertDirectory(url: tileDirURL)
        for url in overlayTileDirURLs{
            FileManager.default.assertDirectory(url: url)
        }
    }
    
    func save(){
        StatusManager.shared.saveCodable(key: CommonSettings.storeKey, value: self)
        Logger.debug("Settings saved")
    }
    
}



