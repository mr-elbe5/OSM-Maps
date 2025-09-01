/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol TrackCellDelegate: MapItemCellDelegate, EditTrackDelegate {
}

class TrackCell: MapItemCell{

    static let CELL_IDENT = "trackCell"
    
    var item : TrackItem? = nil
    
    var delegate : TrackCellDelegate? = nil
    
    override func setupIconView(){
        iconView.removeAllSubviews()
        if let track = item{
            let selectedButton = UIButton().asDarkIconButton(track.selected ? "checkmark.square" : "square")
            selectedButton.addAction(UIAction(){ action in
                track.selected = !track.selected
                selectedButton.setImage(UIImage(systemName: track.selected ? "checkmark.square" : "square"), for: .normal)
                self.delegate?.selectionChanged()
            }, for: .touchDown)
            iconView.addSubviewToLeft(selectedButton, insets: iconInsets)
            
            let exportButton = UIButton().asDarkIconButton("square.and.arrow.up")
            exportButton.addAction(UIAction(){ action in
                if let track = self.item?.track, let url = GPXCreator.createTemporaryFile(track: track){
                    let controller = UIDocumentPickerViewController(forExporting: [url], asCopy: false)
                    controller.delegate = nil
                    MainViewController.shared.present(controller, animated: true)
                }
            }, for: .touchDown)
            iconView.addSubviewToLeft(exportButton, rightView: selectedButton, insets: iconInsets)
            
            let editButton = UIButton().asDarkIconButton("pencil")
            editButton.addAction(UIAction(){ action in
                let controller = EditTrackViewController(item: track)
                controller.delegate = self
                MainViewController.shared.navigationController?.pushViewController(controller, animated: true)
            }, for: .touchDown)
            iconView.addSubviewToLeft(editButton, rightView: exportButton, insets: iconInsets)
            
            let mapButton = UIButton().asDarkIconButton("map")
            mapButton.addAction(UIAction(){ action in
                MainViewController.shared.showTrackOnMap(item: track)
                MainViewController.shared.navigationController?.popViewController(animated: true)
            }, for: .touchDown)
            iconView.addSubviewToLeft(mapButton, rightView: editButton, insets: iconInsets)
            
                .connectToLeft(of: iconView)
        }
    }
    
    override func setupItemView(){
        itemView.removeAllSubviews()
        if let item = item{
            let header = UILabel(header: "track".localize())
            itemView.addSubviewCenteredBelow(header)
            
            let nameLabel = UILabel(text: item.track.name)
            nameLabel.textAlignment = .center
            itemView.addSubviewBelow(nameLabel, upperView: header)
            
            let tp = item.track.trackpoints.isEmpty ? nil : item.track.trackpoints[0]
            let startLabel = UILabel(text: "\("start".localize()): \(tp?.coordinate.asString ?? ""), \(item.track.startTime.dateTimeString())")
            itemView.addSubviewBelow(startLabel, upperView: nameLabel)
            
            let endLabel = UILabel(text: "\("end".localize()): \(item.track.endTime.dateTimeString())")
            itemView.addSubviewBelow(endLabel, upperView: startLabel, insets: OSInsets.flatInsets)
            
            let distanceLabel = UILabel(text: "\("distance".localize()): \(Int(item.track.distance)) m")
            itemView.addSubviewBelow(distanceLabel, upperView: endLabel, insets: OSInsets.flatInsets)
            
            let upDistanceLabel = UILabel(text: "\("upDistance".localize()): \(Int(item.track.upDistance)) m")
            itemView.addSubviewBelow(upDistanceLabel, upperView: distanceLabel, insets: OSInsets.flatInsets)
            
            let downDistanceLabel = UILabel(text: "\("downDistance".localize()): \(Int(item.track.downDistance)) m")
            itemView.addSubviewBelow(downDistanceLabel, upperView: upDistanceLabel, insets: OSInsets.flatInsets)
            
            let durationLabel = UILabel(text: "\("duration".localize()): \(item.track.duration.hmsString())")
            itemView.addSubviewBelow(durationLabel, upperView: downDistanceLabel, insets: OSInsets.flatInsets)
            
            let trackpointsLabel = UILabel(text: "\("trackpoints".localize()): \(item.track.trackpoints.count)")
            itemView.addSubviewBelow(trackpointsLabel, upperView: durationLabel, insets: OSInsets.flatInsets)
            
            if let image = item.getPreview(){
                let imageView = UIImageView()
                imageView.withDefaults()
                imageView.setRoundedBorders()
                imageView.image = image
                imageView.setAspectRatioConstraint()
                imageView.contentMode = .scaleAspectFit
                itemView.addSubviewBelow(imageView, upperView: trackpointsLabel)
                    .connectToBottom(of: itemView)
            }
            else{
                trackpointsLabel.bottom(itemView.bottomAnchor)
            }
        }
    }
    
    override func setupTimeLabel(){
        timeLabel.text = item?.creationDate.dateTimeString()
    }
    
    override func setupMapIcon() {
        if let item = item{
            mapIconView.image = UIImage(systemName: item.hasValidCoordinate ? "mappin" : "mappin.slash", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24))?
                .withTintColor(.systemBlue).withRenderingMode(.alwaysOriginal)
            
        }
    }
    
}

extension TrackCell : EditTrackDelegate{
    
    func trackChanged(item: TrackItem) {
      delegate?.trackChanged(item: item)
    }
    
}

extension TrackCell: UITextFieldDelegate{
    
    func textFieldDidChange(_ textField: UITextView) {
        if let item = item{
            item.track.name = textField.text
        }
    }
    
}
