/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

extension Date{
    
    static var zero = Date(year: 1970, month: 1, day: 1)
    
    var dateString: String{
        DateFormatter.localizedString(from: self, dateStyle: .medium, timeStyle: .none)
    }
    
    var simpleDateString: String{
        DateFormats.simpleDateFormatter.string(from: self)
    }
    
    var dateTimeString: String{
        DateFormatter.localizedString(from: self, dateStyle: .medium, timeStyle: .short)
    }
    
    var longDateTimeString: String{
        DateFormatter.localizedString(from: self, dateStyle: .medium, timeStyle: .medium)
    }
    
    var timeString: String{
        DateFormatter.localizedString(from: self, dateStyle: .none, timeStyle: .short)
    }
    
    var startOfUTCDay: Date{
        startOfDay(timeZone: .gmt)
    }
    
    var startOfUTCMonth: Date{
        startOfMonth(timeZone: .gmt)
    }
    
    var rounded: Date{
        let ti = self.timeIntervalSince1970
        return Date(timeIntervalSince1970: ti.rounded())
    }
    
    var fileNameString: String{
        return DateFormats.fileDateFormatter.string(from: self)
    }
    
    var isoString: String{
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
    
    func startOfDay(timeZone: TimeZone = .current) -> Date{
        var cal = Calendar.current
        cal.timeZone = timeZone
        return cal.startOfDay(for: self)
    }
    
    func startOfMonth(timeZone: TimeZone = .current) -> Date{
        var cal = Calendar.current
        cal.timeZone = timeZone
        let components = cal .dateComponents([.month, .year], from: self)
        return cal.date(from: components)!
    }
    
    func fromUTCDate(offset: UTCOffset = UTCOffset.current) -> Date{
        self.addingTimeInterval(Double(offset.value))
    }
    
    func toUTCDate(offset: UTCOffset = UTCOffset.current) -> Date{
        self.addingTimeInterval(-Double(offset.value))
    }

}

class DateFormats{
    
    static var simpleDateFormatter : DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    
    static var fileDateFormatter : DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        return dateFormatter
    }
    
    static var isoFormatter : ISO8601DateFormatter{
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withFullTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        return dateFormatter
    }
    
    static var exifDateFormatter : DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        return dateFormatter
    }
    
    static var iptcDateFormatter : DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter
    }
    
    static var iptcTimeFormatter : DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HHmmss"
        return dateFormatter
    }
    
}

