/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class VideoViewController: UIViewController {
    
    var videoURL : URL? = nil
    
    var contentView = UIView()
    var videoView = VideoPlayerView()
    var volumeView = VolumeSlider()
    
    override func loadView() {
        super.loadView()
        title = "video".localize()
        loadSubviews(guide: view.safeAreaLayoutGuide)
    }
    
    func loadSubviews(guide: UILayoutGuide) {
        view.addSubviewWithAnchors(contentView, top: guide.topAnchor, leading: guide.leadingAnchor, trailing: guide.trailingAnchor, bottom: guide.bottomAnchor, insets: UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0))
        contentView.backgroundColor = .black
        
        if let url = videoURL{
            videoView.url = url
            contentView.addSubviewBelow(videoView)
            videoView.setAspectRatioConstraint()
            volumeView.tintColor = .white
            volumeView.thumbTintColor = .white
            volumeView.addAction(UIAction(){ action in
                self.videoView.player.volume = self.volumeView.value
            }, for: .valueChanged)
            contentView.addSubviewBelow(volumeView, upperView: videoView)
                .height(25)
                .connectToBottom(of: contentView)
        }
    }
    
}
