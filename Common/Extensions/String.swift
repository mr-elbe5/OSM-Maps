/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

extension String {
    
    func localize() -> String{
        return NSLocalizedString(self,comment: "")
    }
    
    func localize(table: String) -> String{
        return NSLocalizedString(self,tableName: table, comment: "")
    }
    
    func localize(i: Int) -> String{
        return String(format: NSLocalizedString(self,comment: ""), String(i))
    }
    
    func localize(table: String, i: Int) -> String{
        return String(format: NSLocalizedString(self,tableName: table, comment: ""), String(i))
    }
    
    func localize(i1: Int, i2: Int) -> String{
        return String(format: NSLocalizedString(self,comment: ""), String(i1), String(i2))
    }
    
    func localize(param1: String, param2: String, param3: String) -> String{
        return String(format: self.localize(), param1, param2, param3)
    }
    
    func localize(s: String) -> String{
        return String(format: NSLocalizedString(self,comment: ""), s)
    }
    
    func localize(param: String) -> String{
        return String(format: self.localize(), param)
    }
    
    func localize(param1: String, param2: String) -> String{
        return String(format: self.localize(), param1, param2)
    }
    
    func localizeAsMandatory() -> String{
        return String(format: NSLocalizedString(self,comment: "")) + " *"
    }
    
    func localizeWithColon() -> String{
        return localize() + ": "
    }
    
    func localizeWithColonAsMandatory() -> String{
        return localize() + ":* "
    }

    func trim() -> String{
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func removeTimeStringMilliseconds() -> String{
        if self.hasSuffix("Z"), let idx = self.lastIndex(of: "."){
            return self[self.startIndex ..< idx] + "Z"
        }
        return self
    }
    
    func ISO8601Date() -> Date?{
        ISO8601DateFormatter().date(from: self.removeTimeStringMilliseconds())
    }
    
    func toURL() -> String{
        self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? self
    }
    
    func appendingPathComponent(_ pathComponent: String) -> String{
        self + "/" + pathComponent
    }
    
    func lastPathComponent() -> String{
        if var pos = lastIndex(of: "/")    {
            pos = index(after: pos)
            return String(self[pos..<endIndex])
        }
        return self
    }

    func pathExtension() -> String {
        if let idx = index(of: ".", from: startIndex) {
            return String(self[index(after: idx)..<endIndex])
        }
        return self
    }

    func pathWithoutExtension() -> String {
        if let idx = index(of: ".", from: startIndex) {
            return String(self[startIndex..<idx])
        }
        return self
    }

}
