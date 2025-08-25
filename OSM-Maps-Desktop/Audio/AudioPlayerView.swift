/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import AVFoundation

class AudioPlayerView : NSView, AVAudioPlayerDelegate{
    
    var player : AVPlayer
    var playerItem : AVPlayerItem? = nil
    
    var playProgress = NSProgressIndicator()
    var rewindButton = NSButton().asIconButton("repeat", color: .white)
    var playButton = NSButton().asIconButton("play.fill", color: .white)
    var volumeSlider = VolumeSlider()
    
    var timeObserverToken : Any? = nil
    
    private var _url : URL? = nil
    var url : URL?{
        get{
            return _url
        }
        set{
            _url = newValue
            playProgress.doubleValue = 0
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
        backgroundColor = .black
        setRoundedBorders()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView(){
        setRoundedBorders()
        playProgress.isIndeterminate = false
        playProgress.minValue = 0.0
        playProgress.maxValue = 1.0
        playProgress.backgroundColor = NSColor(.clear)
        addSubviewWithAnchors(playProgress, top: topAnchor, leading: leadingAnchor)
        rewindButton.target = self
        rewindButton.action = #selector(rewind)
        addSubviewWithAnchors(rewindButton, top: topAnchor, leading: playProgress.trailingAnchor)
            .height(20)
        playButton.target = self
        playButton.action = #selector(togglePlay)
        addSubviewWithAnchors(playButton, top: topAnchor, leading: rewindButton.trailingAnchor, trailing: trailingAnchor)
            .height(20)
        
        volumeSlider.target = self
        volumeSlider.action = #selector(updateVolume)
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
            player.volume = Float(volumeSlider.doubleValue)
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
        playProgress.doubleValue = 0
        rewindButton.isEnabled = false
        playButton.isEnabled = false
        volumeSlider.isEnabled = false
    }
    
    func addPeriodicTimeObserver(duration: CMTime) {
        let seconds = Float(CMTimeGetSeconds(duration))
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time, queue: .main) {time in
            DispatchQueue.main.async {
                let part = Float(CMTimeGetSeconds(time))
                self.playProgress.doubleValue = Double(part/seconds)
            }
        }
    }

    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    @objc func rewind(){
        player.rate = 0
        if let item = playerItem{
            item.seek(to: CMTime.zero, completionHandler: nil)
        }
        playButton.image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: nil)
        playProgress.doubleValue = 0
        rewindButton.isEnabled = false
        playButton.isEnabled = true
    }
    
    @objc func togglePlay(){
        if player.rate == 0{
            player.rate = 1
            playProgress.doubleValue = 0
            playButton.image = NSImage(systemSymbolName: "pause.fill", accessibilityDescription: nil)
            rewindButton.isEnabled = false
        }
        else{
            player.rate = 0
            playButton.image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: nil)
            rewindButton.isEnabled = true
        }
    }
    
    @objc func updateVolume(){
        self.player.volume = Float(self.volumeSlider.doubleValue)
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero, completionHandler: nil)
            player.rate = 0
            playButton.image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: nil)
            playButton.isEnabled = true
            rewindButton.isEnabled = false
        }
    }
    
}

class VolumeSlider : NSSlider{
    
    init(minValue: Double = 0.0, maxValue: Double = 10.0, value: Double = 1.0){
        super.init(frame: .zero)
        self.minValue = minValue
        self.maxValue = maxValue
        self.trackFillColor = .white
        self.doubleValue = value
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func volumeHeight(){
        height(25)
    }
    
}

