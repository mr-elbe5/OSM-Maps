/*
 OSM Maps (Mac)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class AppStatus: Identifiable, Codable{
    
    static var storeKey = "appStatus"
    
    static var shared = AppStatus()
    
    static func load(){
        if let status : AppStatus = StatusManager.shared.getCodable(key: AppStatus.storeKey){
            AppStatus.shared.sortAscending = status.sortAscending
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case sortAscending
    }
    
    var sortAscending: Bool = true
    
    var currentViewImage: ImageItem? = nil{
        didSet{
            if currentViewImage != nil{
                imageViewMode = true
            }
        }
    }
    var imageViewMode: Bool = false
    
    var currentViewTrack: Track? = nil{
        didSet{
            if currentViewTrack != nil{
                trackEditMode = false
                trackViewMode = true
            }
        }
    }
    var trackViewMode: Bool = false{
        didSet{
            if !trackViewMode{
                currentViewTrack = nil
            }
        }
    }
    
    var currentEditTrack: Track? = nil{
        didSet{
            if currentEditTrack != nil{
                trackViewMode = false
                trackEditMode = true
            }
        }
    }
    var trackEditMode = false{
        didSet{
            if !trackEditMode{
                currentEditTrack = nil
            }
        }
    }
    
    var currentMapDetails = MapItemList()
    
    init(){
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        sortAscending = try values.decodeIfPresent(Bool.self, forKey: .sortAscending) ?? true
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sortAscending, forKey: .sortAscending)
    }
    
    func showItemOnMap(_ item: MapItem){
        MapStatus.shared.centerCoordinate = item.coordinate
        setMapDetail(item)
    }
    
    func showTrackOnMap(_ item: Track){
        if let region = item.coordinateRegion{
            MapStatus.shared.centerCoordinate = region.center
        }
    }
    
    func setMapDetail(_ item: MapItem){
        //selectedTab = .map
        currentMapDetails.removeAll()
        currentMapDetails.append(item)
    }
    
    func setMapDetails(_ group: MapItemGroup){
        //selectedTab = .map
        currentMapDetails.removeAll()
        currentMapDetails.append(contentsOf: group.items)
    }
    
    func setDetailImage(_ track: ImageItem){
        currentViewImage = track
    }
    
    func setDetailTrack(_ track: Track){
        currentViewTrack = track
    }
    
    func setEditTrack(_ track: Track){
        currentEditTrack = track
    }
    
    func save(){
        StatusManager.shared.saveCodable(key: AppStatus.storeKey, value: self)
    }
    
}

