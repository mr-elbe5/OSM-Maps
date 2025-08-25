/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import AVFoundation

class VideoPlayerView: UIView {
    
    var player : AVPlayer
    var playerLayer : AVPlayerLayer
    var aspectRatio : CGFloat = 1
    
    var playButton = UIButton()
    
    var url : URL? = nil{
        didSet{
            if let url = url{
                let asset = AVURLAsset(url: url)
                Task(){
                    do{
                        if let track = try await asset.loadTracks(withMediaType: AVMediaType.video).first{
                            let size = try await track.load(.naturalSize)
                            self.aspectRatio = abs(size.width / size.height)
                        }
                    }
                    catch let(err){
                        Log.error(error: err)
                    }
                }
                let item = AVPlayerItem(asset: asset)
                player.replaceCurrentItem(with: item)
                layoutSubviews()
            }
        }
    }
    
    override init(frame: CGRect) {
        self.player = AVPlayer()
        self.playerLayer = AVPlayerLayer(player: player)
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
        playerLayer.videoGravity = .resizeAspect
        playerLayer.needsDisplayOnBoundsChange = true
        self.layer.addSublayer(playerLayer)
        playButton.asIconButton("play.fill", color: .white)
        playButton.scaleBy(2.0)
        playButton.addAction(UIAction(){ action in
            self.togglePlay()
        }, for: .touchDown)
        addSubviewWithAnchors(playButton, bottom: bottomAnchor, insets: OSInsets.doubleInsets)
            .centerX(centerXAnchor)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer.frame = self.bounds
    }
    
    @objc func togglePlay(){
        if player.rate == 0{
            player.rate = 1
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
        else{
            player.rate = 0
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero, completionHandler: nil)
            player.rate = 0
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        if size.height == UIView.noIntrinsicMetric {
            size.height = size.width / aspectRatio
        }
        return size
    }
    
    func setAspectRatioConstraint() {
        let c = NSLayoutConstraint(item: self, attribute: .width,
                                   relatedBy: .equal,
                                   toItem: self, attribute: .height,
                                   multiplier: aspectRatio, constant: 0)
        c.priority = UILayoutPriority(400)
        self.addConstraint(c)
    }
    
}

