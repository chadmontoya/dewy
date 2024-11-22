import SwiftUI

struct EditProfileView: View {
    @Environment(\..dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Name", text: .constant(""))
                    TextField("Bio", text: .constant(""))
                    DatePicker("Birthday", selection: .constant(Date()), displayedComponents: .date)
                }
                
                Section("Photos") {
                    Button("Add Photos") {
                        
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        dismiss()
                    }
                }
            }
        }
    }
}
