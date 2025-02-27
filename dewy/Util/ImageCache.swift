import SwiftUI

final class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private let queue = DispatchQueue(label: "com.dewy.imagecache")
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100 // 100MB
    }
    
    func image(for url: String) -> UIImage? {
        return cache.object(forKey: url as NSString)
    }
    
    func loadImage(from url: String) async throws -> UIImage? {
        if let cached = image(for: url) {
            return cached
        }
        
        guard let imageURL = URL(string: url) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: imageURL)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        if let image = UIImage(data: data) {
            insertImage(image, for: url)
            return image
        }
        
        return nil
    }
    
    func insertImage(_ image: UIImage, for url: String) {
        cache.setObject(image, forKey: url as NSString)
    }
    
    func removeImage(for url: String) {
        cache.removeObject(forKey: url as NSString)
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}
