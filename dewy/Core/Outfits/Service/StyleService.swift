import Foundation

struct StyleService {
    
    func fetchStyles() async -> [Style] {
        do {
            let styles: [Style] = try await supabase
                .from("Styles")
                .select()
                .execute()
                .value
            
            return styles
        } catch {
            print("error fetching styles \(error)")
            return []
        }
    }
}
