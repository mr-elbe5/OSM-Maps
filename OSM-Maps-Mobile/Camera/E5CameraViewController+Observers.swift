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
    
    func addObservers() {
        let keyValueObservation = session.observe(\.isRunning, options: .new) { _, change in
            guard let isSessionRunning = change.newValue else { return }
            
            DispatchQueue.main.async {
                //Log.debug("observers: enable/disable buttons")
                self.cameraButton.isEnabled = isSessionRunning && AVCaptureDevice.DiscoverySession(deviceTypes: E5CameraViewController.discoverableDeviceTypes, mediaType: .video, position: .unspecified).uniqueDevicePositionsCount > 1
                self.captureButton.isEnabled = isSessionRunning
                self.captureModeControl.isEnabled = isSessionRunning
            }
        }
        keyValueObservations.append(keyValueObservation)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(subjectAreaDidChange),
                                               name: .AVCaptureDeviceSubjectAreaDidChange,
                                               object: currentDevice)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRuntimeError),
                                               name: .AVCaptureSessionRuntimeError,
                                               object: session)
        
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        
        for keyValueObservation in keyValueObservations {
            keyValueObservation.invalidate()
        }
        keyValueObservations.removeAll()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if !isCaptureEnabled{
            return
        }
        if context == &systemPreferredCameraContext {
            guard let systemPreferredCamera = change?[.newKey] as? AVCaptureDevice else { return }
            if let movieFileOutput = self.movieFileOutput, movieFileOutput.isRecording {
                return
            }
            if self.currentDevice == systemPreferredCamera {
                return
            }
            //Log.debug("changing device by observer")
            self.changeVideoDevice(systemPreferredCamera)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        switch UIDevice.current.orientation {
        case UIDeviceOrientation.portraitUpsideDown:
            previewView.videoPreviewLayer.connection?.videoOrientation = .portraitUpsideDown
        case UIDeviceOrientation.landscapeLeft:
            previewView.videoPreviewLayer.connection?.videoOrientation = .landscapeRight
        case UIDeviceOrientation.landscapeRight:
            previewView.videoPreviewLayer.connection?.videoOrientation = .landscapeLeft
        case UIDeviceOrientation.portrait:
            previewView.videoPreviewLayer.connection?.videoOrientation = .portrait
        default:
            break
        }
    }
    
    @objc func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        focus(with: .continuousAutoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
    }
    
    @objc func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        
        Log.error("Capture session runtime error: \(error)")
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.isSessionRunning {
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
                }
            }
        }
    }
    
    
}
