/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import AVKit

import CoreLocation

class VideoCell: MapItemCell{
    
    var item : VideoItem
    
    var selectedButton: NSButton!
    
    let videoPlayerView = AVPlayerView()
    
    init(video: VideoItem){
        self.item = video
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        videoPlayerView.player = nil
    }
    
    override func updateIconView(){
        iconView.removeAllSubviews()
        selectedButton = NSButton(icon: item.selected ? "checkmark.square" : "square", color: .lightColor, backgroundColor: .darkColor, target: self, action: #selector(toggleSelection))
        iconView.addSubviewToLeft(selectedButton, insets: iconInsets)
        let editButton = NSButton(icon: "pencil", color: .lightColor, backgroundColor: .darkColor, target: self, action: #selector(editVideo))
        iconView.addSubviewToLeft(editButton, rightView: selectedButton, insets: iconInsets)
        let showButton = NSButton(icon: "magnifyingglass", color: .lightColor, backgroundColor: .darkColor, target: self, action: #selector(showVideo))
        iconView.addSubviewToLeft(showButton, rightView: editButton, insets: iconInsets)
            .connectToLeft(of: iconView)
    }
    
    override func setupTimeLabel(){
        timeLabel.stringValue = item.creationDate.dateTimeString()
    }
    
    override func setupMapIcon() {
        mapIconView.image = NSImage(systemSymbolName: item.hasValidCoordinate ? "mappin" : "mappin.slash", accessibilityDescription: nil)!.withTintColor(.red)
    }
    
    override func updateItemView(){
        itemView.removeAllSubviews()
        let imageView = NSImageView()
        imageView.setRoundedBorders()
        imageView.image = item.preview
        imageView.setAspectRatioConstraint()
        itemView.addSubviewFilling(imageView, insets: .zero)
    }
    
    @objc func toggleSelection(){
        item.selected = !item.selected
        selectedButton.image = NSImage(systemSymbolName: item.selected ? "checkmark.square" : "square", accessibilityDescription: nil)
    }
    
    @objc func showVideo(){
        videoPlayerView.player?.pause()
        MainViewController.shared.showVideo(item)
    }
    
    @objc func editVideo(){
        MainViewController.shared.editVideo(item)
    }
    
    @objc func selectionChanged(){
        item.selected = !item.selected
        updateIconView()
    }
    
}


