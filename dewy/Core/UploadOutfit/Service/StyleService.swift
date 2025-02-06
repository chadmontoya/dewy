import Foundation

struct StyleService {
    func fetchStyles() async throws -> [Style] {
        var styles: [Style] = []
        styles = try await supabase
            .from("Styles")
            .select()
            .execute()
            .value
        return styles
    }
}
