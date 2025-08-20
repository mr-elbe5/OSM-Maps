/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

extension StringProtocol{

    func indexOf(_ str: String) -> String.Index? {
        self.range(of: str, options: .literal)?.lowerBound
    }

    func lastIndexOf(_ str: String) -> String.Index? {
        self.range(of: str, options: .backwards)?.lowerBound
    }

    func index(of string: String, from: Index) -> Index? {
        range(of: string, options: [], range: from..<endIndex, locale: nil)?.lowerBound
    }

    func charAt(_ i: Int) -> Character{
        let idx = self.index(startIndex, offsetBy: i)
        return self[idx]
    }

    func substr(_ from: Int,_ to:Int, includeLast : Bool = false) -> String{
        if to + (includeLast ? 1 : 0) < from{
            return ""
        }
        let start = self.index(startIndex, offsetBy: from)
        let end = self.index(start, offsetBy: to - from)
        return includeLast ? String(self[start...end]) : String(self[start..<end])
    }
    
    func substr(_ from: Int) -> String{
        let start = self.index(startIndex, offsetBy: from)
        return String(self[start...])
    }
    
    func endOfLines() -> Array<Int>{
        var eols = Array<Int>()
        for (index, char) in self.enumerated() {
            if char == "\n"{
                eols.append(index)
            }
        }
        return eols
    }
    
    func substr(lines: Int) -> String{
        let eols = endOfLines()
        if eols.count > lines{
            return substr(eols[eols.count - lines])
        }
        return String(self)
    }

    func trim() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func unquote() -> String {
        trimmingCharacters(in: ["\""])
    }

    // tag format extensions

    func toHtml() -> String {
        var result = ""
        for ch in self {
            switch ch {
            case "\"": result.append("&quot;")
            case "'": result.append("&apos;")
            case "&": result.append("&amp;")
            case "<": result.append("&lt;")
            case ">": result.append("&gt;")
            default: result.append(ch)
            }
        }
        return result
    }

    func toHtmlMultiline() -> String {
        toHtml().replacingOccurrences(of: "\n", with: "<br/>\n")
    }

    func toUri() -> String {
        var result = ""
        var code = ""
        for ch in self {
            switch ch{
            case "$" : code = "%24"
            case "&" : code = "%26"
            case ":" : code = "%3A"
            case ";" : code = "%3B"
            case "=" : code = "%3D"
            case "?" : code = "%3F"
            case "@" : code = "%40"
            case " " : code = "%20"
            case "\"" : code = "%5C"
            case "<" : code = "%3C"
            case ">" : code = "%3E"
            case "#" : code = "%23"
            case "%" : code = "%25"
            case "~" : code = "%7E"
            case "|" : code = "%7C"
            case "^" : code = "%5E"
            case "[" : code = "%5B"
            case "]" : code = "%5D"
            default: code = ""
            }
            if !code.isEmpty {
                result.append(code)
            }
            else{
                result.append(ch)
            }
        }
        return result
    }

    func toXml() -> String {
        var result = ""
        for ch in self {
            switch ch {
            case "\"": result.append("&quot;")
            case "'": result.append("&apos;")
            case "&": result.append("&amp;")
            case "<": result.append("&lt;")
            case ">": result.append("&gt;")
            default: result.append(ch)
            }
        }
        return result
    }

}
