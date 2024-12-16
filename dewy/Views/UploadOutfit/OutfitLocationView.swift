import SwiftUI
import MapKit

struct OutfitLocationView: View {
    @State var locationSearchVM = LocationSearchViewModel()
    
    var body: some View {
        Text("set outfit location")
    }
    
    private var mapDisplay: some View {
        ZStack {
            Map()
                .onMapCameraChange(frequency: .onEnd) { context in
                    let location = context.region.center
                    let locationRegion = MKCoordinateRegion(center: location, span: context.region.span)
                    
                }
        }
    }
}
