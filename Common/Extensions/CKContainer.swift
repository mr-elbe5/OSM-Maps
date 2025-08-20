/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit

extension CKContainer{
    
    static var osmMapsContainerName = "iCloud.OSMMaps"
    static var zoneName = "osmzone"
    static var zoneID = CKRecordZone.ID(zoneName: zoneName)
    
    static var container = CKContainer(identifier: osmMapsContainerName)
    static var privateDatabase = container.privateCloudDatabase
    
    static func isConnected() async throws -> Bool{
        let status = try await container.accountStatus()
        Log.info("iCloud account status = \(status == .available ? "connected" : "disconnected")")
        return status == .available
    }
    
}
