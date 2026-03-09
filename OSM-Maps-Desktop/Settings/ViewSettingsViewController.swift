/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import UniformTypeIdentifiers

class ViewSettingsViewController: PopoverViewController{
    
    var contentView: ViewSettingsView{
        view as! ViewSettingsView
    }
    
    override func loadView() {
        view = ViewSettingsView(controller: self)
        view.frame = CGRect(origin: .zero, size: CGSize(width: 400, height: 0))
        view.setupView()
    }
    
}

class ViewSettingsView: PopoverView{
    
    var dateFilterView = DateFilterView().withColor(.white)
    var sortAscendingCheckbox = Checkbox().withColor(.white)
    
    override func setupView() {
        var header = NSTextField(labelWithString: "dateFilter".localize()).asHeadline()
        addSubviewBelow(header)
        dateFilterView.setupView(minLabelText: "minimumDate".localize(), maxLabelText: "maximumDate".localize(), minDate: ViewFilter.shared.dateFilterMinDate, maxDate: ViewFilter.shared.dateFilterMaxDate)
        dateFilterView.delegate = self
        addSubviewBelow(dateFilterView, upperView: header, insets: NSEdgeInsets(top: 10, left: 10, bottom: 10, right: 20))
        header = NSTextField(labelWithString: "sorting".localize())
        addSubviewBelow(header, upperView: dateFilterView)
        sortAscendingCheckbox.setup(title: "sortAscending".localize(), index: 0, isOn: ViewFilter.shared.defaultSortAscending)
        sortAscendingCheckbox.delegate = self
        addSubviewWithAnchors(sortAscendingCheckbox, top: header.bottomAnchor, leading: leadingAnchor)
            .connectToBottom(of: self)
    }
    
}

extension ViewSettingsView: DateFilterDelegate{
    
    func dateFilterDidChange() {
        ViewFilter.shared.dateFilterMinDate = dateFilterView.minDate
        ViewFilter.shared.dateFilterMaxDate = dateFilterView.maxDate
        ViewFilter.shared.save()
        MainViewController.shared.itemsChanged()
    }
    
}

extension ViewSettingsView: CheckboxDelegate{
    
    func checkboxIsSelected(index: Int, value: String) {
        switch index {
        case 0:
            ViewFilter.shared.defaultSortAscending = sortAscendingCheckbox.isOn
            ViewFilter.shared.save()
        default:
            break
        }
    }
    
    
}

