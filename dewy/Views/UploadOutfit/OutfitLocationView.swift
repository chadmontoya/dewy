import SwiftUI
import MapKit

struct OutfitLocationView: View {
    @EnvironmentObject var uploadOutfitVM: UploadOutfitViewModel
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var currentCity: String = ""
    @State private var searchCity: String = ""
    
    @State var locationSearchVM = LocationSearchViewModel()

    var body: some View {
        MapView(location: $uploadOutfitVM.location)
    }
}
