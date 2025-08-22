/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import Photos

extension AVCaptureDevice {
    
    static func askAudioAuthorization(callback: @escaping (Result<Void, Error>) -> Void){
        switch AVCaptureDevice.authorizationStatus(for: .audio){
        case .authorized:
            callback(.success(()))
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio){ granted in
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
    
}

