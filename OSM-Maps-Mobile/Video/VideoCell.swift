/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class VideoCell: MapItemCell{
    
    static let CELL_IDENT = "videoCell"
    
    var video : VideoItem? = nil {
        didSet {
            updateCell()
            setSelected(video?.selected ?? false, animated: false)
        }
    }
    
    override func updateIconView(){
        iconView.removeAllSubviews()
        if let video = video{
            let selectedButton = UIButton().asIconButton(video.selected ? "checkmark.square" : "square", color: .darkGray)
            selectedButton.addAction(UIAction(){ action in
                video.selected = !video.selected
                selectedButton.setImage(UIImage(systemName: video.selected ? "checkmark.square" : "square"), for: .normal)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(selectedButton, top: iconView.topAnchor, trailing: iconView.trailingAnchor , bottom: iconView.bottomAnchor, insets: iconInsets)
            
            let viewButton = UIButton().asIconButton("magnifyingglass", color: .darkGray)
            viewButton.addAction(UIAction(){ action in
                MainViewController.shared.showVideo(item: video)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(viewButton, top: iconView.topAnchor, leading: iconView.leadingAnchor, trailing: selectedButton.leadingAnchor, bottom: iconView.bottomAnchor, insets: iconInsets)
            
        }
    }
    
    override func updateTimeLabel(){
        timeLabel.text = video?.creationDate.dateTimeString()
    }
    
    override func updateItemView(){
        itemView.removeAllSubviews()
        if let video = video{
            let videoView = VideoPlayerView()
            videoView.setRoundedBorders()
            itemView.addSubviewWithAnchors(videoView, top: iconView.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: UIEdgeInsets(top: 2, left: 0, bottom: OSInsets.defaultInset, right: 0))
            videoView.url = video.url
            videoView.setAspectRatioConstraint()
            videoView.bottom(itemView.bottomAnchor)
        }
    }
    
}




