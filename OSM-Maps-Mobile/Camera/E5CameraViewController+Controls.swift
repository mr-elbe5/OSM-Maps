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
    
    func enableControls(_ enable: Bool){
        //Log.debug("enable controls: \(enable)")
        captureModeControl.isEnabled = enable
        hdrVideoModeButton.isEnabled = enable && !isPhotoMode
        hdrVideoModeButton.isHidden = !enable || isPhotoMode
        flashModeButton.isEnabled = enable
        //Log.debug("current position: \(currentPosition)")
        backLensControl.isHidden = currentDevice?.position == .front || !enable
        backLensControl.isEnabled = currentDevice?.position == .back && enable
        captureButton.isEnabled = enable
        cameraButton.isEnabled = enable
    }
    
    func updateZoomLabel(){
        zoomLabel.text = "\(String(format: "%.1f", currentZoom))x"
    }
    
    func updateFlashButton(){
        switch flashMode{
        case .auto:
            flashModeButton.setImage(UIImage(systemName: "bolt.badge.automatic"), for: .normal)
        case .on:
            flashModeButton.setImage(UIImage(systemName: "bolt"), for: .normal)
        case .off:
            flashModeButton.setImage(UIImage(systemName: "bolt.slash"), for: .normal)
        @unknown default:
            flashModeButton.setImage(UIImage(systemName: "bolt"), for: .normal)
        }
    }
    
    func changeCamera() {
        if !isCaptureEnabled{
            return
        }
        enableControls(false)
        self.selectedMovieMode10BitDeviceFormat = nil
        var newVideoDevice: AVCaptureDevice? = nil
        if let position = currentDevice?.position{
            switch position {
            case .unspecified, .front:
                newVideoDevice = backDevices[currentBackCameraIndex]
            case .back:
                newVideoDevice = frontDevice
            @unknown default:
                newVideoDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
            }
        }
        if let newVideoDevice = newVideoDevice{
            changeVideoDevice(newVideoDevice, completion: { success in
                if success{
                    DispatchQueue.main.async {
                        self.enableControls(true)
                    }
                }
            })
        }
        else{
            Log.error("Could not change camera")
            DispatchQueue.main.async {
                self.enableControls(true)
            }
        }
    }
    
    func changeBackLens() {
        if !isCaptureEnabled{
            return
        }
        if currentDevice?.position != .back{
            Log.info("back lens cannot change when front lens is active")
            return
        }
        currentBackCameraIndex = backLensControl.selectedSegmentIndex
        enableControls(false)
        self.selectedMovieMode10BitDeviceFormat = nil
        let newVideoDevice = backDevices[currentBackCameraIndex]
        self.changeVideoDevice(newVideoDevice, completion: { success in
            if success{
                DispatchQueue.main.async {
                    self.enableControls(true)
                }
            }
        })
    }
    
    @objc func focusAndExposeTap() {
        if !isCaptureEnabled{
            return
        }
        let devicePoint = previewView.videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: tapGestureRecognizer.location(in: tapGestureRecognizer.view))
        focus(with: .autoFocus, exposureMode: .autoExpose, at: devicePoint, monitorSubjectAreaChange: true)
    }
    
    @objc func zoomTap() {
        if isCaptureEnabled, let currentDevice = currentDevice{
            switch pinchGestureRecognizer.state{
            case .began:
                currentZoomAtBegin = currentZoom
            case .ended:
                currentZoomAtBegin = 1.0
            case .changed:
                currentZoom = pinchGestureRecognizer.scale * currentZoomAtBegin
                currentZoom = min(max(1.0, currentZoom), currentMaxZoom)
                do{
                    try currentDevice.lockForConfiguration()
                    currentDevice.videoZoomFactor = currentZoom
                    currentDevice.unlockForConfiguration()
                    updateZoomLabel()
                }
                catch (let err){
                    Log.error(err.localizedDescription)
                }
            default:
                break
            }
        }
    }
    
    func capture() {
        if !isCaptureEnabled{
            return
        }
        if isPhotoMode{
            if !capturePhoto(){
                Log.error("could not capture photo")
                return
            }
        }
        else{
            toggleMovieRecording()
        }
    }
    
    func toggleHDRVideoMode() {
        if isCaptureEnabled, let currentDevice = currentDevice{
            if isPhotoMode{
                Log.info("use hdr only in video mode")
                return
            }
            sessionQueue.async {
                self.isHdrVideoMode = !self.isHdrVideoMode
                DispatchQueue.main.async {
                    if self.isHdrVideoMode {
                        do {
                            try currentDevice.lockForConfiguration()
                            currentDevice.activeFormat = self.selectedMovieMode10BitDeviceFormat!
                            currentDevice.unlockForConfiguration()
                        } catch {
                            Log.error("Could not lock device for configuration: \(error)")
                        }
                        self.hdrVideoModeButton.setImage(UIImage(systemName: "square.3.layers.3d.down.right"),for: .normal)
                    } else {
                        self.session.beginConfiguration()
                        self.session.sessionPreset = .high
                        self.session.commitConfiguration()
                        self.hdrVideoModeButton.setImage(UIImage(systemName: "square.3.layers.3d.down.right.slash"),for: .normal)
                    }
                }
            }
        }
    }
    
    func toggleFlashMode(){
        if !isCaptureEnabled{
            return
        }
        switch flashMode{
        case .auto:
            flashMode = .off
        case .off:
            flashMode = .on
        case .on:
            flashMode = .auto
        @unknown default:
            flashMode = .auto
        }
        photoSettings.flashMode = flashMode
        updateFlashButton()
    }
    
    func toggleCaptureMode(){
        if isCaptureEnabled, let currentDevice = currentDevice{
            isPhotoMode = !isPhotoMode
            //Log.debug("isPhotoMode = \(cameraSettings.isPhotoMode)")
            enableControls(false)
            if isPhotoMode {
                Log.info("running photo mode")
                enableControls(false)
                selectedMovieMode10BitDeviceFormat = nil
                sessionQueue.async {
                    self.session.beginConfiguration()
                    self.session.removeOutput(self.movieFileOutput!)
                    self.session.sessionPreset = .photo
                    self.movieFileOutput = nil
                    if self.configurePhotoOutput(){
                        self.session.commitConfiguration()
                        DispatchQueue.main.async {
                            self.enableControls(true)
                            self.updateZoomLabel()
                        }
                    }
                }
            } else {
                Log.info("running video mode")
                sessionQueue.async {
                    let movieFileOutput = AVCaptureMovieFileOutput()
                    if self.session.canAddOutput(movieFileOutput) {
                        self.session.beginConfiguration()
                        self.session.addOutput(movieFileOutput)
                        self.session.sessionPreset = .high
                        self.selectedMovieMode10BitDeviceFormat = self.tenBitVariantOfFormat(activeFormat: currentDevice.activeFormat)
                        if self.selectedMovieMode10BitDeviceFormat != nil {
                            DispatchQueue.main.async {
                                self.hdrVideoModeButton.isHidden = false
                                self.hdrVideoModeButton.isEnabled = true
                            }
                            if self.isHdrVideoMode {
                                do {
                                    try currentDevice.lockForConfiguration()
                                    currentDevice.activeFormat = self.selectedMovieMode10BitDeviceFormat!
                                    Log.debug("Setting 'x420' format \(String(describing: self.selectedMovieMode10BitDeviceFormat)) for video recording")
                                    currentDevice.unlockForConfiguration()
                                } catch {
                                    Log.error("Could not lock device for configuration: \(error)")
                                }
                            }
                        }
                        if let connection = movieFileOutput.connection(with: .video) {
                            if connection.isVideoStabilizationSupported {
                                connection.preferredVideoStabilizationMode = .auto
                            }
                        }
                        self.session.commitConfiguration()
                        self.movieFileOutput = movieFileOutput
                        DispatchQueue.main.async {
                            self.enableControls(true)
                            self.updateZoomLabel()
                        }
                    }
                }
            }
        }
    }
    
}
