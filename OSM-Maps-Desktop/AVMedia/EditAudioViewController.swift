/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation
import AVKit

class EditAudioViewController: ModalViewController {
    
    var item: AudioItem
    
    var newCoordinate: CLLocationCoordinate2D?
    
    var coordinateLabel = NSTextField(labelWithString: "")
    var datePicker = LabeledDatePicker()
    
    init(item: AudioItem){
        self.item = item
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: 500, height: 0))
        var header = NSTextField(labelWithString: "editAudio".localize()).asHeadline()
        view.addSubviewBelow(header)
        let audioView = AudioPlayerView()
        audioView.setupView()
        audioView.url = item.url
        audioView.enablePlayer()
        view.addSubviewBelow(audioView, upperView: header)
        header = NSTextField(labelWithString: "coordinate".localize()).asHeadline()
        view.addSubviewBelow(header, upperView: audioView)
        coordinateLabel.stringValue = item.coordinate.asShortString
        view.addSubviewBelow(coordinateLabel, upperView: header)
        let changeButton = NSButton(title: "changeCoordinateToMapCenter".localize(), target: self, action: #selector(changeToMapCenter))
        view.addSubviewCenteredBelow(changeButton, upperView: coordinateLabel)
        datePicker.setupView(labelText: "audioDateTime".localize(), date: item.creationDate)
        datePicker.mode = .single
        view.addSubviewBelow(datePicker, upperView: changeButton, insets: .zero)
        let hint = NSTextField(wrappingLabelWithString: "exifChangeHint".localize(table: "Hints"))
        view.addSubviewBelow(hint, upperView: datePicker)
        let saveButton = NSButton(title: "save".localize(), target: self, action: #selector(save))
        view.addSubviewWithAnchors(saveButton, top: hint.bottomAnchor, bottom: view.bottomAnchor)
            .centerX(view.centerXAnchor)
    }
    
    @objc func changeToMapCenter(){
        newCoordinate = MapStatus.shared.centerCoordinate
        coordinateLabel.stringValue = newCoordinate!.asShortString
    }
    
    @objc func save(){
        let newCoord: CLLocationCoordinate2D? = newCoordinate != item.coordinate ? newCoordinate : nil
        let newDate: Date? = datePicker.date != item.creationDate ? datePicker.date : nil
        if newCoord != nil || newDate != nil{
            item.updateEditedMedia(coordinate: newCoordinate, creationDate: datePicker.date)
            AppData.shared.save()
            MainViewController.shared.updateItemLayer()
        }
        responseCode = .OK
        self.view.window?.close()
    }
    
}
