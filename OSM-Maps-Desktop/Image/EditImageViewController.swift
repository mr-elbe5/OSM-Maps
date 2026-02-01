/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation

class EditImageViewController: ModalViewController {
    
    var item: ImageItem
    
    var newCoordinate: CLLocationCoordinate2D?
    
    var coordinateLabel = NSTextField(labelWithString: "")
    var datePicker = LabeledDatePicker()
    
    init(item: ImageItem){
        self.item = item
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: 500, height: 0))
        var header = NSTextField(labelWithString: "editImage".localize()).asHeadline()
        view.addSubviewBelow(header)
        let imageView = NSImageView()
        if let img = item.preview{
            imageView.image = img
        }
        imageView.compressable()
        imageView.setAspectRatioConstraint()
        view.addSubviewBelow(imageView, upperView: header)
            .minWidth(300).minHeight(300)
        header = NSTextField(labelWithString: "coordinate".localize()).asHeadline()
        view.addSubviewBelow(header, upperView: imageView)
        coordinateLabel.stringValue = item.coordinate.asShortString
        view.addSubviewBelow(coordinateLabel, upperView: header)
        let changeButton = NSButton(title: "changeCoordinateToMapCenter".localize(), target: self, action: #selector(changeToMapCenter))
        view.addSubviewCenteredBelow(changeButton, upperView: coordinateLabel)
        datePicker.setupView(labelText: "imageDateTime".localize(), date: item.creationDate)
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
            item.updateEditedImage(coordinate: newCoordinate, creationDate: datePicker.date)
            AppData.shared.save()
            MainViewController.shared.itemsChanged()
        }
        responseCode = .OK
        self.view.window?.close()
    }
    
}
