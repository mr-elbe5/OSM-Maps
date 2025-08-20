/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import AppKit

protocol DateFilterDelegate{
    func dateFilterDidChange()
}

class DateFilterView : NSView{
    
    private var minDateCheckbox = Checkbox()
    private var minDatePicker = NSDatePicker()
    private var maxDateCheckbox = Checkbox()
    private var maxDatePicker = NSDatePicker()
    
    var delegate : DateFilterDelegate? = nil
    
    var minDate : Date? {
        minDateCheckbox.isOn ? minDatePicker.dateValue : nil
    }
    
    var maxDate : Date? {
        maxDateCheckbox.isOn ? maxDatePicker.dateValue : nil
    }
    
    init(){
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func withColor(_ color: NSColor) -> DateFilterView {
        minDateCheckbox.withColor(color)
        maxDateCheckbox.withIconColor(color)
        return self
    }
    
    func setupView(minLabelText: String, maxLabelText: String, minDate : Date? = nil, maxDate : Date? = nil){
        let topLine = NSView()
        addSubviewBelow(topLine, insets: .zero)
        
        minDatePicker.timeZone = .none
        if let date = minDate{
            minDatePicker.dateValue = date
        } else{
            minDatePicker.dateValue = Date().startOfDay()
        }
        minDatePicker.minDate = nil
        minDatePicker.maxDate = Date()
        minDatePicker.datePickerMode = .single
        minDatePicker.datePickerStyle = .textFieldAndStepper
        minDatePicker.action = #selector(dateFilterDidChange)
        topLine.addSubviewToLeft(minDatePicker, insets: .zero)
        minDatePicker.isHidden = minDate == nil
        minDateCheckbox.setup(title: minLabelText, index: 0, isOn: minDate != nil)
        minDateCheckbox.delegate = self
        topLine.addSubviewWithAnchors(minDateCheckbox, leading: topLine.leadingAnchor, insets: .zero)
            .centerY(minDatePicker.centerYAnchor)
        
        let bottomLine = NSView()
        addSubviewBelow(bottomLine, upperView: topLine, insets: NSEdgeInsets(top: OSInsets.defaultInset, left: 0, bottom: 0, right: 0))
            .connectToBottom(of: self, inset: .zero)
        
        maxDatePicker.timeZone = .none
        if let date = maxDate{
            maxDatePicker.dateValue = date
        } else{
            maxDatePicker.dateValue = Date().startOfDay()
        }
        maxDatePicker.minDate = nil
        maxDatePicker.maxDate = Date()
        maxDatePicker.datePickerMode = .single
        maxDatePicker.datePickerStyle = .textFieldAndStepper
        maxDatePicker.action = #selector(dateFilterDidChange)
        bottomLine.addSubviewToLeft(maxDatePicker, insets: .zero)
        maxDatePicker.isHidden = maxDate == nil
        maxDateCheckbox.setup(title: maxLabelText, index: 1, isOn: maxDate != nil)
        maxDateCheckbox.delegate = self
        bottomLine.addSubviewWithAnchors(maxDateCheckbox, leading: bottomLine.leadingAnchor, insets: .zero)
            .centerY(maxDatePicker.centerYAnchor)
    }
    
    @objc func dateFilterDidChange(){
        delegate?.dateFilterDidChange()
    }
    
}

extension DateFilterView: CheckboxDelegate{
    
    func checkboxIsSelected(index: Int, value: String) {
        if index == 0 {
            minDatePicker.isHidden = !minDateCheckbox.isOn
        }
        else if index == 1 {
            maxDatePicker.isHidden = !maxDateCheckbox.isOn
        }
        self.delegate?.dateFilterDidChange()
    }
    
}

