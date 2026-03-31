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
        case mapSource
        case mapOverlaySource
    }
    
    var mapSource: MapSource = MapSource.defaultMapSource
    var mapOverlaySource: MapOverlaySource? = nil
    
    var hasOverlay: Bool{
        mapOverlaySource != nil
    }
    
    var tileDirURL: URL{
        BasePaths.tileDirURL.appendingPathComponent(mapSource.name)
    }
    
    var overlayTileDirURL: URL?{
        if let source = mapOverlaySource{
            return BasePaths.tileDirURL.appendingPathComponent(source.name)
        }
        return nil
    }
    
    init(){
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let mapSourceString = try? values.decodeIfPresent(String.self, forKey: .mapSource){
            mapSource = MapSources.shared.first(where: { $0.name == mapSourceString }) ?? MapSource.defaultMapSource
        }
        if let overlaySourceString = try? values.decodeIfPresent(String.self, forKey: .mapOverlaySource){
            mapOverlaySource = MapOverlaySources.shared.first(where: { $0.name == overlaySourceString })
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mapSource.name, forKey: .mapSource)
        try container.encodeIfPresent(mapOverlaySource?.name, forKey: .mapOverlaySource)
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
        FileManager.default.assertDirectory(url: tileDirURL)
        if let url = overlayTileDirURL{
            FileManager.default.assertDirectory(url: url)
        }
    }
    
    func setDefaultSources(){
        mapSource = MapSource.defaultMapSource
        mapOverlaySource = nil
        save()
    }
    
    func save(){
        StatusManager.shared.saveCodable(key: CommonSettings.storeKey, value: self)
        Log.debug("Settings saved")
    }
    
}



