import SwiftUI
import MapKit

@Observable
class LocationViewModel: NSObject {
    
    var query: String = "" {
        didSet {
            handleSearchFragment(query)
        }
    }
    
    var results: [LocationResult] = []
    var status: SearchStatus = .idle
    var completer: MKLocalSearchCompleter
    
    init(filter: MKPointOfInterestFilter = .excludingAll, region: MKCoordinateRegion = MKCoordinateRegion(.world), types: MKLocalSearchCompleter.ResultType = [.query, .address]) {
        
        completer = MKLocalSearchCompleter()
        
        super.init()
        
        completer.delegate = self
        completer.pointOfInterestFilter = filter
        completer.region = region
        completer.resultTypes = types
    }
    
    private func handleSearchFragment(_ fragment: String) {
        self.status = .searching
        
        if !fragment.isEmpty {
            self.completer.queryFragment = fragment
        }
        else {
            self.status = .idle
            self.results = []
        }
    }
}

extension LocationViewModel: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results.filter { result in
            guard result.title.contains(",") || !result.subtitle.isEmpty else { return false }
            guard !result.subtitle.contains("Nearby") else { return false }
            return true
        }
        .map({ result in
            LocationResult(title: result.title, subtitle: result.subtitle)
        })
        self.status = .result
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        self.status = .error(error.localizedDescription)
    }
}

struct LocationResult: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var subtitle: String
}

enum SearchStatus: Equatable {
    case idle
    case searching
    case error(String)
    case result
}

struct CityResult: Hashable {
    var city: String
    var country: String
    var latitude: Double
    var longitude: Double
}
