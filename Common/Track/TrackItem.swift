/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import CloudKit
import SwiftUI

class TrackItem: MapItem{
    
    static var itemType: String = "track"
    
    static var previewSize: CGFloat = 512
    static var imageSize: CGFloat = 2048
    
    static func == (lhs: TrackItem, rhs: TrackItem) -> Bool {
        lhs.id == rhs.id
    }
    
    private enum CodingKeys: String, CodingKey {
        case track
    }
    
    var track : Track
    
    override var itemType: String{
        TrackItem.itemType
    }
    
    override var coordinate: CLLocationCoordinate2D{
        get{
            track.startCoordinate ?? .zero
        }
        set {
            super.coordinate = newValue
        }
    }
    
    var coordinateRegion: CoordinateRegion?{
        var reg = track.coordinateRegion
        if reg == nil || reg == .zero{
            track.updateCoordinateRegion()
            reg = track.coordinateRegion
        }
        return reg
    }
    
    var fileName: String{
        "track_\(id).jpg"
    }
    
    var previewURL: URL{
        BasePaths.previewDirURL.appendingPathComponent(fileName)
    }
    
    override init(){
        track = Track()
        super.init()
    }
    
    init(gpx: GPXData){
        track = Track(gpx: gpx)
        super.init()
    }
    
    init(track: Track){
        self.track = track
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        track = try values.decodeIfPresent(Track.self, forKey: .track) ?? Track()
        try super.init(from: decoder)
        coordinate = track.startCoordinate ?? .zero
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try super .encode(to: encoder)
        try container.encode(track, forKey: .track)
    }
    
    func getPreviewFile() -> Data?{
        FileManager.default.readFile(url: previewURL)
    }
    
    func trackpointsChanged(){
        if FileManager.default.fileExists(url: previewURL){
            FileManager.default.deleteFile(url: previewURL)
        }
    }
    
    @discardableResult
    func deleteFiles() -> Bool{
        if FileManager.default.fileExists(dirPath: BasePaths.previewDirURL.path, fileName: fileName){
            if !FileManager.default.deleteFile(url: BasePaths.previewDirURL.appendingPathComponent(fileName)){
                Log.error("Track could not delete preview: \(fileName)")
                return false
            }
        }
        return true
    }
    
    func getPreview() -> OSImage?{
        if let data = getPreviewFile(){
            return OSImage(data: data)
        } else{
            return TrackImageCreator.createPreview(item: self)
        }
    }
    
    override func prepareToDelete(){
        deleteFiles()
    }
    
}

extension TrackItem: Transferable {
    
    public static var transferRepresentation: some TransferRepresentation {
        
        DataRepresentation(exportedContentType: .gpx) { item in
            let gpx = GPXCreator.trackString(track: item.track)
            return Data(gpx.utf8)
        }
    }
    
    enum ConversionError: Error {
        case failedToConvertToGPX
    }
}

typealias TrackItemList = SelectableList<TrackItem>

extension TrackItemList{
    
    mutating func sortByDate(ascending: Bool){
        if ascending{
            self.sort(by: { $0.creationDate < $1.creationDate})
        }
        else{
            self.sort(by: { $0.creationDate > $1.creationDate})
        }
    }
    
}
