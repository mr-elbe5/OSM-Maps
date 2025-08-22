/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import AVFoundation
import CoreLocation
import Photos

extension E5CameraViewController{
    
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
                Log.error("Default video device is unavailable.")
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
                Log.error("Couldn't add video device input to the session.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            Log.error("Couldn't create video device input: \(error)")
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
                Log.error("Could not add audio device input to the session")
            }
        } catch {
            Log.error("Could not create audio device input: \(error)")
        }
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            //live photos disabled
            photoOutput.isLivePhotoCaptureEnabled = false
            photoOutput.maxPhotoQualityPrioritization = .quality
            if !self.configurePhotoOutput(){
                Log.error("Could not configure photo output")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } else {
            Log.error("Could not add photo output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        session.commitConfiguration()
    }
    
    
}
