/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import WatchKit
import OSLog

@Observable class WatchMapStatus: NSObject{
    
    static var shared = WatchMapStatus()
    
    var currentCoordinate: CLLocationCoordinate2D = MapDefaults.startLocation.coordinate
    var centerCoordinate: CLLocationCoordinate2D = MapDefaults.startLocation.coordinate
    var direction: CLLocationDirection = 0
    
    var screenSize = WKInterfaceDevice.current().screenBounds
    let tileExtent: CGFloat = World.tileExtent
    var gridWidth: Int = 1
    var gridHeight: Int = 1
    var mainGrid = TileArea()
    var overlayGrids = Array<TileArea>()
    
    var centerTile: Tile = .zero
    var tileOffset: CGPoint = .zero
    
    var zoom: Int = MapDefaults.startZoom
    
    var downScaleFromWorld: Double{
        World.downScale(to: zoom)
    }
    
    var tilesLoaded = false
    
    // tile 16/34530/21183
    
    override init(){
        super.init()
        currentCoordinate = LocationStatus.shared.coordinate
        setCenterCoordinate(to: LocationStatus.shared.coordinate)
        gridWidth = 2 * (Int(floor(screenSize.width/2 / tileExtent)) + 2) + 1
        gridHeight = 2 * (Int(floor(screenSize.height/2 / tileExtent)) + 2) + 1
        Logger.debug("grid size = \(gridWidth) x \(gridHeight)")
        setupMainGrid()
        updateMainGrid()
        setupOverlayGrids()
        //updateOverlayGrids()
    }
    
    func setupMainGrid(){
        mainGrid = TileArea()
        for _ : Int in 0..<gridHeight{
            var line = TileList()
            for _ : Int in 0..<gridWidth{
                line.append(.zero)
            }
            mainGrid.append(line);
        }
        print("created main grid: \(mainGrid[0].count) x \(mainGrid.count)")
    }
    
    func setupOverlayGrids(){
        overlayGrids.removeAll()
        for _ : Int in 0..<Settings.shared.overlayTileSources.count{
            var grid = TileArea()
            for _ : Int in 0..<gridHeight{
                var line = TileList()
                for _ : Int in 0..<gridWidth{
                    line.append(.zero)
                }
                grid.append(line);
            }
            overlayGrids.append(grid)
        }
    }
    
    func updateMainGrid(){
        print("updating grid")
        print("centerTile = \(centerTile.asString)")
        updateGrid(grid: mainGrid, tileSource: Settings.shared.tileSource)
    }
    
    func updateOverlayGrids(){
        for i:Int in 0..<overlayGrids.count{
            let grid = overlayGrids[i]
            updateGrid(grid: grid, tileSource: Settings.shared.overlayTileSources[i])
        }
    }
    
    private func updateGrid(grid: TileArea, tileSource: TileSource){
        print("updating overlay grid")
        let leftTileX = centerTile.x - (gridHeight - 1)/2
        let topTileY = centerTile.y - (gridHeight - 1)/2
        for y in 0..<gridHeight {
            for x in 0..<gridWidth {
                let tile = getTile(x: x, y: y)
                tile.change(zoom: zoom, x: leftTileX + x, y: topTileY + y, tileSource: tileSource)
                print("changed tile \(tile.asString)")
                TileProvider.shared.getTileImage(tile: tile){ success in
                    if !success{
                        print("could not load tile \(tile.asString)")
                    }
                }
            }
        }
    }
    
    func setCenterCoordinate(_ coordinate: CLLocationCoordinate2D){
        self.centerCoordinate = coordinate
        
    }
    
    private func setCurrentCoordinate(_ coordinate: CLLocationCoordinate2D){
        self.currentCoordinate = coordinate
        
    }
    
    func updateTiles(){
        /*let centerTileLeft = scaledWorldCenterX - tileExtent/2
        let centerTileTop = scaledWorldCenterY - tileExtent/2
        centerTileX = Int(floor(centerTileLeft / tileExtent))
        centerTileY = Int(floor(centerTileTop / tileExtent))
        print("centerTile \(centerTileX), \(centerTileY)")
        
        // diff of tile edge to center plus offset to tile center
        tileOffsetX = (Double(centerTileX)*tileExtent - scaledWorldCenterX + tileExtent/2)
        tileOffsetY = (Double(centerTileY)*tileExtent - scaledWorldCenterY + tileExtent/2)
        //print("offset: \(tileOffsetX),\(tileOffsetY)")
        setupGrid()*/
    }
    
    func refresh(){
        setupMainGrid()
    }
    
