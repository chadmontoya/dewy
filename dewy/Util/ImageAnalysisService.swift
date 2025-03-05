import SwiftUI
import Alamofire

enum ImageAnalysisError: LocalizedError {
    case invalidImage
    case nsfwContentDetected
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "unable to process image"
        case .networkError(let message):
            return "network error: \(message)"
        case .nsfwContentDetected:
            return "inappropriate content detected"
        }
    }
}

struct ImageAnalysisResponse: Decodable {
    let isNsfw: Bool
    let details: Details
    
    struct Details: Decodable {
        let adult: String
        let violence: String
        let racy: String
        let medical: String
        let spoof: String
    }
    
    enum CodingKeys: String, CodingKey {
        case isNsfw = "is_nsfw"
        case details
    }
}

final class ImageAnalysisService {
    static let shared = ImageAnalysisService()
    
    private let baseURL: String
    
    private init() {
        self.baseURL = "https://detect-nsfw-function-876610507421.us-west2.run.app"
    }
    
    func analyzeImage(_ image: UIImage) async throws -> ImageAnalysisResponse {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw ImageAnalysisError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.upload(
                multipartFormData: { multipart in
                    multipart.append(
                        imageData,
                        withName: "file",
                        fileName: "image.jpg",
                        mimeType: "image/jpeg"
                    )
                },
                to: "\(baseURL)",
                headers: ["Accept": "application/json"]
            )
            .validate()
            .responseDecodable(of: ImageAnalysisResponse.self) { response in
                switch response.result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure(let error):
                    continuation.resume(throwing: ImageAnalysisError.networkError(error.localizedDescription))
                }
            }
        }
    }
}
