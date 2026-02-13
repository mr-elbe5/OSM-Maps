/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

class SaveTrackViewController: ScrollViewController{
    
    var item : TrackItem
    
    var imageView = UIImageView()
    var nameField = LabeledTextField()
    
    init(item: TrackItem){
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        imageView.image = item.getPreview()
        imageView.setAspectRatioConstraint()
        contentView.addSubviewBelow(imageView, insets: .zero)
        nameField.setupView(labelText: "name".localize())
        nameField.text = item.track.name
        contentView.addSubviewBelow(nameField, upperView: imageView)
        let saveButton = TextButton(text: "save".localize())
        saveButton.addAction(UIAction(){ action in
            self.save()
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(saveButton, upperView: nameField)
            .connectToBottom(of: contentView)
    }
    
    override func scrollForKeyboard() {
        scrollToTop()
    }
    
    func save(){
        item.track.name = nameField.text
        self.close()
        MainViewController.shared.saveTrack(item: item)
    }
    
}



