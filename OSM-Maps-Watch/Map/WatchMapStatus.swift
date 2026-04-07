/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import WatchKit

typealias MapTileRow = [MapTile]
typealias MapTileGrid = [MapTileRow]

@Observable class WatchMapStatus: NSObject{
    
    static var shared = WatchMapStatus()
    
    var currentCoordinate: CLLocationCoordinate2D? = nil
    var centerCoordinate: CLLocationCoordinate2D? = nil
    var direction: CLLocationDirection = 0
    
    var screenSize = WKInterfaceDevice.current().screenBounds
    let tileExtent: CGFloat = World.tileExtent
    var gridWidth: Int = 1
    var gridHeight: Int = 1
    var tileGrid: MapTileGrid = []
    var overlayGrid: MapTileGrid = []
    
    var centerTileX: Int = 0
    var centerTileY: Int = 0
    var horzExtraTiles: Int = 0
    var vertExtraTiles: Int = 0
    var tileOffsetX: CGFloat = 0
    var tileOffsetY: CGFloat = 0
    var currentLocationOffset: CGSize = .zero
    
    var zoom: Int = MapDefaults.startZoom
    
    private var downScaleFromWorld = World.downScale(to: MapDefaults.startZoom)
    private var scaledWorldCenterX = 0.0
    private var scaledWorldCenterY = 0.0
    
    var tilesLoaded = false
    
    // tile 16/34530/21183
    
    override init(){
        super.init()
        currentCoordinate = LocationStatus.shared.coordinate
        centerCoordinate = LocationStatus.shared.coordinate
        horzExtraTiles = Int(floor(screenSize.width/2 / tileExtent)) + 2
        vertExtraTiles = Int(floor(screenSize.height/2 / tileExtent)) + 2
        gridWidth = 2 * horzExtraTiles + 1
        gridHeight = 2 * vertExtraTiles + 1
        //Log.debug("grid size = \(gridWidth) x \(gridHeight)")
        for _ in 0..<gridHeight {
            var row = MapTileRow()
            var overlayRow = MapTileRow()
            for _ in 0..<gridWidth {
                row.append(MapTile.dummyTile)
                overlayRow.append(MapTile.dummyTile)
            }
            tileGrid.append(row)
            overlayGrid.append(overlayRow)
        }
    }
    
    func setCenterCoordinate(_ coordinate: CLLocationCoordinate2D){
        self.centerCoordinate = coordinate
        updateWorldValues()
    }
    
    private func setCurrentCoordinate(_ coordinate: CLLocationCoordinate2D){
        self.currentCoordinate = coordinate
        updateWorldValues()
    }
    
    @discardableResult
    private func updateWorldValues() -> Bool{
        if let coordinate = centerCoordinate{
            downScaleFromWorld = World.downScale(to: zoom)
            scaledWorldCenterX = World.scaledX(coordinate.longitude, downScale: downScaleFromWorld)
            scaledWorldCenterY = World.scaledY(coordinate.latitude, downScale: downScaleFromWorld)
            return true
        }
        return false
    }
    
    func updateTiles(){
        let centerTileLeft = scaledWorldCenterX - tileExtent/2
        let centerTileTop = scaledWorldCenterY - tileExtent/2
        centerTileX = Int(floor(centerTileLeft / tileExtent))
        centerTileY = Int(floor(centerTileTop / tileExtent))
        //print("centerTile \(centerTileX), \(centerTileY)")
        
        // diff of tile edge to center plus offset to tile center
        tileOffsetX = (Double(centerTileX)*tileExtent - scaledWorldCenterX + tileExtent/2)
        tileOffsetY = (Double(centerTileY)*tileExtent - scaledWorldCenterY + tileExtent/2)
        //print("offset: \(tileOffsetX),\(tileOffsetY)")
        updateTileGrid()
    }
    
    func refresh(){
        updateTileGrid()
    }
    
