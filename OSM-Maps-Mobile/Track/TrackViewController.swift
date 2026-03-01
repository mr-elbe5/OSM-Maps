/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers
import CoreLocation

class TrackViewController: ScrollViewController{
    
    var item: TrackItem
    
    var nameEditField = UITextField()
    
    var timeLabel = UILabel(text: "")
    var distanceLabel = UILabel(text: "\("distance".localize()): 0 m")
    var upDistanceLabel = UILabel(text: "\("upDistance".localize()): 0 m")
    var downDistanceLabel = UILabel(text: "\("downDistance".localize()): 0 m")
    var durationLabel = UILabel(text: "\("duration".localize()): 00:00")
    var trackpointsLabel = UILabel(text: "\("trackpoints".localize()): 0")
    
    init(item: TrackItem){
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "track".localize()
        super.loadView()
        scrollView.backgroundColor = .systemBackground
        setupScrollView()
        addScrollViewFillingWithKeyboard()
        loadScrollableSubviews()
    }
    
    func setupNavigationItems() {
        setNavigationBackButton()
        var groups = Array<UIBarButtonItemGroup>()
        var items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "showOnMap", image: UIImage(systemName: "map"), primaryAction: UIAction(){ action in
            self.navigationController?.popToRootViewController(animated: true)
            MainViewController.shared.showTrackOnMap(item: self.item)
        }))
        items.append(UIBarButtonItem(title: "export", image: UIImage(systemName: "square.and.arrow.up"), primaryAction: UIAction(){ action in
            self.exportTrack(track: self.item.track)
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(items: items))
        navigationItem.trailingItemGroups = groups
    }
    
    func loadScrollableSubviews() {
        contentView.removeAllSubviews()
        if !item.track.trackpoints.isEmpty {
            var header = UILabel(header: "startLocation".localize())
            contentView.addSubviewWithAnchors(header, top: contentView.topAnchor, leading: contentView.leadingAnchor)
            
            let coordinateLabel = UILabel(text: item.track.trackpoints[0].coordinate.asString)
            contentView.addSubviewWithAnchors(coordinateLabel, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor,insets: OSInsets.flatInsets)
            
            contentView.addSubviewWithAnchors(timeLabel, top: coordinateLabel.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor,insets: OSInsets.flatInsets)
            
            header = UILabel(header: "name".localize())
            contentView.addSubviewWithAnchors(header, top: timeLabel.bottomAnchor, leading: contentView.leadingAnchor)
            
            nameEditField.setDefaults()
            nameEditField.text = item.track.name
            nameEditField.setKeyboardToolbar(doneTitle: "done".localize())
            contentView.addSubviewWithAnchors(nameEditField, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor)
            
            header = UILabel(header: "distances".localize())
            contentView.addSubviewWithAnchors(header, top: nameEditField.bottomAnchor, leading: contentView.leadingAnchor)
            contentView.addSubviewWithAnchors(distanceLabel, top: header.bottomAnchor, leading: contentView.leadingAnchor,insets: OSInsets.flatInsets)
            contentView.addSubviewWithAnchors(upDistanceLabel, top: distanceLabel.bottomAnchor, leading: contentView.leadingAnchor,insets: OSInsets.flatInsets)
            contentView.addSubviewWithAnchors(downDistanceLabel, top: upDistanceLabel.bottomAnchor, leading: contentView.leadingAnchor,insets: OSInsets.flatInsets)
            contentView.addSubviewWithAnchors(durationLabel, top: downDistanceLabel.bottomAnchor, leading: contentView.leadingAnchor, insets: OSInsets.flatInsets)
            contentView.addSubviewWithAnchors(trackpointsLabel, top: durationLabel.bottomAnchor, leading: contentView.leadingAnchor, insets: OSInsets.flatInsets)
            
            updateLabels()
            
            let recalculateButton = UIButton()
            recalculateButton.setTitle("recalculate".localize(), for: .normal)
            recalculateButton.setTitleColor(.systemBlue, for: .normal)
            recalculateButton.addAction(UIAction(){ action in
                self.recalculate()
            }, for: .touchDown)
            contentView.addSubviewWithAnchors(recalculateButton, top: trackpointsLabel.bottomAnchor)
                .centerX(contentView.centerXAnchor)
            
            let saveButton = UIButton()
            saveButton.setTitle("save".localize(), for: .normal)
            saveButton.setTitleColor(.systemBlue, for: .normal)
            saveButton.addAction(UIAction(){ action in
                self.save()
            }, for: .touchDown)
            contentView.addSubviewWithAnchors(saveButton, top: recalculateButton.bottomAnchor)
                .centerX(contentView.centerXAnchor)
            
            var lastView: UIView = saveButton
            
            if let img = TrackImageCreator.createImage(track: item.track, size: CGSize(width: 500, height: 500)){
                let imgView = UIImageView(image: img)
                imgView.setAspectRatioConstraint()
                contentView.addSubviewWithAnchors(imgView, top: saveButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor)
                lastView = imgView
            }
            else{
                let loadButton = UIButton()
                loadButton.setTitle("loadImage".localize(), for: .normal)
                loadButton.setTitleColor(.systemBlue, for: .normal)
                loadButton.addAction(UIAction(){ action in
                    self.loadScrollableSubviews()
                }, for: .touchDown)
                contentView.addSubviewWithAnchors(loadButton, top: saveButton.bottomAnchor)
                    .centerX(contentView.centerXAnchor)
                lastView = loadButton
            }
            
            lastView.bottom(contentView.bottomAnchor)
                
        }
        
    }
    
    func updateLabels(){
        timeLabel.text = "\(item.track.startTime.dateTimeString) - \(item.track.endTime.dateTimeString)"
        distanceLabel.text = "\("distance".localize()): \(Int(item.track.distance))m"
        upDistanceLabel.text = "\("upDistance".localize()): \(Int(item.track.upDistance))m"
        downDistanceLabel.text = "\("downDistance".localize()): \(Int(item.track.downDistance))m"
        durationLabel.text = "\("duration".localize()): \(item.track.duration.hmsString())"
        trackpointsLabel.text = "\("trackpoints".localize()): \(item.track.trackpoints.count)"
    }
    
    func exportTrack(track: Track) {
        if let url = track.createGPXFile(){
            let controller = UIDocumentPickerViewController(forExporting: [url], asCopy: false)
            //controller.directoryURL = FileManager.exportGpxDirURL
            present(controller, animated: true)
        }
    }
    
    func save(){
        item.track.name = nameEditField.text ?? "Tour"
        item.setModified()
        AppData.shared.save()
    }
    
    func recalculate(){
        item.track.updateFromTrackpoints()
        item.setModified()
        AppData.shared.save()
        updateLabels()
    }
    
}

