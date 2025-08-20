/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

protocol DateFilterDelegate{
    func dateFilterDidChange()
}

class DateFilterView : UIView{
    
    private var minDateCheckbox = Checkbox()
    private var minDatePicker = UIDatePicker()
    private var maxDateCheckbox = Checkbox()
    private var maxDatePicker = UIDatePicker()
    
    var delegate : DateFilterDelegate? = nil
    
    var minDate : Date? {
        minDateCheckbox.isOn ? minDatePicker.date : nil
    }
    
    var maxDate : Date? {
        maxDateCheckbox.isOn ? maxDatePicker.date : nil
    }
    
    init(){
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(minLabelText: String, maxLabelText: String, minDate : Date? = nil, maxDate : Date? = nil){
        let topLine = UIView()
        addSubviewBelow(topLine, insets: .zero)
        
        minDatePicker.timeZone = .none
        if let date = minDate{
            minDatePicker.date = date
        } else{
            minDatePicker.date = Date()
        }
        minDatePicker.minimumDate = nil
        minDatePicker.maximumDate = Date()
        minDatePicker.datePickerMode = .date
        minDatePicker.addAction(UIAction(){ action in
            self.delegate?.dateFilterDidChange()
        }, for: .valueChanged)
        topLine.addSubviewToLeft(minDatePicker, insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15))
        minDatePicker.isHidden = minDate == nil
        minDateCheckbox.setup(title: minLabelText, index: 0, isOn: minDate != nil)
        minDateCheckbox.delegate = self
        topLine.addSubviewWithAnchors(minDateCheckbox, leading: topLine.leadingAnchor, insets: .zero)
            .centerY(minDatePicker.centerYAnchor)
        
        let bottomLine = UIView()
        addSubviewBelow(bottomLine, upperView: topLine, insets: .zero)
            .connectToBottom(of: self, inset: .zero)
        
        maxDatePicker.timeZone = .none
        if let date = maxDate{
            maxDatePicker.date = date
        } else{
            maxDatePicker.date = Date()
        }
        maxDatePicker.minimumDate = nil
        maxDatePicker.maximumDate = Date()
        maxDatePicker.datePickerMode = .date
        maxDatePicker.addAction(UIAction(){ action in
            self.delegate?.dateFilterDidChange()
        }, for: .valueChanged)
        bottomLine.addSubviewToLeft(maxDatePicker, insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15))
        maxDatePicker.isHidden = maxDate == nil
        maxDateCheckbox.setup(title: maxLabelText, index: 1, isOn: maxDate != nil)
        maxDateCheckbox.delegate = self
        bottomLine.addSubviewWithAnchors(maxDateCheckbox, leading: bottomLine.leadingAnchor, insets: .zero)
            .centerY(maxDatePicker.centerYAnchor)
    }
    
}

extension DateFilterView: CheckboxDelegate{
    
    func checkboxIsSelected(index: Int, value: String) {
        if index == 0 {
            minDatePicker.isHidden = !minDateCheckbox.isOn
            if !minDateCheckbox.isOn{
                minDatePicker.date = Date(year: 2000, month: 1, day: 1)
            }
        }
        else if index == 1 {
            maxDatePicker.isHidden = !maxDateCheckbox.isOn
            if !maxDateCheckbox.isOn{
                maxDatePicker.date = Date()
            }
        }
        self.delegate?.dateFilterDidChange()
    }
    
}