    func getTile(x: Int, y: Int) -> Tile{
        if y < 0 || y > mainGrid.count - 1{
            return .zero
        }
        if x < 0 || x > mainGrid[0].count - 1{
            return .zero
        }
        return mainGrid[y][x]
    }
    
    func getOverlayTile(idx: Int, x: Int, y: Int) -> Tile{
        let overlayGrid = overlayGrids[idx]
        return overlayGrid[y][x]
    }
    
    /*func moveBy(offset: CGSize){
        //print("center coordinate before is \(centerCoordinate.asString)")
        //print("offset is \(offset)")
        let scale = downScaleFromWorld
        let centerX = World.scaledX(centerCoordinate.longitude, downScale: scale)
        let scaledX = centerX - offset.width
        let centerY = World.scaledY(centerCoordinate.latitude, downScale: scale)
        let scaledY = centerY - offset.height
        centerCoordinate = World.coordinate(scaledX: scaledX, scaledY: scaledY, downScale: scale)
        //print("center coordinate after is \(centerCoordinate.asString)")
        
        setupGrid()
    }*/
    
    func moveCenter(by offset: CGSize){
        let scale = World.downScale(to: zoom)
        var centerPoint = World.scaledPoint(centerCoordinate, downScale: scale)
        centerPoint = CGPoint(x: centerPoint.x - offset.width, y: centerPoint.y - offset.height)
        let coordinate = World.coordinate(scaledPoint: centerPoint, downScale: scale)
        setCenterCoordinate(to: coordinate)
    }
    
    func setCenterCoordinate(to coordinate: CLLocationCoordinate2D){
        let oldCenterTile = centerTile
        //print("old CenterTile is \(oldCenterTile.asString)")
        //print("moving center from \(centerCoordinate.asLongString) to \(coordinate.asLongString)")
        centerCoordinate = coordinate
        setCenterTile()
        //print("new centerTile is \(centerTile.asString)")
        //print("new offset is \(tileOffset)")
        if oldCenterTile != centerTile{
            print("----- new center tile")
            updateMainGrid()
        }
    }
    
    func setCenterTile(){
        let centerPoint = World.scaledPoint(centerCoordinate, downScale: downScaleFromWorld)
        let tileX = Int(floor((centerPoint.x - tileExtent/2) / tileExtent))
        let tileY = Int(floor((centerPoint.y - tileExtent/2) / tileExtent))
        centerTile = Tile(zoom: zoom, x: tileX, y: tileY)
        let centerX = (Double(centerTile.x)*tileExtent + tileExtent/2)
        let centerY = (Double(centerTile.y)*tileExtent + tileExtent/2)
        tileOffset = CGPoint(x: centerX - centerPoint.x, y: centerY - centerPoint.y)
        updateMainGrid()
        updateOverlayGrids()
    }
    
    func zoomTo(_ zoom: Int){
        if zoom <= World.maxZoom, zoom >= 0{
            self.zoom = zoom
            print("updating tiles at zoom \(zoom)")
            updateTiles()
        }
    }
    
    func zoomIn(){
        if zoom < World.maxZoom{
            print("zooming in to \(zoom + 1)")
            zoomTo(zoom + 1)
        }
    }
    
    func zoomOut(){
        if zoom > 0{
            print("zooming out to \(zoom - 1)")
            zoomTo(zoom - 1)
        }
    }
    
    func getScreenPoints(_ mappoints: [Mappoint], size: CGSize) -> [CGPoint]{
        var points = [CGPoint]()
        let centerPoint = World.scaledPoint(centerCoordinate, downScale: downScaleFromWorld)
        let originX: Double = centerPoint.x - size.width/2.0
        let originY: Double = centerPoint.y - size.height/2.0
        for point in mappoints{
            let pnt = World.scaledPoint(point.coordinate, downScale: downScaleFromWorld)
            let cgpnt = CGPoint(x: pnt.x - originX, y: pnt.y - originY)
            points.append(cgpnt)
        }
        return points
    }
    
    func checkStatus(){
        /*print("center coordinate is \(centerCoordinate.asString)")
        print("zoom is \(zoom)")
        print("center tile is \(centerTile.asString)")
        print("tile images:")
        for y in 0..<gridHeight{
            let line = tileGrid[y]
            for x in 0..<gridWidth {
                let tile = line[x]
                print("\(x),\(y): \(tile.shortDescription): \(tile.imageData != nil)")
            }
        }*/
    }
    
}

extension WatchMapStatus: LocationServiceDelegate{
    
    func locationChanged(to location: CLLocation) {
        //Logger.debug("locationChanged to \(location.coordinate)")
        self.setCurrentCoordinate(location.coordinate)
        if Settings.shared.followLocation {
            self.setCenterCoordinate(location.coordinate)
            self.updateTiles()
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