    private func updateTileGrid(){
        //print("update grid")
        tilesLoaded = true
        for y in 0..<gridHeight {
            for x in 0..<gridWidth {
                let currentTile = tileGrid[y][x]
                let newTileX = centerTileX - horzExtraTiles + x
                let newTileY = centerTileY - vertExtraTiles + y
                if currentTile.zoom != zoom || currentTile.x != newTileX || currentTile.y != newTileY || currentTile.tileSource != Settings.shared.tileSource{
                    //print("changing tile")
                    let tile = MapTile(zoom: zoom, x: newTileX, y: newTileY, tileSource: Settings.shared.tileSource)
                    TileProvider.shared.getTileImage(tile: tile){ success in
                        if !success{
                            self.tilesLoaded = false
                            Log.error("TileLayerView could not load tile \(tile.shortDescription)")
                        }
                    }
                    tileGrid[y][x] = tile
                }
                if Settings.shared.hasOverlay, let overlaySource = Settings.shared.overlayTileSource{
                    let currentTile = overlayGrid[y][x]
                    if currentTile.zoom != zoom || currentTile.x != newTileX || currentTile.y != newTileY || currentTile.tileSource != Settings.shared.tileSource{
                        //print("changing overlay tile")
                        let tile = MapTile(zoom: zoom, x: newTileX, y: newTileY, tileSource: overlaySource)
                        TileProvider.shared.getTileImage(tile: tile){ success in
                            if !success{
                                self.tilesLoaded = false
                                Log.error("TileLayerView could not load overlay tile \(tile.shortDescription)")
                            }
                        }
                        overlayGrid[y][x] = tile
                    }
                }
                else{
                    overlayGrid[y][x] = MapTile.dummyTile
                }
            }
        }
    }
    
    func getTile(x: Int, y: Int) -> MapTile?{
        guard x >= 0 && x < tileGrid[0].count && y >= 0 && y < tileGrid.count else {
            print("out of range: \(x), \(y)")
            return nil }
        return tileGrid[y][x]
    }
    
    func getOverlayTile(x: Int, y: Int) -> MapTile?{
        guard x >= 0 && x < overlayGrid[0].count && y >= 0 && y < overlayGrid.count else {
            print("out of range: \(x), \(y)")
            return nil }
        return overlayGrid[y][x]
    }
    
    func updateCurrentLocationOffset(){
        if let coordinate = currentCoordinate{
            let scaledWorldX = World.scaledX(coordinate.longitude, downScale: downScaleFromWorld)
            let scaledWorldY = World.scaledY(coordinate.latitude, downScale: downScaleFromWorld)
            let xOffset = scaledWorldCenterX - scaledWorldX
            let yOffset = scaledWorldCenterY - scaledWorldY
            currentLocationOffset = CGSize(width: -xOffset, height: -yOffset)
        }
    }
    
    func moveBy(offset: CGSize){
        scaledWorldCenterX -= offset.width
        scaledWorldCenterY -= offset.height
        setCenterCoordinate(World.coordinate(scaledX: scaledWorldCenterX, scaledY: scaledWorldCenterY, downScale: downScaleFromWorld))
        //print("moving to coordinate \(centerCoordinate)")
        updateCurrentLocationOffset()
        updateTiles()
    }
    
    func zoomTo(_ zoom: Int){
        if zoom <= World.maxZoom, zoom >= 0{
            self.zoom = zoom
            updateWorldValues()
            updateCurrentLocationOffset()
            updateTiles()
        }
    }
    
    func zoomIn(){
        zoomTo(zoom + 1)
    }
    
    func zoomOut(){
        zoomTo(zoom - 1)
    }
    
    func getScreenPoints(_ mappoints: [Mappoint], size: CGSize) -> [CGPoint]{
        updateWorldValues()
        var points = [CGPoint]()
        let originX: Double = scaledWorldCenterX - size.width/2.0
        let originY: Double = scaledWorldCenterY - size.height/2.0
        for point in mappoints{
            let pnt = World.scaledPoint(point.coordinate, downScale: downScaleFromWorld)
            let cgpnt = CGPoint(x: pnt.x - originX, y: pnt.y - originY)
            points.append(cgpnt)
        }
        return points
    }
    
}

extension WatchMapStatus: LocationServiceDelegate{
    
    func locationChanged(to location: CLLocation) {
        //Log.debug("locationChanged to \(location.coordinate)")
        self.setCurrentCoordinate(location.coordinate)
        if Settings.shared.followLocation {
            self.setCenterCoordinate(location.coordinate)
            self.updateTiles()
        }
        if Settings.shared.showCurrentLocation {
            self.updateCurrentLocationOffset()
        }
        if TrackRecorder.shared.isRecording {
            TrackRecorder.shared.locationChanged(to: location)
        }
    }
    
    func directionChanged(to direction: CLLocationDirection) {
        if Settings.shared.showDirection {
            self.direction = direction
        }
    }
        
}

typealias MapStatus = WatchMapStatus

