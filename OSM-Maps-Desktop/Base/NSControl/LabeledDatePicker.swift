/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import AppKit

protocol DatePickerDelegate{
    func dateValueDidChange(sender: LabeledDatePicker,date: Date?)
}

class LabeledDatePicker : NSView{
    
    private var label = NSTextField(labelWithString: "")
    private var datePicker = NSDatePicker()
    
    var delegate : DatePickerDelegate? = nil
    
    var date : Date? {
        datePicker.dateValue
    }
    
    var mode: NSDatePicker.Mode{
        get{
            datePicker.datePickerMode
        }
        set{
            datePicker.datePickerMode = newValue
        }
    }
    
    func setupView(labelText: String, date : Date?, minimumDate : Date? = nil){
        label.stringValue = labelText
        addSubview(label)
        datePicker.timeZone = .none
        if let date = date{
            datePicker.dateValue = date
        } else{
            datePicker.dateValue = Date.localDate
        }
        datePicker.minDate = minimumDate
        datePicker.maxDate = Date.localDate
        datePicker.datePickerMode = .single
        datePicker.target = self
        datePicker.action = #selector(dateValueDidChange)
        addSubview(datePicker)
        label.setAnchors(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, insets: OSInsets.defaultInsets)
        datePicker.setAnchors(top: topAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: OSInsets.defaultInsets)
    }
    
    @objc func dateValueDidChange(){
        delegate?.dateValueDidChange(sender: self,date: datePicker.dateValue)
    }
    
}

