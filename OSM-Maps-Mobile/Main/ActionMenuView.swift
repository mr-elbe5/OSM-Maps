/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

class ActionMenuView: UIView {
    
    var startTrackingButton = UIButton().asIconButton("figure.walk.departure", color: .darkText)
    var trackingIcon = UIImageView(image: UIImage(systemName: "figure.walk.motion"))
    var pauseResumeButton = UIButton().asIconButton("pause.circle", color: .darkText)
    var stopButton = UIButton().asIconButton("stop.circle", color: .darkText)
    var cameraButton = UIButton().asIconButton("camera", color: .darkText)
    var audioButton = UIButton().asIconButton("microphone", color: .darkText)
    var routeButton = UIButton().asIconButton("point.topright.arrow.triangle.backward.to.point.bottomleft.scurvepath", color: .darkText)
    
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
        cameraButton.addAction(UIAction(){ action in
            self.openCamera()
        }, for: .touchDown)
        audioButton.addAction(UIAction(){ action in
            self.openAudioRecorder()
        }, for: .touchDown)
        routeButton.addAction(UIAction(){ action in
            self.createRoute()
        }, for: .touchDown)
        setupForIdle()
    }
    
    func setupForIdle(){
        removeAllSubviews()
        addSubviewBelow(startTrackingButton, insets: insets)
        addSubviewBelow(cameraButton, upperView: startTrackingButton, insets: insets)
        addSubviewBelow(audioButton, upperView: cameraButton, insets: insets)
        addSubviewBelow(routeButton, upperView: audioButton, insets: insets)
            .connectToBottom(of: self, inset: 20)
    }
    
    func setupForTracking(){
        removeAllSubviews()
        addSubviewBelow(trackingIcon, insets: insets)
        addSubviewBelow(pauseResumeButton, upperView: trackingIcon, insets: insets)
        addSubviewBelow(stopButton, upperView: pauseResumeButton, insets: insets)
        addSubviewBelow(cameraButton, upperView: stopButton, insets: insets)
        addSubviewBelow(audioButton, upperView: cameraButton, insets: insets)
        addSubviewBelow(routeButton, upperView: audioButton, insets: insets)
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
            TrackRecorder.shared.saveTrack(){ result in
                if result{
                    self.setupForIdle()
                }
            }
        })
        actions.append(UIAction(title: "cancelTrack".localize(), image: UIImage(systemName: "trash")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)){ action in
            MainViewController.shared.cancelTrack()
            self.setupForIdle()
        })
        return UIMenu(title: "", children: actions)
    }
    
    func openCamera(){
        MainViewController.shared.openCamera()
    }
    
    func openAudioRecorder(){
        MainViewController.shared.openAudioRecorder()
    }
    
    func createRoute(){
        MainViewController.shared.createRoute()
    }
    
}






