/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import AVFoundation
import AVKit


protocol VideoCellDelegate{
    func editVideo(_ video: VideoItem)
}

class VideoCellView : MapItemCellView{
    
    var video: VideoItem
    
    var selectedButton: NSButton!
    let videoPlayerView = AVPlayerView()
    
    var delegate: VideoCellDelegate? = nil
    
    init(video: VideoItem){
        self.video = video
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        videoPlayerView.player = nil
    }
    
    override func viewDidHide() {
        super.viewDidHide()
        videoPlayerView.player?.pause()
    }
    
    override func setupView() {
        super.setupView()
        let titleField = NSTextField(wrappingLabelWithString: "video".localize()).asHeadline()
        addSubviewWithAnchors(titleField, top: topAnchor, leading: leadingAnchor, insets: OSInsets.defaultInsets)
        let iconBar = IconBar()
        addSubviewWithAnchors(iconBar, top: topAnchor, trailing: trailingAnchor)
        let showButton = NSButton(icon: "magnifyingglass", target: self, action: #selector(showVideo))
        iconBar.addArrangedSubview(showButton)
        let editButton = NSButton(icon: "pencil", target: self, action: #selector(editVideo))
        iconBar.addArrangedSubview(editButton)
        selectedButton = NSButton(icon: video.selected ? "checkmark.square" : "square", target: self, action: #selector(selectionChanged))
        iconBar.addArrangedSubview(selectedButton)
        var lastView: NSView = iconBar
        if let image = video.preview{
            let imageView = NSImageView(image: image)
            imageView.compressable()
            imageView.setAspectRatioConstraint()
            addSubviewWithAnchors(imageView, top: lastView.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor)
            lastView = imageView
        }
        lastView.bottom(bottomAnchor)
    }
    
    override func updateIconView() {
        selectedButton.image = NSImage(systemSymbolName: video.selected ? "checkmark.square" : "square", accessibilityDescription: .none)
    }
    
    @objc func showVideo(){
        videoPlayerView.player?.pause()
        MainViewController.shared.showVideo(video)
    }
    
    @objc func editVideo(){
        delegate?.editVideo(video)
    }
    
    @objc func selectionChanged(){
        video.selected = !video.selected
        updateIconView()
    }
    
}
