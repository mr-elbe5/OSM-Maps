/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import AVFoundation

class AudioRecorderViewController : ScrollViewController, AVAudioRecorderDelegate{
    
    var audioRecorder = AudioRecorderView()
    var commentField = UITextField()
    var saveButton = UIButton()
    
    override func loadView() {
        super.loadView()
        title = "audioRecording".localize()
        view.addSubviewFillingSafeArea(scrollView, insets: .zero)
        setupScrollView()
        loadScrollableSubviews()
        setupKeyboard()
    }
    
    func loadScrollableSubviews() {
        audioRecorder.setupView()
        audioRecorder.backgroundColor = .black
        audioRecorder.delegate = self
        contentView.addSubviewWithAnchors(audioRecorder, top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor)
        
        commentField.setDefaults(placeholder: "comment".localize())
        commentField.setKeyboardToolbar(doneTitle: "done".localize())
        contentView.addSubviewWithAnchors(commentField, top: audioRecorder.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor)
        
        saveButton.asTextButton("save".localize(), color: .systemBlue)
        saveButton.setTitleColor(.systemGray, for: .disabled)
        saveButton.addAction(UIAction(){ action in
            self.save()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(saveButton, top: commentField.bottomAnchor, bottom: contentView.bottomAnchor)
            .centerX(contentView.centerXAnchor)
        saveButton.isEnabled = false
    }
    
    func save(){
        let audioItem = AudioItem(coordinate: LocationStatus.shared.location.coordinate)
        audioItem.altitude = LocationStatus.shared.location.altitude
        audioItem.time = (audioRecorder.currentTime*100).rounded() / 100
        //Log.debug("AudioRecorderViewController saving url \(audioFile.fileURL)")
        if FileManager.default.copyFile(fromURL: audioRecorder.tmpFileURL, toURL: audioItem.url){
            AppData.shared.addItem(audioItem)
            audioRecorder.cleanup()
            self.close()
            MainViewController.shared.audioCaptured(audio: audioItem)
        }
        
    }
    
}

extension AudioRecorderViewController: AudioRecorderDelegate{
    
    func recordingFinished() {
        saveButton.isEnabled = true
    }
    
}
