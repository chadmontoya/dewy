import SwiftUI

struct TestView: View {
    @EnvironmentObject var photoPickerVM: PhotoPickerViewModel
    
    var body: some View {
        Text("test view")
    }
}
