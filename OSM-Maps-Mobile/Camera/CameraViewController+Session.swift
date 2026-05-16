/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import AVFoundation
import CoreLocation
import Photos
import OSLog

extension CameraViewController{
    
    func configureSession() {
        if setupResult != .success {
            return
        }
        session.beginConfiguration()
        session.sessionPreset = .photo
        do {
            var defaultVideoDevice: AVCaptureDevice? = nil
            let userDefaults = UserDefaults.standard
            let backVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .back)
            if let device = backVideoDeviceDiscoverySession.devices.first{
                defaultVideoDevice = device
            }
            else{
                let frontVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .front)
                if let device = frontVideoDeviceDiscoverySession.devices.first{
                    defaultVideoDevice = device
                }
            }
            userDefaults.set(true, forKey: "setInitialUserPreferredCamera")
            guard let videoDevice = defaultVideoDevice else {
                Logger.error("Default video device is unavailable.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            AVCaptureDevice.self.addObserver(self, forKeyPath: "systemPreferredCamera", options: [.new], context: &systemPreferredCameraContext)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.currentDeviceInput = videoDeviceInput
                self.isCaptureEnabled = true
                if self.resetZoomForNewDevice(){
                    DispatchQueue.main.async {
                        self.updateZoomLabel()
                    }
                }
            } else {
                Logger.error("Couldn't add video device input to the session.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            Logger.error("Couldn't create video device input: \(error)")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        do {
            let audioDevice = AVCaptureDevice.default(for: .audio)
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
            
            if session.canAddInput(audioDeviceInput) {
                session.addInput(audioDeviceInput)
            } else {
                Logger.error("Could not add audio device input to the session")
            }
        } catch {
            Logger.error("Could not create audio device input: \(error)")
        }
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            //live photos disabled
            photoOutput.isLivePhotoCaptureEnabled = false
            photoOutput.maxPhotoQualityPrioritization = .quality
            if !self.configurePhotoOutput(){
                Logger.error("Could not configure photo output")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } else {
            Logger.error("Could not add photo output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        session.commitConfiguration()
    }
    
    
}
