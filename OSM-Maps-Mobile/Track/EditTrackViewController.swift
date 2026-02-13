/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

protocol EditTrackDelegate {
    func trackChanged(item: TrackItem)
}

class EditTrackViewController: ScrollViewController{
    
    var item : TrackItem
    var newTrack: Track
    
    var delegate: EditTrackDelegate?
    
    var imageView = UIImageView()
    var nameField = LabeledTextField()
    var pointLabel = LabeledText()
    var minDistanceField = LabeledTextField()
    
    init(item: TrackItem){
        self.item = item
        self.newTrack = Track()
        super.init(nibName: nil, bundle: nil)
        newTrack.setTrackpoints(item.track.trackpoints)
        newTrack.updateFromTrackpoints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        item.track.trackpoints.deselectAll()
    }
    
    override func loadView() {
        super.loadView()
        title = "track".localize()
        scrollView.backgroundColor = .systemBackground
        setupScrollView()
        addScrollViewFillingWithKeyboard()
        loadScrollableSubviews()
    }
    
    func loadScrollableSubviews() {
        imageView.withDefaults()
        imageView.setRoundedBorders()
        imageView.image = TrackImageCreator.createImage(track: newTrack, size: CGSize(width: TrackItem.previewSize, height: TrackItem.previewSize), withPoints: true)
        imageView.setAspectRatioConstraint()
        contentView.addSubviewBelow(imageView, insets: .zero)
        nameField.setupView(labelText: "name".localize())
        nameField.text = item.track.name
        contentView.addSubviewBelow(nameField, upperView: imageView)
        pointLabel.setupView(labelText: "numTrackpoints".localize())
        pointLabel.text = "\(newTrack.trackpoints.count)"
        contentView.addSubviewBelow(pointLabel, upperView: nameField, insets: .zero)
        minDistanceField.setupView(labelText: "simplifyByDistance".localize())
        contentView.addSubviewBelow(minDistanceField, upperView: pointLabel)
        let applyButton = TextButton(text: "apply".localize())
        applyButton.addAction(UIAction(){ action in
            self.apply()
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(applyButton, upperView: minDistanceField)
            .centerX(contentView.centerXAnchor)
        let saveButton = TextButton(text: "save".localize())
        saveButton.addAction(UIAction(){ action in
            self.save()
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(saveButton, upperView: applyButton)
            .connectToBottom(of: contentView)
    }
    
    override func scrollForKeyboard() {
        scrollToTop()
    }
    
    func apply(){
        let dist = Double(minDistanceField.text)
        if let dist = dist, dist > 0{
            newTrack.setMinimalTrackpointDistances(minDistance: dist)
        }
        pointLabel.text = "\(newTrack.trackpoints.count)"
        imageView.image = TrackImageCreator.createImage(track: newTrack, size: CGSize(width: TrackItem.previewSize, height: TrackItem.previewSize), withPoints: true)
    }
    
    func save(){
        item.track.name = nameField.text
        item.track.trackpoints = newTrack.trackpoints
        item.track.updateFromTrackpoints()
        item.setModified()
        self.close()
        AppData.shared.save()
        delegate?.trackChanged(item: item)
    }
    
}



