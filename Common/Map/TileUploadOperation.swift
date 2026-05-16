/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import Combine
import OSLog

protocol UploadDelegate {
    func uploadSucceeded()
    func uploadWithError()
}

class TileUploadOperation : AsyncOperation, @unchecked Sendable {
    
    var tile : MapTile
    var data : Data
    var delegate : UploadDelegate? = nil
    
    init(tile: MapTile, data: Data) {
        self.tile = tile
        self.data = data
        super.init()
    }
    
    override func startExecution(){
        //Logger.debug("TileUploadOperation starting upload of \(tile.shortDescription)")
        WatchConnector.shared.sendTile(tile, data: data){ success in
            if success{
                DispatchQueue.main.async { [self] in
                    //Logger.debug("TileUploadOperation succeeded")
                    delegate?.uploadSucceeded()
                }
            }
            else{
                DispatchQueue.main.async { [self] in
                    //Logger.debug("TileUploadOperation uploading \(tile.shortDescription)")
                    delegate?.uploadWithError()
                }
            }
            self.state = .isFinished
        }
    }
    
}

