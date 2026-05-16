/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import AVFoundation
import OSLog

protocol AudioRecorderDelegate{
    func recordingFinished()
}

class AudioRecorderView : UIView, AVAudioRecorderDelegate{
    
    var audioRecorder: AVAudioRecorder? = nil
    var isRecording: Bool = false
    var currentTime: Double = 0.0
    
    var recordButton = CaptureButton()
    var timeLabel = UILabel()
    var progress = AudioProgressView()
    var player = AudioPlayerView()
    
    var tmpFileName = "tmpaudio.m4a"
    var tmpFileURL : URL
    
    var delegate: AudioRecorderDelegate? = nil
    
    init(){
        tmpFileURL = URL.temporaryDirectory.appendingPathComponent(tmpFileName)
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        setRoundedBorders()
        timeLabel.textAlignment = .center
        timeLabel.textColor = .white
        addSubviewWithAnchors(timeLabel, top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor)
        
        addSubviewWithAnchors(progress, top: timeLabel.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor)
            .setBackground(.white).setRoundedBorders()
        progress.setupView()
        
        addSubviewWithAnchors(player, top: progress.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor)
            .setBackground(.white)
        player.setupView()
        player.disablePlayer()
        
        recordButton.addAction(UIAction(){ action in
            self.toggleRecording()
        }, for: .touchUpInside)
        addSubviewWithAnchors(recordButton, top: player.bottomAnchor, bottom: bottomAnchor)
            .centerX(centerXAnchor)
            .width(50)
            .height(50)
        recordButton.isEnabled = false
        
        updateTime(time: 0.0)
        AVCaptureDevice.askAudioAuthorization(){ result in
            self.enableRecording()
        }
    }
    
    func enableRecording(){
        AudioSession.enableRecording(){result in
            switch result{
            case .success:
                DispatchQueue.main.async {
                    self.recordButton.isEnabled = true
                }
            default:
                break
            }
        }
    }
    
    func startRecording() {
        player.disablePlayer()
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVNumberOfChannelsKey: 1,
        ]
        //Logger.debug("AudioRecorderViewController recording on url \(tmpFileURL)")
        do{
            audioRecorder = try AVAudioRecorder(url: tmpFileURL, settings: settings)
            if let recorder = audioRecorder{
                recorder.isMeteringEnabled = true
                recorder.delegate = self
                recorder.record()
                isRecording = true
                self.recordButton.buttonState = .recording
                DispatchQueue.global(qos: .userInitiated).async {
                    repeat{
                        recorder.updateMeters()
                        DispatchQueue.main.async {
                            self.currentTime = recorder.currentTime
                            self.updateTime(time: self.currentTime)
                            self.updateProgress(decibels: recorder.averagePower(forChannel: 0))
                        }
                        // 1/10s
                        usleep(100000)
                    } while self.isRecording
                }
            }
        }
        catch{
            recordButton.isEnabled = false
        }
    }
    
    func finishRecording(success: Bool) {
        isRecording = false
        audioRecorder?.stop()
        audioRecorder = nil
        if success {
            //Logger.debug("AudioRecorderViewController playing on url \(tmpFileURL)")
            player.url = tmpFileURL
            player.enablePlayer()
            delegate?.recordingFinished()
        } else {
            player.disablePlayer()
            player.url = nil
        }
        recordButton.buttonState = .normal
    }
    
    func updateTime(time: Double){
        timeLabel.text = String(format: "%.02f s", time)
    }
    
    func updateProgress(decibels: Float){
        progress.setProgress((min(max(-60.0, decibels),0) + 60.0) / 60.0)
    }
    
    func toggleRecording() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: flag)
        }
    }
    
    func cleanup() {
        if FileManager.default.fileExists(atPath: tmpFileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: tmpFileURL.path)
            } catch let err{
                Logger.error("AudioRecorderViewController Could not remove file at url: \(String(describing: tmpFileURL))", err)
            }
        }
    }
    
}

class AudioSession{
    
    static var isEnabled = false
    
    static func enableRecording(callback: @escaping (Result<Void, Error>) -> Void){
        if isEnabled{
            callback(.success(()))
        }
        else{
            AVCaptureDevice.askAudioAuthorization(){ result in
                switch result{
                case .success(()):
                    do {
                        let session = AVAudioSession.sharedInstance()
                        try session.setCategory(.playAndRecord, mode: .default)
                        try session.overrideOutputAudioPort(.speaker)
                        try session.setActive(true)
                        AVCaptureDevice.askAudioAuthorization(){ result in
                            switch result{
                            case .success(()):
                                isEnabled = true
                                callback(.success(()))
                                return
                            case .failure:
                                callback(.failure(NSError()))
                                return
                            }
                        }
                    } catch {
                        callback(.failure(NSError()))
                    }
                    return
                case .failure:
                    callback(.failure(NSError()))
                    return
                }
            }
        }
    }
    
}

class AudioProgressView : UIView{
    
    var lowLabel = UIImageView(image: UIImage(systemName: "speaker"))
    var progress = UIProgressView()
    var loudLabel = UIImageView(image: UIImage(systemName: "speaker.3"))
    
    func setupView() {
        addSubviewWithAnchors(lowLabel, top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor)
        progress.progressTintColor = .systemRed
        progress.progress = 0.0
        addSubviewWithAnchors(progress, top: topAnchor, leading: lowLabel.trailingAnchor, bottom: bottomAnchor)
        addSubviewWithAnchors(loudLabel, top: topAnchor, leading: progress.trailingAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
    }
    
    func setProgress(_ value: Float){
        progress.setProgress(value, animated: true)
    }
    
}
