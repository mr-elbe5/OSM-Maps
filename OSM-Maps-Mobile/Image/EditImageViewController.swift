/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

protocol EditImageDelegate {
    func imageChanged(item: ImageItem)
}

class EditImageViewController: ScrollViewController{
    
    var item : ImageItem
    var newCoordinate: CLLocationCoordinate2D?
    
    var coordinateLabel = UILabel()
    var datePicker = LabeledDatePicker()
    
    var delegate: EditImageDelegate?
    
    init(item: ImageItem){
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        title = "image".localize()
        view.addSubviewFillingSafeArea(scrollView, insets: .zero)
        scrollView.backgroundColor = .systemBackground
        setupScrollView()
        loadScrollableSubviews()
    }
    
    func loadScrollableSubviews() {
        let imageView = UIImageView()
        imageView.withDefaults()
        imageView.setRoundedBorders()
        imageView.image = item.preview
        imageView.setAspectRatioConstraint()
        contentView.addSubviewBelow(imageView, insets: .zero)
        let header = UILabel(header: "coordinate".localize())
        contentView.addSubviewBelow(header, upperView: imageView)
        coordinateLabel.text = item.coordinate.asShortString
        contentView.addSubviewBelow(coordinateLabel, upperView: header)
        let changeButton = TextButton(text: "changeCoordinateToMapCenter".localize())
        changeButton.addAction(UIAction(){ action in
            self.changeToMapCenter()
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(changeButton, upperView: coordinateLabel)
        datePicker.setupView(labelText: "imageDateTime".localize(), date: item.creationDate)
        datePicker.mode = .dateAndTime
        contentView.addSubviewBelow(datePicker, upperView: changeButton, insets: .zero)
        let hint = UILabel(hint: "exifChangeHint".localize(table: "Hints"))
        hint .textAlignment = .center
        view.addSubviewBelow(hint, upperView: datePicker)
        let saveButton = TextButton(text: "save".localize())
        saveButton.addAction(UIAction(){ action in
            self.save()
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(saveButton, upperView: hint)
            .connectToBottom(of: contentView)
    }
    
    func changeToMapCenter(){
        newCoordinate = MapStatus.shared.centerCoordinate
        coordinateLabel.text = newCoordinate!.asShortString
    }
    
    func save(){
        let newCoord: CLLocationCoordinate2D? = newCoordinate != item.coordinate ? newCoordinate : nil
        let newDate: Date? = datePicker.date != item.creationDate ? datePicker.date : nil
        if newCoord != nil || newDate != nil{
            item.updateEditedImage(coordinate: newCoordinate, creationDate: datePicker.date)
            AppData.shared.save()
            delegate?.imageChanged(item: item)
        }
        self.close()
        
    }
    
}



