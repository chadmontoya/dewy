import UIKit
import Photos

enum PhotoLibraryPermission {
    enum PhotoLibraryError: Error, LocalizedError {
        case unauthorized
        case restricted
        
        var errorDescription: String? {
            switch self {
            case .unauthorized:
                return NSLocalizedString("You have not authorized photo library access", comment: "")
            case .restricted:
                return NSLocalizedString("Photo library access is restricted", comment: "")
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .unauthorized:
                return "Open Settings > Privacy and Security > Photos and turn on for this app."
            case .restricted:
                return "Photo library access is restricted by device settings or parental controls."
            }
        }
    }
    
    static func checkPermissions() -> PhotoLibraryError? {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .notDetermined:
            return nil
        case .restricted:
            return .restricted
        case .denied:
            return .unauthorized
        case .authorized, .limited:
            return nil
        @unknown default:
            return nil
        }
    }
}