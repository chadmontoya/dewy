import SwiftUI
import MapKit

struct Outfit {
    let id: Int64?
    let createDate: Date?
    let userId: UUID?
    let imageURL: String?
    let description: String? = ""
    let location: CLLocationCoordinate2D?
    let isPublic: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createDate = "created_at"
        case userId = "user_id"
        case imageURL = "image_url"
        case description
        case location
        case isPublic = "public"
    }
    
//    init(from decoder: Decoder) throws {
//        
//    }
//    
//    func encode(to encoder: any Encoder) throws {
//        
//    }
}
