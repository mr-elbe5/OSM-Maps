/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

import CoreLocation

protocol ImageCellDelegate: EditImageDelegate {
}

class ImageCell: MapItemCell{
    
    static let CELL_IDENT = "imageCell"
    
    var item : ImageItem? = nil {
        didSet {
            updateCell()
            setSelected(item?.selected ?? false, animated: false)
        }
    }
    
    var delegate: ImageCellDelegate?
    
    override func updateIconView(){
        iconView.removeAllSubviews()
        if let image = item{
            let selectedButton = UIButton().asIconButton(image.selected ? "checkmark.square" : "square", color: .label)
            selectedButton.addAction(UIAction(){ action in
                image.selected = !image.selected
                selectedButton.setImage(UIImage(systemName: image.selected ? "checkmark.square" : "square"), for: .normal)
            }, for: .touchDown)
            iconView.addSubviewToLeft(selectedButton, insets: iconInsets)
            let showOnMapButton = UIButton().asIconButton("map", color: .label)
            showOnMapButton.addAction(UIAction(){ action in
                MainViewController.shared.navigationController?.popToRootViewController(animated: true)
                MainViewController.shared.showItemOnMap(item: image)
            }, for: .touchDown)
            iconView.addSubviewToLeft(showOnMapButton, rightView: selectedButton, insets: iconInsets)
            showOnMapButton.isEnabled = image.hasValidCoordinate
            let editButton = UIButton().asIconButton("pencil", color: .label)
            editButton.addAction(UIAction(){ action in
                let controller = EditImageViewController(item: image)
                controller.delegate = self
                MainViewController.shared.navigationController?.pushViewController(controller, animated: true)
            }, for: .touchDown)
            iconView.addSubviewToLeft(editButton, rightView: showOnMapButton, insets: iconInsets)
            let viewButton = UIButton().asIconButton("magnifyingglass", color: .label)
            viewButton.addAction(UIAction(){ action in
                if let uiImage = image.preview{
                    MainViewController.shared.navigationController?.pushViewController(ImageViewController(image: uiImage), animated: true)
                }
            }, for: .touchDown)
            iconView.addSubviewToLeft(viewButton, rightView: editButton, insets: iconInsets)
                .connectToLeft(of: iconView)
        }
    }
    
    override func updateTimeLabel(){
        timeLabel.text = item?.creationDate.dateTimeString()
    }
    
    override func updateMapIcon() {
        if let item = item{
            mapIconView.image = UIImage(systemName: item.hasValidCoordinate ? "mappin" : "mappin.slash", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24))?
                .withTintColor(.systemRed).withRenderingMode(.alwaysOriginal)
            
        }
    }
    
    override func updateItemView(){
        itemView.removeAllSubviews()
        if let image = item{
            let imageView = UIImageView()
            imageView.withDefaults()
            imageView.setRoundedBorders()
            imageView.image = image.preview
            imageView.setAspectRatioConstraint()
            itemView.addSubviewFilling(imageView, insets: .zero)
        }
    }
    
}

extension ImageCell : EditImageDelegate{
    
    func imageChanged(item: ImageItem) {
      delegate?.imageChanged(item: item)
    }
    
}


