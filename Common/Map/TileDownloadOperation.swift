/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import OSLog

protocol DownloadDelegate {
    func downloadSucceeded()
    func downloadWithError()
}

class TileDownloadOperation : AsyncOperation, @unchecked Sendable {
    
    var tile : MapTile
    var delegate : DownloadDelegate? = nil
    
    init(tile: MapTile) {
        self.tile = tile
        super.init()
    }
    
    override func startExecution(){
        //debug("TileDownloadOperation starting download of \(tile.shortDescription)")
        TileProvider.shared.loadTileImage(tile: tile){ success in
            if success{
                DispatchQueue.main.async { [self] in
                    delegate?.downloadSucceeded()
                }
            }
            else{
                DispatchQueue.main.async { [self] in
                    //Logger.debug("TileDownloadOperation loading \(tile.shortDescription)")
                    delegate?.downloadWithError()
                }
            }
            self.state = .isFinished
        }
    }
    
}

