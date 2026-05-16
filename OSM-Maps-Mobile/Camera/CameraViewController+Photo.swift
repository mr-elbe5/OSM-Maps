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
    
    func configurePhotoOutput() -> Bool {
        if isCaptureEnabled, let supportedMaxPhotoDimensions = currentDevice?.activeFormat.supportedMaxPhotoDimensions{
            if let largestDimension = supportedMaxPhotoDimensions.last{
                self.photoOutput.maxPhotoDimensions = largestDimension
            }
            self.photoOutput.isLivePhotoCaptureEnabled = false
            self.photoOutput.maxPhotoQualityPrioritization = .quality
            let photoSettings = self.setUpPhotoSettings()
            DispatchQueue.main.async {
                self.photoSettings = photoSettings
            }
            return true
        }
        return false
    }
    
    func capturePhoto() -> Bool{
        if isCaptureEnabled, self.photoSettings != nil{
            let photoSettings = AVCapturePhotoSettings(from: self.photoSettings)
            let photoCaptureProcessor = PhotoCaptureProcessor(with: photoSettings, completionHandler: { photoCaptureProcessor in
                self.sessionQueue.async {
                    self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = nil
                }
            })
            self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = photoCaptureProcessor
            self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureProcessor)
            return true
        }
        return false
    }
    
}

class PhotoCaptureProcessor: NSObject {
    
    private(set) var requestedPhotoSettings: AVCapturePhotoSettings
    
    lazy var context = CIContext()
    private let completionHandler: (PhotoCaptureProcessor) -> Void
    private var photoData: Data?
    
    init(with requestedPhotoSettings: AVCapturePhotoSettings, completionHandler: @escaping (PhotoCaptureProcessor) -> Void) {
        self.requestedPhotoSettings = requestedPhotoSettings
        self.completionHandler = completionHandler
    }
    
}

extension PhotoCaptureProcessor: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            Logger.error("Error capturing photo: \(error)")
            return
        }
        self.photoData = photo.fileDataRepresentation()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        if let error = error {
            Logger.error("Error capturing photo: \(error)")
            completionHandler(self)
            return
        }
        guard photoData != nil else {
            Logger.error("No photo data resource")
            completionHandler(self)
            return
        }
        DispatchQueue.main.async{
            MainViewController.shared.photoCaptured(data: self.photoData!)
        }
        PhotoLibrary.savePhoto(photoData: self.photoData!, fileType: self.requestedPhotoSettings.processedFileType, location: LocationStatus.shared.location, resultHandler: { s in
            self.completionHandler(self)
        })
    }
}

