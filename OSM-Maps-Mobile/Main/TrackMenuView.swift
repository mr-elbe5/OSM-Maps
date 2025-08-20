/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

class TrackMenuView: UIView {
    
    var startTrackingButton = UIButton().asIconButton("figure.walk.departure", color: .darkText)
    var trackingIcon = UIImageView(image: UIImage(systemName: "figure.walk.motion"))
    var pauseResumeButton = UIButton().asIconButton("pause.circle", color: .darkText)
    var stopButton = UIButton().asIconButton("stop.circle", color: .darkText)
    
    let insets = UIEdgeInsets(top: 20, left: 5, bottom: 20, right: 5)
    
    func setup(){
        setBackground(.transparentColor)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        startTrackingButton.addAction(UIAction(){ action in
            if !TrackRecorder.shared.isTracking{
                MainViewController.shared.startTracking()
                self.setupForTracking()
            }
        }, for: .touchDown)
        trackingIcon.tintColor = .darkGray
        pauseResumeButton.addAction(UIAction(){ action in
            self.togglePauseResume()
        }, for: .touchDown)
        stopButton.menu = getEndTrackingMenu()
        stopButton.showsMenuAsPrimaryAction = true
        setupForIdle()
    }
    
    func setupForIdle(){
        removeAllSubviews()
        addSubviewBelow(startTrackingButton, insets: insets)
            .connectToBottom(of: self, inset: 20)
    }
    
    func setupForTracking(){
        removeAllSubviews()
        addSubviewBelow(trackingIcon, insets: insets)
        addSubviewBelow(pauseResumeButton, upperView: trackingIcon, insets: insets)
        addSubviewBelow(stopButton, upperView: pauseResumeButton, insets: insets)
            .connectToBottom(of: self, inset: 20)
    }
    
    func startTracking(){
        MainViewController.shared.startTracking()
        setupForTracking()
    }
    
    func togglePauseResume(){
        MainViewController.shared.togglePauseTracking()
        pauseResumeButton.asIconButton(TrackRecorder.shared.isRecording ? "pause.circle" : "play.circle", color: .darkText)
    }
    
    func getEndTrackingMenu() -> UIMenu{
        var actions = Array<UIAction>()
        actions.append(UIAction(title: "saveTrack".localize(), image: UIImage(systemName: "figure.walk.arrival")){ action in
            MainViewController.shared.saveTrack()
            self.setupForIdle()
        })
        actions.append(UIAction(title: "cancelTrack".localize(), image: UIImage(systemName: "trash")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)){ action in
            MainViewController.shared.cancelTrack()
            self.setupForIdle()
        })
        return UIMenu(title: "", children: actions)
    }
    
}






