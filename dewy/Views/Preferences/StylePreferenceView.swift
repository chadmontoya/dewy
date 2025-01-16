import SwiftUI

struct StylePreferenceView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var preferencesVM: PreferencesViewModel
    
    var body: some View {
        Text("hello world")
    }
}
