/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers

class SettingsViewController: ScrollViewController{
    
    // date filter
    
    var dateFilterView = DateFilterView()
    var sortAscendingCheckbox = Checkbox()
    
    // other settings
    
    var followLocationSwitch = LabeledSwitchView()
    var mapSourceControl = UISegmentedControl()
    var distanceFilterControl = UISegmentedControl()
    
    var trackpointIntervalField = UISegmentedControl()
    
    override func loadView() {
        title = "settings".localize()
        super.loadView()
        view.addSubviewFillingSafeArea(scrollView, insets: .zero)
        scrollView.backgroundColor = .systemBackground
        setupScrollView()
        loadScrollableSubviews()
    }
    
    func loadScrollableSubviews() {
        
        let segmentTitleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]
        
        var header = UILabel(header: "dateFilter".localize())
        contentView.addSubviewBelow(header)
        dateFilterView.setupView(minLabelText: "minimumDate".localize(), maxLabelText: "maximumDate".localize(), minDate: ViewFilter.shared.dateFilterMinDate, maxDate: ViewFilter.shared.dateFilterMaxDate)
        dateFilterView.delegate = self
        contentView.addSubviewBelow(dateFilterView, upperView: header, insets: .zero)
        header = UILabel(header: "sorting".localize())
        contentView.addSubviewBelow(header, upperView: dateFilterView)
        sortAscendingCheckbox.setup(title: "sortAscending".localize(), index: 0, isOn: ViewFilter.shared.defaultSortAscending)
        sortAscendingCheckbox.delegate = self
        contentView.addSubviewWithAnchors(sortAscendingCheckbox, top: header.bottomAnchor, leading: contentView.leadingAnchor, insets: .zero)
        
        header = UILabel(header: "map".localize())
        contentView.addSubviewBelow(header, upperView: sortAscendingCheckbox)
        
        followLocationSwitch.setupView(labelText: "followLocation".localize(), isOn: Settings.shared.followLocation)
        followLocationSwitch.delegate = self
        contentView.addSubviewBelow(followLocationSwitch, upperView: header, insets: .zero)
        
        var subheader = UILabel(subheader: "distanceFilter".localize())
        contentView.addSubviewBelow(subheader, upperView: followLocationSwitch)
        
        distanceFilterControl.insertSegment(action: UIAction(){ action in
            Settings.shared.distanceFilter = .gps
            Settings.shared.save()
        }, at: 0, animated: false)
        distanceFilterControl.setTitle("gpsAccuracy".localize(), forSegmentAt: 0)
        distanceFilterControl.insertSegment(action: UIAction(){ action in
            Settings.shared.distanceFilter = .tight
            Settings.shared.save()
        }, at: 1, animated: false)
        distanceFilterControl.setTitle("\(Int(LocationDistance.tight.distance))m", forSegmentAt: 1)
        distanceFilterControl.insertSegment(action: UIAction(){ action in
            Settings.shared.distanceFilter = .medium
            Settings.shared.save()
        }, at: 2, animated: false)
        distanceFilterControl.setTitle("\(Int(LocationDistance.medium.distance))m", forSegmentAt: 2)
        distanceFilterControl.insertSegment(action: UIAction(){ action in
            Settings.shared.distanceFilter = .wide
            Settings.shared.save()
        }, at: 3, animated: false)
        distanceFilterControl.setTitle("\(Int(LocationDistance.wide.distance))m", forSegmentAt: 3)
        distanceFilterControl.insertSegment(action: UIAction(){ action in
            Settings.shared.distanceFilter = .extraWide
            Settings.shared.save()
        }, at: 4, animated: false)
        distanceFilterControl.setTitle("\(Int(LocationDistance.extraWide.distance))m", forSegmentAt: 4)
        distanceFilterControl.setTitleTextAttributes(segmentTitleAttributes, for: .normal)
        distanceFilterControl.selectedSegmentIndex = LocationDistanceList.shared.indexOf(distance: Settings.shared.distanceFilter)
        contentView.addSubviewBelow(distanceFilterControl, upperView: subheader)
        var hint = UILabel(hint: "distanceFilterHint".localize(table: "Hints"))
        contentView.addSubviewBelow(hint, upperView: distanceFilterControl, insets: OSInsets.flatInsets)
        
        header = UILabel(header: "tracks".localize())
        contentView.addSubviewBelow(header, upperView: hint)
        
        subheader = UILabel(subheader: "trackpointInterval".localize())
        contentView.addSubviewBelow(subheader, upperView: header)
        
        trackpointIntervalField.insertSegment(action: UIAction(){ action in
            Settings.shared.trackpointInterval = .extrashort
            Settings.shared.save()
        }, at: 0, animated: false)
        trackpointIntervalField.setTitle("\(Int(TrackpointInterval.extrashort.interval))s", forSegmentAt: 0)
        trackpointIntervalField.insertSegment(action: UIAction(){ action in
            Settings.shared.trackpointInterval = .short
            Settings.shared.save()
        }, at: 1, animated: false)
        trackpointIntervalField.setTitle("\(Int(TrackpointInterval.short.interval))s", forSegmentAt: 1)
        trackpointIntervalField.insertSegment(action: UIAction(){ action in
            Settings.shared.trackpointInterval = .medium
            Settings.shared.save()
        }, at: 2, animated: false)
        trackpointIntervalField.setTitle("\(Int(TrackpointInterval.medium.interval))s", forSegmentAt: 2)
        trackpointIntervalField.insertSegment(action: UIAction(){ action in
            Settings.shared.trackpointInterval = .long
            Settings.shared.save()
        }, at: 3, animated: false)
        trackpointIntervalField.setTitle("\(Int(TrackpointInterval.long.interval))s", forSegmentAt: 3)
        trackpointIntervalField.insertSegment(action: UIAction(){ action in
            Settings.shared.trackpointInterval = .extralong
            Settings.shared.save()
        }, at: 4, animated: false)
        trackpointIntervalField.setTitle("\(Int(TrackpointInterval.extralong.interval))s", forSegmentAt: 4)
        trackpointIntervalField.setTitleTextAttributes(segmentTitleAttributes, for: .normal)
        trackpointIntervalField.selectedSegmentIndex = TrackpointIntervalList.shared.indexOf(interval: Settings.shared.trackpointInterval)
        contentView.addSubviewBelow(trackpointIntervalField, upperView: subheader)
        hint = UILabel(hint: "trackpointIntervalHint".localize(table: "Hints"))
        contentView.addSubviewBelow(hint, upperView: trackpointIntervalField, insets: OSInsets.flatInsets)
            .connectToBottom(of: contentView)
        
    }
    
    func deleteAllTiles(){
        showDestructiveApprove(title: "deleteAllTiles".localize(), text: "deleteAllTilesHint".localize(table: "Hints")){
            TileProvider.shared.deleteAllTiles()
        }
    }
    
}

extension SettingsViewController: SwitchDelegate{
    
    func switchValueDidChange(sender: LabeledSwitchView, isOn: Bool) {
        if sender == followLocationSwitch{
            Settings.shared.followLocation = isOn
            Settings.shared.save()
        }
    }
    
}

extension SettingsViewController: DateFilterDelegate {
    
    func dateFilterDidChange() {
        ViewFilter.shared.dateFilterMinDate = dateFilterView.minDate
        ViewFilter.shared.dateFilterMaxDate = dateFilterView.maxDate
        ViewFilter.shared.save()
        MainViewController.shared.updateItemLayer()
    }
    
}

extension SettingsViewController: CheckboxDelegate {
    
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



    

