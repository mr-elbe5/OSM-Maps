/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import AVFoundation
import CoreLocation
import Photos

extension CameraViewController{
    
    func toggleMovieRecording() {
        guard let movieFileOutput = self.movieFileOutput else {
            return
        }
        enableControls(false)
        if let window = self.view.window, let windowScene = window.windowScene {
            switch windowScene.interfaceOrientation {
            case .portrait: self.supportedInterfaceOrientations = .portrait
            case .landscapeLeft: self.supportedInterfaceOrientations = .landscapeLeft
            case .landscapeRight: self.supportedInterfaceOrientations = .landscapeRight
            case .portraitUpsideDown: self.supportedInterfaceOrientations = .portraitUpsideDown
            case .unknown: self.supportedInterfaceOrientations = .portrait
            default: self.supportedInterfaceOrientations = .portrait
            }
        }
        self.setNeedsUpdateOfSupportedInterfaceOrientations()
        sessionQueue.async {
            if !movieFileOutput.isRecording {
                Log.debug("start movie recording")
                DispatchQueue.main.async {
                    //Log.debug("movie recording: change capture button to recording")
                    self.captureButton.buttonState = .recording
                }
                if UIDevice.current.isMultitaskingSupported {
                    self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                }
                let movieFileOutputConnection = movieFileOutput.connection(with: .video)
                //movieFileOutputConnection?.videoRotationAngle = videoRotationAngle ?? .zero
                let availableVideoCodecTypes = movieFileOutput.availableVideoCodecTypes
                if availableVideoCodecTypes.contains(.hevc) {
                    movieFileOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc], for: movieFileOutputConnection!)
                }
                let outputFileName = NSUUID().uuidString
                let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
                movieFileOutput.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
                DispatchQueue.main.async {
                    //Log.debug("movie recording: enable only capture button")
                    self.captureButton.isEnabled = true
                }
            } else {
                movieFileOutput.stopRecording()
                Log.debug("stop movie recording")
                DispatchQueue.main.async {
                    //Log.debug("movie recording: reset capture button")
                    self.captureButton.buttonState = .normal
                    self.enableControls(true)
                }
            }
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        func cleanup() {
            let path = outputFileURL.path
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    Log.error("Could not remove file at url: \(outputFileURL)")
                }
            }
            if let currentBackgroundRecordingID = backgroundRecordingID {
                backgroundRecordingID = UIBackgroundTaskIdentifier.invalid
                if currentBackgroundRecordingID != UIBackgroundTaskIdentifier.invalid {
                    UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
                }
            }
        }
        var success = true
        if error != nil {
            Log.error("Movie file finishing error: \(String(describing: error))")
            success = (((error! as NSError).userInfo[AVErrorRecordingSuccessfullyFinishedKey] as AnyObject).boolValue)!
        }
        if success {
            let location = self.locationManager.location
            DispatchQueue.main.async{
                MainViewController.shared.videoCaptured(data: FileManager.default.readFile(url: outputFileURL)!)
            }
            PhotoLibrary.saveVideo(outputFileURL: outputFileURL, location: location, resultHandler: { localIdentifier in
                Log.debug("saved video with localIdentifier \(localIdentifier)")
                cleanup()
            })
        } else {
            cleanup()
        }
        DispatchQueue.main.async {
            //Log.debug("file output: enable buttons")
            self.cameraButton.isEnabled = AVCaptureDevice.DiscoverySession(deviceTypes: CameraViewController.discoverableDeviceTypes, mediaType: .video, position: .unspecified).uniqueDevicePositionsCount > 1
            self.captureButton.isEnabled = true
            self.captureModeControl.isEnabled = true
            self.supportedInterfaceOrientations = UIInterfaceOrientationMask.all
            self.setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }
    
}
