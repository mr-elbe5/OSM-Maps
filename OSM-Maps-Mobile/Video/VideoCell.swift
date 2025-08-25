/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol VideoCellDelegate {
    func videoChanged(_ item: VideoItem)
}

class VideoCell: MapItemCell{
    
    static let CELL_IDENT = "videoCell"
    
    var item : VideoItem? = nil {
        didSet {
            updateCell()
            setSelected(item?.selected ?? false, animated: false)
        }
    }
    
    var delegate : VideoCellDelegate?
    
    override func updateIconView(){
        iconView.removeAllSubviews()
        if let video = item{
            let selectedButton = UIButton().asIconButton(video.selected ? "checkmark.square" : "square", color: .darkGray)
            selectedButton.addAction(UIAction(){ action in
                video.selected = !video.selected
                selectedButton.setImage(UIImage(systemName: video.selected ? "checkmark.square" : "square"), for: .normal)
            }, for: .touchDown)
            iconView.addSubviewToLeft(selectedButton, insets: iconInsets)
            let editButton = UIButton().asDarkIconButton("pencil")
            editButton.addAction(UIAction(){ action in
                let controller = EditVideoViewController(item: video)
                controller.delegate = self
                MainViewController.shared.navigationController?.pushViewController(controller, animated: true)
            }, for: .touchDown)
            iconView.addSubviewToLeft(editButton, rightView: selectedButton, insets: iconInsets)
            let viewButton = UIButton().asIconButton("magnifyingglass", color: .darkGray)
            viewButton.addAction(UIAction(){ action in
                MainViewController.shared.showVideo(item: video)
            }, for: .touchDown)
            iconView.addSubviewToLeft(viewButton, rightView: editButton, insets: iconInsets)
                .connectToLeft(of: iconView)
        }
    }
    
    override func updateTimeLabel(){
        timeLabel.text = item?.creationDate.dateTimeString()
    }
    
    override func updateItemView(){
        itemView.removeAllSubviews()
        if let video = item{
            let imageView = UIImageView()
            imageView.withDefaults()
            imageView.setRoundedBorders()
            imageView.image = video.preview
            imageView.setAspectRatioConstraint()
            itemView.addSubviewFilling(imageView)
        }
    }
    
}

extension VideoCell : EditVideoDelegate{
    
    func videoChanged(item: VideoItem) {
      delegate?.videoChanged(item)
    }
    
}



