/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

extension Date{
    
    static var zero = Date(year: 1970, month: 1, day: 1)
    
    static var utcZone = TimeZone(abbreviation: "UTC")
    
    static var localDate: Date{
        get{
            Date().toLocalDate()
        }
    }
    
    init(year: Int, month: Int, day: Int){
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 0
        components.minute = 0
        components.second = 0
        if let date = Calendar.current.date(from: components){
            self = date
        }
        else{
            self = Date()
        }
    }
    
    func rounded() -> Date{
        let ti = self.timeIntervalSince1970
        return Date(timeIntervalSince1970: ti.rounded())
    }
    
    func toLocalDate() -> Date{
        var secs = self.timeIntervalSince1970
        secs += Double(TimeZone.current.secondsFromGMT())
        return Date(timeIntervalSince1970: secs)
    }
    
    func toUTCDate() -> Date{
        var secs = self.timeIntervalSince1970
        secs -= Double(TimeZone.current.secondsFromGMT())
        return Date(timeIntervalSince1970: secs)
    }
    
    func dateString() -> String{
        DateFormatter.localizedString(from: self.toUTCDate(), dateStyle: .medium, timeStyle: .none)
    }
    
    func simpleDateString() -> String{
            DateFormats.simpleDateFormatter.string(from: self)
        }
    
    func dateTimeString() -> String{
        return DateFormatter.localizedString(from: self.toUTCDate(), dateStyle: .medium, timeStyle: .short)
    }
    
    func longDateTimeString() -> String{
        return DateFormatter.localizedString(from: self.toUTCDate(), dateStyle: .medium, timeStyle: .medium)
    }
    
    func timeString() -> String{
        return DateFormatter.localizedString(from: self.toUTCDate(), dateStyle: .none, timeStyle: .short)
    }
    
    func startOfDay() -> Date{
        var cal = Calendar.current
        cal.timeZone = TimeZone(abbreviation: "UTC")!
        return cal.startOfDay(for: self)
    }
    
    func startOfMonth() -> Date{
        var cal = Calendar.current
        cal.timeZone = TimeZone(abbreviation: "UTC")!
        let components = cal .dateComponents([.month, .year], from: self)
        return cal.date(from: components)!
    }
    
    func timestampString() -> String{
        return DateFormats.timestampFormatter.string(from: self)
    }
    
    func fileDate() -> String{
        return DateFormats.fileDateFormatter.string(from: self)
    }
    
    func shortFileDate() -> String{
        return DateFormats.shortFileDateFormatter.string(from: self)
    }
    
    func isoString() -> String{
        return DateFormats.isoFormatter.string(from: self)
    }
 
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    var exifString : String{
        DateFormats.exifDateFormatter.string(from: self)
    }

    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }

}

class DateFormats{
    
    static var timestampFormatter : DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }
    
    static var simpleDateFormatter : DateFormatter{
            let dateFormatter = DateFormatter()
        dateFormatter.timeZone = Date.utcZone
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter
        }
    
    static var fileDateFormatter : DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = Date.utcZone
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        return dateFormatter
    }
    
    static var shortFileDateFormatter : DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = Date.utcZone
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm"
        return dateFormatter
    }
    
    static var isoFormatter : ISO8601DateFormatter{
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withFullTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        return dateFormatter
    }
    
    static var exifDateFormatter : DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = Date.utcZone
        dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        return dateFormatter
    }
    
    static var iptcDateFormatter : DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = Date.utcZone
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter
    }
    
    static var iptcTimeFormatter : DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = Date.utcZone
        dateFormatter.dateFormat = "HHmmss"
        return dateFormatter
    }
    
}

