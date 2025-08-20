/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

protocol DatePickerDelegate{
    func dateValueDidChange(sender: LabeledDatePicker,date: Date?)
}

class LabeledDatePicker : UIView{
    
    private var label = UILabel()
    private var datePicker = UIDatePicker()
    
    var delegate : DatePickerDelegate? = nil
    
    var date : Date? {
        datePicker.date
    }
    
    var mode: UIDatePicker.Mode{
        get{
            datePicker.datePickerMode
        }
        set{
            datePicker.datePickerMode = newValue
        }
    }
    
    func setupView(labelText: String, date : Date?, minimumDate : Date? = nil){
        label.text = labelText
        addSubview(label)
        datePicker.timeZone = .none
        if let date = date{
            datePicker.date = date
        } else{
            datePicker.date = Date.localDate
        }
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = Date.localDate
        datePicker.datePickerMode = .date
        datePicker.addAction(UIAction(){ action in
            self.delegate?.dateValueDidChange(sender: self,date: self.datePicker.date)
        }, for: .valueChanged)
        addSubview(datePicker)
        label.setAnchors(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, insets: OSInsets.defaultInsets)
        datePicker.setAnchors(top: topAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: OSInsets.defaultInsets)
    }
    
}

