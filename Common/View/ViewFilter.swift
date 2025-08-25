/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

class ViewFilter: Identifiable, Codable{
    
    static var storeKey = "viewFilter"
    
    static var shared = ViewFilter()
    
    static func load(){
        if let filter : ViewFilter = StatusManager.shared.getCodable(key: ViewFilter.storeKey){
            ViewFilter.shared = filter
        }
        else{
            Log.error("No saved data available for date filter")
            ViewFilter.shared = ViewFilter()
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case dateFilterMinDate
        case dateFilterMaxDate
        case useDateFilterForLists
        case useDateFilterForMap
        case defaultSortAscending
    }
    
    var dateFilterMinDate: Date? = nil
    var dateFilterMaxDate: Date? = nil
    var useDateFilterForLists: Bool = true
    var useDateFilterForMap: Bool = true
    var defaultSortAscending: Bool = false
    
    var isActive: Bool {
        return (useDateFilterForMap || useDateFilterForLists) && (dateFilterMinDate != nil || dateFilterMaxDate != nil)
    }
    
    init(){
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        dateFilterMinDate = try values.decodeIfPresent(Date.self, forKey: .dateFilterMinDate)
        dateFilterMaxDate = try values.decodeIfPresent(Date.self, forKey: .dateFilterMaxDate)
        useDateFilterForLists = try values.decodeIfPresent(Bool.self, forKey: .useDateFilterForLists) ?? true
        useDateFilterForMap = try values.decodeIfPresent(Bool.self, forKey: .useDateFilterForMap) ?? true
        defaultSortAscending = try values.decodeIfPresent(Bool.self, forKey: .defaultSortAscending) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let dateFilterMinDate = dateFilterMinDate {
            try container.encode(dateFilterMinDate, forKey: .dateFilterMinDate)
        }
        if let dateFilterMaxDate = dateFilterMaxDate {
            try container.encode(dateFilterMaxDate, forKey: .dateFilterMaxDate)
        }
        try container.encode(useDateFilterForLists, forKey: .useDateFilterForLists)
        try container.encode(useDateFilterForMap, forKey: .useDateFilterForMap)
        try container.encode(defaultSortAscending, forKey: .defaultSortAscending)
    }
    
    func save(){
        StatusManager.shared.saveCodable(key: ViewFilter.storeKey, value: self)
        //Log.debug("Date filter saved")
    }
    
    func isInFilter(item: MapItem) -> Bool{
        if let date = dateFilterMinDate, item.creationDate < date{
            return false
        }
        if let date = dateFilterMaxDate, item.creationDate > date{
            return false
        }
        return true
    }
    
    func filteredItems(items: MapItemList) -> MapItemList{
        if !useDateFilterForLists{
            return items
        }
        return items.filter(){ item in
            return isInFilter(item: item)
        }
    }
    
    func filteredNotes(notes: NoteItemList) -> NoteItemList{
        if !useDateFilterForLists{
            return notes
        }
        return notes.filter(){ item in
            return isInFilter(item: item)
        }
    }
    
    func filteredImages(images: ImageItemList) -> ImageItemList{
        if !useDateFilterForLists{
            return images
        }
        return images.filter(){ item in
            return isInFilter(item: item)
        }
    }
    
    func filteredTracks(tracks: TrackItemList) -> TrackItemList{
        if !useDateFilterForLists{
            return tracks
        }
        return tracks.filter(){ item in
            return isInFilter(item: item)
        }
    }
    
}


