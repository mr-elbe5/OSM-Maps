/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation
import AVKit

protocol EditVideoDelegate {
    func videoChanged(item: VideoItem)
}

class EditVideoViewController: ModalViewController {
    
    var item: VideoItem
    
    var newCoordinate: CLLocationCoordinate2D?
    
    var coordinateLabel = NSTextField(labelWithString: "")
    var datePicker = LabeledDatePicker()
    
    init(item: VideoItem){
        self.item = item
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: 500, height: 0))
        var header = NSTextField(labelWithString: "editVideo".localize()).asHeadline()
        view.addSubviewBelow(header)
        var lastView: NSView = header
        if let image = item.preview{
            let imageView = NSImageView(image: image)
            imageView.compressable()
            imageView.setAspectRatioConstraint()
            view.addSubviewCenteredBelow(imageView, upperView: header)
                .height(300)
            lastView = imageView
        }
        header = NSTextField(labelWithString: "coordinate".localize()).asHeadline()
        view.addSubviewBelow(header, upperView: lastView)
        coordinateLabel.stringValue = item.coordinate.asShortString
        view.addSubviewBelow(coordinateLabel, upperView: header)
        let changeButton = NSButton(title: "changeCoordinateToMapCenter".localize(), target: self, action: #selector(changeToMapCenter))
        view.addSubviewCenteredBelow(changeButton, upperView: coordinateLabel)
        datePicker.setupView(labelText: "creationDate".localize(), date: item.creationDate)
        datePicker.mode = .single
        view.addSubviewBelow(datePicker, upperView: changeButton, insets: .zero)
        let saveButton = NSButton(title: "save".localize(), target: self, action: #selector(save))
        view.addSubviewWithAnchors(saveButton, top: datePicker.bottomAnchor, bottom: view.bottomAnchor)
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
            MainViewController.shared.itemsChanged()
        }
        responseCode = .OK
        self.view.window?.close()
    }
    
}
