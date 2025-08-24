/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import AVFoundation

class AudioPlayerView : UIView, AVAudioPlayerDelegate{
    
    var player : AVPlayer
    var playerItem : AVPlayerItem? = nil
    
    var playProgress = UIProgressView()
    var rewindButton = UIButton().asIconButton("repeat", color: .label)
    var playButton = UIButton().asIconButton("play.fill", color: .label)
    var volumeSlider = VolumeSlider()
    
    var timeObserverToken : Any? = nil
    
    private var _url : URL? = nil
    var url : URL?{
        get{
            return _url
        }
        set{
            _url = newValue
            playProgress.setProgress(0, animated: false)
            rewindButton.isEnabled = false
            if _url == nil{
                playButton.isEnabled = false
            } else {
                playButton.isEnabled = true
            }
        }
    }
    
    override init(frame: CGRect) {
        self.player = AVPlayer()
        super.init(frame: frame)
        backgroundColor = .white
        setRoundedBorders()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(){
        setRoundedBorders()
        playProgress.setBackground(.white)
        addSubviewWithAnchors(playProgress, top: topAnchor, leading: leadingAnchor)
            .height(25)
        
        rewindButton.addAction(UIAction(){ action in
            self.rewind()
        }, for: .touchDown)
        addSubviewWithAnchors(rewindButton, top: topAnchor, leading: playProgress.trailingAnchor)
            .height(20)
        
        playButton.addAction(UIAction(){ action in
            self.togglePlay()
        }, for: .touchDown)
        addSubviewWithAnchors(playButton, top: topAnchor, leading: rewindButton.trailingAnchor, trailing: trailingAnchor)
            .height(20)
        
        volumeSlider.addAction(UIAction(){ action in
            self.player.volume = self.volumeSlider.value
        }, for: .valueChanged)
        addSubviewWithAnchors(volumeSlider, top: playProgress.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
            .height(25)
        rewindButton.isEnabled = false
        playButton.isEnabled = false
    }
    
    func enablePlayer(){
        if url != nil{
            let asset = AVURLAsset(url: url!)
            playerItem = AVPlayerItem(asset: asset)
            player.replaceCurrentItem(with: playerItem!)
            player.rate = 0
            player.volume = volumeSlider.value
            Task(){
                let duration = try await asset.load(.duration)
                addPeriodicTimeObserver(duration: duration)
            }
            rewindButton.isEnabled = false
            volumeSlider.isEnabled = true
        }
    }
    
    func disablePlayer(){
        player.rate = 0
        removePeriodicTimeObserver()
        playerItem = nil
        playProgress.setProgress(0, animated: false)
        rewindButton.isEnabled = false
        playButton.isEnabled = false
        volumeSlider.isEnabled = false
    }
    
    func addPeriodicTimeObserver(duration: CMTime) {
        let seconds = Float(CMTimeGetSeconds(duration))
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time,
                                                           queue: .main) {
                                                            [weak self] time in
                                                            let part = Float(CMTimeGetSeconds(time))
                                                            self?.playProgress.setProgress(part/seconds, animated: true)
        }
    }

    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    func rewind(){
        player.rate = 0
        if let item = playerItem{
            item.seek(to: CMTime.zero, completionHandler: nil)
        }
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playProgress.setProgress(0, animated: false)
        rewindButton.isEnabled = false
        playButton.isEnabled = true
    }
    
    func togglePlay(){
        if player.rate == 0{
            player.rate = 1
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            rewindButton.isEnabled = false
        }
        else{
            player.rate = 0
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            rewindButton.isEnabled = true
        }
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero, completionHandler: nil)
            player.rate = 0
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playButton.isEnabled = true
            rewindButton.isEnabled = false
        }
    }
    
}

class VolumeSlider : UISlider{
    
    init(minValue: Float = 0.0, maxValue: Float = 10.0, value: Float = 1.0){
        super.init(frame: .zero)
        minimumValue = minValue
        maximumValue = maxValue
        tintColor = .label
        minimumValueImage = UIImage(systemName: "speaker")
        maximumValueImage = UIImage(systemName: "speaker.3")
        thumbTintColor = .label
        self.value = value
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func volumeHeight(){
        height(25)
    }
    
}

