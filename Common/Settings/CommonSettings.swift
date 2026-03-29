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
    }
    
    var mapSource: MapSource = .osmSource
    
    var tileDirURL: URL{
        BasePaths.tileDirURL.appendingPathComponent(mapSource.name)
    }
    
    init(){
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let mapSourceString = try? values.decodeIfPresent(String.self, forKey: .mapSource){
            mapSource = MapSources.shared.first(where: { $0.name == mapSourceString }) ?? .osmSource
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mapSource.name, forKey: .mapSource)
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
    
    func assertTileDir(){
        FileManager.default.assertDirectory(url: tileDirURL)
    }
    
    func save(){
        StatusManager.shared.saveCodable(key: CommonSettings.storeKey, value: self)
        Log.debug("Settings saved")
    }
    
}



