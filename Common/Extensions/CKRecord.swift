/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit

extension CKRecord{
    
    var json: String?{
        value(forKey: "json") as? String
    }
    
    //all records created with uuid
    var uuid: UUID{
        return UUID(uuidString: self.recordID.recordName)!
    }
    
    var itemType: String?{
        value(forKey: "itemType") as? String
    }
    
    var version: Int{
        Int(value(forKey: "version") as? Int64 ?? 0)
    }
    
    func changeDate() -> Date?{
        (value(forKey: "changeDate") as? Date)?.rounded
    }
    
    func file() -> CKAsset?{
        value(forKey: "file") as? CKAsset
    }
    
}

extension CKRecord.ID{
    
    convenience init(uuid: UUID){
        self.init(recordName: uuid.uuidString, zoneID: CKContainer.zoneID)
    }
    
    func isFromUUID(_ uuid: UUID) -> Bool{
        return self.recordName == uuid.uuidString
    }
    
}
