/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import WatchConnectivity

class WatchConnector: NSObject {
    
    static var shared = WatchConnector()
    
    var session = WCSession.default

    override init() {
        super.init()
        session.delegate = self
    }
    
    func start(){
        session.activate()
    }
    
    var isWatchConnected: Bool {
        session.isWatchAppInstalled && session.isPaired && session.activationState == .activated
    }
    
    func sendTile(_ tile: MapTile, data: Data, completion: @escaping (Bool) -> Void) {
        //Log.debug("sending tile")
        if !isWatchConnected {
            Log.error("not connected to phone")
            completion(false)
            return
        }
        session.sendMessage([
            "request": "tileUpload",
            "zoom": tile.zoom,
            "x": tile.x,
            "y": tile.y,
            "data": data as Any
        ], replyHandler: {response in
            DispatchQueue.main.async {
                if let success = response["success"] as? Bool {
                    completion(success)
                }
                else{
                    completion(false)
                }
            }
        }) { error in
            Log.error("error sending tile: \(error)")
        }
    }
    
    func sendRoute(_ route: Route, completion: @escaping (Bool) -> Void) {
        Log.debug("sending route")
        if !isWatchConnected {
            Log.error("not connected to phone")
            completion(false)
            return
        }
        let json = route.toJSON()
        session.sendMessage([
            "request": "routeUpload",
            "json": json as Any
        ], replyHandler: {response in
            DispatchQueue.main.async {
                if let success = response["success"] as? Bool {
                    completion(success)
                }
                else{
                    completion(false)
                }
            }
        }) { error in
            Log.error("error sending route: \(error)")
        }
    }
    
    func sendTileSources(completion: @escaping (Bool) -> Void){
        Log.debug("sending tile sources")
        if !isWatchConnected {
            Log.error("not connected to phone")
            completion(false)
            return
        }
        let tileJson = TileSources.shared.toJSON()
        let overlayJson = TileSources.sharedOverlays.toJSON()
        session.sendMessage([
            "request": "tileSourcesUpload",
            "tileJson": tileJson as Any,
            "overlayJson": overlayJson as Any
        ], replyHandler: {response in
            DispatchQueue.main.async {
                if let success = response["success"] as? Bool {
                    completion(success)
                }
                else{
                    completion(false)
                }
            }
        }) { error in
            Log.error("error sending tileSources: \(error)")
        }
    }
    
    func checkTiles(_ tiles: MapTileDataList, completion: @escaping (MapTileDataList?) -> Void) {
        Log.debug("checking tiles")
        if !isWatchConnected {
            Log.error("not connected to phone")
            completion(nil)
            return
        }
        if let data = try? JSONEncoder().encode(tiles){
            session.sendMessage([
                "request": "missingTiles",
                "data": data as Any
            ], replyHandler: {response in
                DispatchQueue.main.async {
                    if let success = response["success"] as? Bool, success{
                        if let data = response["data"] as? Data {
                            if let tilesData = try? JSONDecoder().decode(MapTileDataList.self, from: data){
                                completion(tilesData)
                            }
                            else{
                                completion(nil)
                            }
                        }
                        else{
                            completion(nil)
                        }
                    }
                    else{
                        completion(nil)
                    }
                }
            }) { error in
                Log.error("error checking tiles: \(error)")
                completion(nil)
            }
        }
        else{
            Log.error("could not encode tiles")
            completion(nil)
        }
    }
}

extension WatchConnector: WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error{
            Log.error("Watch session failed with:\(String(describing: error))")
            return
        }
        Log.debug("Watch session is paired: \(session.isPaired)")
        Log.debug("Watch session is activated: \(session.activationState == .activated)")
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        Log.debug("Watch session reachability is: \(session.isReachable)")
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        Log.debug("sessionDidBecomeInactive: \(session)")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        Log.debug("sessionDidDeactivate: \(session)")
    }

    func session(_: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        //Log.debug("didReceiveMessage: \(message)")
        if let request = message["request"] as? String {
            switch request {
            case "connection":
                //Log.debug("got connection request")
                replyHandler(["connected": true as Any])
            case "saveTrack":
                Log.debug("receiving track from watch")
                if let json = message["json"] as? String, let track = createTrack(json: json){
                    let item = TrackItem(track: track)
                    AppData.shared.addItem(item)
                    AppData.shared.save()
                    //Log.debug("saved track on phone")
                    replyHandler(["success": true as Any])
                }
                else{
                    replyHandler(["success": false as Any])
                }
            default:
                break
            }
        }
        
        func createTrack(json: String) -> Track?{
            if let data =  json.data(using: .utf8){
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                do{
                    let track: Track = try decoder.decode(Track.self, from : data)
                    if track.trackpoints.isEmpty{
                        return nil
                    }
                    track.updateFromTrackpoints()
                    track.setNameByDate()
                    return track
                }
                catch (let err){
                    Log.error(err.localizedDescription)
                }
            }
            return nil
        }
    }
        
}

