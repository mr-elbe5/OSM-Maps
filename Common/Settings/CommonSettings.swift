/*
 OSM Maps (Mac)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

class CommonSettings: Identifiable, Codable{
    
    static var storeKey = "preferences"
    
    static var shared = Settings()
    
    static func load(){
        if let prefs : Settings = StatusManager.shared.getCodable(key: CommonSettings.storeKey){
            Settings.shared = prefs
        }
        else{
            Log.error("no saved data available for settings")
            Settings.shared = Settings()
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case tileSource
        case overlayTileSource
        case showOverlay
    }
    
    var tileSource: TileSource = TileSource.defaultTileSource
    var overlayTileSource: TileSource? = nil
    var showOverlay: Bool = false
    
    var hasOverlay: Bool{
        overlayTileSource != nil
    }
    
    var tileDirURL: URL{
        BasePaths.tileDirURL.appendingPathComponent(tileSource.name)
    }
    
    var overlayTileDirURL: URL?{
        if let source = overlayTileSource{
            return BasePaths.tileDirURL.appendingPathComponent(source.name)
        }
        return nil
    }
    
    init(){
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let tileSourceString = try? values.decodeIfPresent(String.self, forKey: .tileSource){
            tileSource = TileSources.shared.first(where: { $0.name == tileSourceString }) ?? TileSource.defaultTileSource
        }
        if let overlaySourceString = try? values.decodeIfPresent(String.self, forKey: .overlayTileSource){
            overlayTileSource = TileSources.sharedOverlays.first(where: { $0.name == overlaySourceString })
        }
        showOverlay = try values.decodeIfPresent(Bool.self, forKey: .showOverlay) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tileSource.name, forKey: .tileSource)
        try container.encodeIfPresent(overlayTileSource?.name, forKey: .overlayTileSource)
        try container.encode(showOverlay, forKey: .showOverlay)
    }
    
    func assertInitialTileDir(){
        FileManager.default.assertDirectory(url: tileDirURL)
        let names = FileManager.default.listAllFiles(dirPath: BasePaths.tileDirURL.path())
        for name in names{
            if name.hasSuffix(".png"){
                FileManager.default.moveFile(fromURL: BasePaths.tileDirURL.appendingPathComponent(name), toURL: tileDirURL.appendingPathComponent(name))
                Log.info("moved file \(name)")
            }
        }
    }
    
    func assertTileDirs(){
        Log.debug("asserting \(tileDirURL.lastPathComponent)")
        FileManager.default.assertDirectory(url: tileDirURL)
        if let url = overlayTileDirURL{
            FileManager.default.assertDirectory(url: url)
        }
    }
    
    func setDefaultSources(){
        tileSource = TileSource.defaultTileSource
        overlayTileSource = nil
        save()
    }
    
    func save(){
        StatusManager.shared.saveCodable(key: CommonSettings.storeKey, value: self)
        Log.debug("Settings saved")
    }
    
}



