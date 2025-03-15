import Foundation
import CoreLocation

struct OutfitService {
    func createOutfit(userId: UUID, imageUrl: String, location: CLLocationCoordinate2D, locationString: String, isPublic: Bool, selectedStyles: Set<Style>) async throws -> Outfit {
        let outfitParams = CreateOutfitParams(
            userId: userId,
            imageUrl: imageUrl,
            location: location,
            locationString: locationString,
            isPublic: isPublic,
            selectedStyles: selectedStyles
        )
        
        do {
            let outfit: Outfit = try await supabase
                .rpc("create_outfit_with_styles", params: outfitParams)
                .single()
                .execute()
                .value
            return outfit
        } catch {
            print("error creating outfit: \(error)")
            throw UploadOutfitError.outfitSaveFailed
        }
    }
    
    func deleteOutfit(outfitId: Int64) async throws {
        try await supabase
            .from("Outfits")
            .delete()
            .eq("id", value: String(outfitId))
            .execute()
    }
    
    func fetchUsersOutfits(userId: UUID) async -> [Outfit] {
        do {
            let outfits: [Outfit] = try await supabase
                .rpc("get_closet_outfits")
                .eq("user_id", value: userId)
                .execute()
                .value
            
            return outfits
        } catch {
            print("error fetching user \(userId) outfits: \(error)")
            return []
        }
    }
    
    func updateOutfit(outfitId: Int64, isPublic: Bool, styleIds: [Int64]) async throws -> Outfit {
        let updateParams = UpdateOutfitParams(
            outfitId: outfitId,
            isPublic: isPublic,
            styleIds: styleIds
        )
        
        let outfit: Outfit = try await supabase
            .rpc("update_outfit", params: updateParams)
            .single()
            .execute()
            .value
        
        return outfit
    }
}
