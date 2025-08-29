/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

protocol EditVideoDelegate {
    func videoChanged(item: VideoItem)
}

class EditVideoViewController: ScrollViewController{
    
    var item : VideoItem
    var newCoordinate: CLLocationCoordinate2D?
    
    var coordinateLabel = UILabel()
    var datePicker = LabeledDatePicker()
    
    var delegate: EditVideoDelegate?
    
    init(item: VideoItem){
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        title = "video".localize()
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
        contentView.addSubviewBelow(imageView)
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
        let saveButton = TextButton(text: "save".localize())
        saveButton.addAction(UIAction(){ action in
            self.save()
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(saveButton, upperView: datePicker)
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
            item.updateEditedMedia(coordinate: newCoordinate, creationDate: datePicker.date)
            AppData.shared.save()
            delegate?.videoChanged(item: item)
        }
        self.close()
        
    }
    
}



