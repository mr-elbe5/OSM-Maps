/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import WatchKit
import WatchConnectivity

@Observable class PhoneConnector: NSObject {
    
    enum ConnectionState: String {
        case connectionNotTested
        case connectionEstablished
        case connectionFailed
    }
    
    static var shared = PhoneConnector()
    
    var connectionState: ConnectionState = .connectionNotTested
    
    var session: WCSession?
    
    override init() {
        if WCSession.isSupported() {
            session = WCSession.default
            super.init()
            session?.delegate = self
            session?.activate()
        }
        else{
            session = nil
            super.init()
        }
    }
    
    func requestConnection() {
        //Log.debug("sending connection request")
        let request = ["request": "connection"]
        session?.sendMessage(
            request,
            replyHandler: { response in
                //Log.debug("Received response \(response)")
                DispatchQueue.main.async {
                    let result = response["connected"] as? Bool ?? false
                    self.connectionState = result ? .connectionEstablished : .connectionFailed
                }
            },
            errorHandler: { error in
                Log.error("Error sending message:", error)
                self.connectionState = .connectionFailed
            }
        )
    }
    
    func saveTrack(json: String, completion: @escaping (Bool) -> Void) {
        //Log.info("watch saving track")
        let request = ["request": "saveTrack", "json": json] as [String : Any]
        session?.sendMessage(
            request,
            replyHandler: { response in
                DispatchQueue.main.async {
                    if let success = response["success"] as? Bool {
                        if success {
                            //Log.info("track saved on phone")
                            completion(true)
                        }
                        else{
                            Log.error("track not saved on phone")
                            completion(false)
                        }
                    }
                    else{
                        completion(false)
                    }
                }
            },
            errorHandler: { error in
                Log.error("Error sending message:", error)
                completion(false)
            }
        )
    }
}

extension PhoneConnector: WCSessionDelegate {
    func session(_: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Log.debug("activationDidCompleteWith activationState:\(activationState.rawValue), error: \(String(describing: error))")
    }
    
    func session(_: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        Log.error("didReceiveMessage: \(message["request"] as? String ?? "")")
        if let request = message["request"] as? String {
            switch request {
            case "tileUpload":
                let zoom = message["zoom"] as? Int ?? 0
                let x = message["x"] as? Int ?? 0
                let y = message["y"] as? Int ?? 0
                if let data = message["data"] as? Data{
                    let tile = MapTile(zoom: zoom, x: x, y: y)
                    tile.imageData = data
                    if FileManager.default.fileExists(atPath: tile.fileUrl.path()){
                        FileManager.default.deleteFile(url: tile.fileUrl)
                    }
                    if FileManager.default.saveFile(data: data, url: tile.fileUrl){
                        Log.error("file \(tile.fileUrl.lastPathComponent) received from phone")
                        replyHandler(["success": true])
                    }
                    else{
                        Log.error("could not save file \(tile.fileUrl.lastPathComponent)")
                        replyHandler(["success": false])
                    }
                }
                else{
                    replyHandler(["success": false])
                }
            case "routeUpload":
                if let json = message["json"] as? String, let route:Route = Route.fromJSON(encoded: json){
                    RouteStatus.shared.setRoute(route)
                    replyHandler(["success": true])
                }
                else{
                    replyHandler(["success": false])
                }
            case "missingTiles":
                if let data = message["data"] as? Data, let tiles = try? JSONDecoder().decode(MapTileDataList.self, from: data){
                    var result = MapTileDataList()
                    for tileData in tiles{
                        if !tileData.exists {
                            result.append(tileData)
                        }
                    }
                    if let response = try? JSONEncoder().encode(result){
                        replyHandler(["success": true, "data" : response as Any])
                    }
                    else{
                        replyHandler(["success": false])
                    }
                }
                else{
                    replyHandler(["success": false])
                }
            default:
                break
            }
        }
        
    }
}

