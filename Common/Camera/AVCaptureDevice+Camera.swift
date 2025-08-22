/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import Photos

extension AVCaptureDevice {
    
    static var defaultCameraDevice : AVCaptureDevice?{
        if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return dualCameraDevice
        } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return backCameraDevice
        } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            return frontCameraDevice
        }
        return nil
    }
    
    static var isCameraAvailable : Bool{
        defaultCameraDevice != nil
    }
        
    static func askCameraAuthorization(callback: @escaping (Result<Void, Error>) -> Void){
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .authorized:
            callback(.success(()))
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video){ granted in
                if granted{
                    callback(.success(()))
                }
                else{
                    callback(.failure(GenericError("notAutorized")))
                }
            }
            break
        default:
            callback(.failure(GenericError("notAutorized")))
            break
        }
    }
    
    static func askVideoAuthorization(callback: @escaping (Result<Void, Error>) -> Void){
        askCameraAuthorization(){ result  in
            switch result{
            case .success(()):
                askAudioAuthorization(){ _ in
                    callback(.success(()))
                }
                return
            case .failure:
                callback(.failure(GenericError("notAutorized")))
                return
            }
        }
    }
    
}

