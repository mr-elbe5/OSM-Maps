/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import AVFoundation
import AVKit

class VideoPresenterView: PresenterView {
    
    var items = VideoItemList()
    
    var videoPlayer = AVPlayerView()
    
    override var itemCount: Int{
        items.count
    }
    
    deinit{
        videoPlayer.player = nil
    }
    
    override func setupItemView(){
        videoPlayer.controlsStyle = .floating
        addSubviewFilling(videoPlayer)
    }
    
    func setVideos(_ items: VideoItemList){
        self.items = items
        setVideoView(item: items.first)
        currentIdx = 0
        checkButtons()
    }
    
    func setVideo(item: VideoItem){
        var arr = VideoItemList()
        arr.append(item)
        setVideos(arr)
        checkButtons()
    }
    
    func setVideoView(item: VideoItem?){
        videoPlayer.player = nil
        videoPlayer.isHidden = true
        if let item = item{
            videoPlayer.isHidden = false
            videoPlayer.player = AVPlayer(url: item.url)
        }
    }
    
    override func setCurrentItem(){
        setVideoView(item: items[currentIdx])
    }
    
}




