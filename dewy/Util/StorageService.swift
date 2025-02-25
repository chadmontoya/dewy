import SwiftUI

enum StorageError: Error {
    case invalidImageData
    case uploadFailed
    case urlGenerationFailed
}

struct StorageService {
    private let bucket: String
    
    init(bucket: String) {
        self.bucket = bucket
    }
    
    func uploadImage(_ image: UIImage, path: String, compressionQuality: CGFloat = 0.8) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            throw StorageError.invalidImageData
        }
        
        do {
            try await supabase.storage
                .from(bucket)
                .upload(path, data: imageData)
            
            let publicUrl: URL = try supabase.storage
                .from(bucket)
                .getPublicURL(path: path)
            
            return publicUrl.absoluteString
        } catch {
            throw StorageError.uploadFailed
        }
    }
    
    func generateFilePath(userId: UUID, fileName: String? = nil) -> String {
        let actualFilename = fileName ?? generateRandomFilename()
        return "\(userId)/\(actualFilename)"
    }
    
    private func generateRandomFilename() -> String {
        let uuid = UUID().uuidString
        let timestamp = Int(Date().timeIntervalSince1970)
        return "\(uuid)-\(timestamp).jpg"
    }
}
