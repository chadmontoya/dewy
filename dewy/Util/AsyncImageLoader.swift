import SwiftUI

class AsyncImageLoader {
    
    func downloadImage(urlString: String) async throws -> UIImage? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        return handleResponse(data: data, response: response)
    }
    
    private func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard
            let data = data,
            let image = UIImage(data: data),
            let response = response as? HTTPURLResponse,
            (200...299).contains(response.statusCode) else {
            return nil
        }
        return image
    }
}
