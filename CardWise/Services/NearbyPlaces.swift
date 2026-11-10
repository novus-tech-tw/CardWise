import CoreLocation
import Foundation
import MapKit

/// A point of interest near the user, already mapped to a CardWise spending category.
struct NearbyPlace: Identifiable, Equatable {
    let id: String
    let name: String
    let category: SpendingCategory
    /// Meters from the user's location at search time.
    let distance: CLLocationDistance
    /// True when the category came from the user's own saved merchant preference.
    let isSavedCategory: Bool

    var formattedDistance: String {
        Measurement(value: distance, unit: UnitLength.meters)
            .formatted(.measurement(width: .abbreviated, usage: .road))
    }
}

/// Maps a nearby place to a spending category. Order: the user's saved choice, then
/// brand-specific categories that issuers reward separately (Costco, Target, Whole Foods…),
/// then Apple Maps' point-of-interest type, then generic name keywords.
enum NearbyCategoryResolver {
    static let brandCategories: Set<SpendingCategory> = [
        .wholesale, .amazon, .wholeFoods, .target, .walmart, .macys, .kohls, .gap, .nordstrom, .disney, .apple
    ]

    private static let placeTypeCategories: [MKPointOfInterestCategory: SpendingCategory] = [
        .restaurant: .dining, .cafe: .dining, .bakery: .dining, .brewery: .dining, .winery: .dining, .nightlife: .dining,
        .foodMarket: .grocery, .gasStation: .gas, .evCharger: .evCharging, .pharmacy: .drugstore, .hotel: .hotels,
        .airport: .airlines, .publicTransport: .transit, .carRental: .travel, .fitnessCenter: .fitness,
        .movieTheater: .entertainment, .theater: .entertainment, .amusementPark: .entertainment,
        .stadium: .entertainment, .museum: .entertainment, .zoo: .entertainment, .aquarium: .entertainment
    ]

    static func category(for poi: MKPointOfInterestCategory?) -> SpendingCategory? {
        poi.flatMap { placeTypeCategories[$0] }
    }

    /// Point-of-interest types searched; `.store` is included so brand stores are found.
    static let searchedCategories: [MKPointOfInterestCategory] = [
        .restaurant, .cafe, .bakery, .brewery, .winery, .nightlife, .foodMarket, .gasStation, .evCharger,
        .pharmacy, .hotel, .airport, .publicTransport, .carRental, .fitnessCenter, .movieTheater, .theater,
        .amusementPark, .stadium, .museum, .zoo, .aquarium, .store
    ]

    static func resolve(name: String, poi: MKPointOfInterestCategory?, saved: SpendingCategory?,
                        nameSuggestion: SpendingCategory?) -> (category: SpendingCategory, isSaved: Bool) {
        if let saved { return (saved, true) }
        if let nameSuggestion, brandCategories.contains(nameSuggestion) { return (nameSuggestion, false) }
        if let mapped = category(for: poi) { return (mapped, false) }
        return (nameSuggestion ?? .other, false)
    }
}

/// One-shot "where am I and what is around me" search. Location is requested only while the
/// app is in use, is never stored, and only the coordinate is sent to Apple Maps for the
/// nearby search.
@MainActor
final class NearbyPlacesSearcher: NSObject, ObservableObject, CLLocationManagerDelegate {
    enum State: Equatable {
        case idle
        case needsPermission
        case denied
        case locating
        case searching
        case loaded([NearbyPlace])
        case failed(String)
    }

    @Published private(set) var state: State = .idle
    static let radius: CLLocationDistance = 400
    static let maxResults = 25

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        state = Self.state(for: manager.authorizationStatus)
    }

    private static func state(for status: CLAuthorizationStatus) -> State {
        switch status {
        case .notDetermined: return .needsPermission
        case .denied, .restricted: return .denied
        default: return .idle
        }
    }

    func search() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            state = .denied
        default:
            state = .locating
            manager.requestLocation()
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                if self.state == .needsPermission || self.state == .denied { self.search() }
            default:
                self.state = Self.state(for: status)
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in await self.searchPlaces(near: location) }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let message = (error as? CLError)?.code == .denied ? nil : error.localizedDescription
        Task { @MainActor in
            self.state = message.map { .failed("Could not get your location: \($0)") } ?? .denied
        }
    }

    private func searchPlaces(near location: CLLocation) async {
        state = .searching
        let request = MKLocalPointsOfInterestRequest(center: location.coordinate, radius: Self.radius)
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: NearbyCategoryResolver.searchedCategories)
        do {
            let response = try await MKLocalSearch(request: request).start()
            state = .loaded(Self.places(from: response.mapItems, origin: location))
        } catch {
            let code = (error as? MKError)?.code
            state = code == .placemarkNotFound ? .loaded([]) : .failed("Nearby search failed: \(error.localizedDescription)")
        }
    }

    static func places(from items: [MKMapItem], origin: CLLocation) -> [NearbyPlace] {
        var seen = Set<String>()
        var result: [NearbyPlace] = []
        let preferences = MerchantPreferencesStore.shared
        for item in items {
            guard let name = item.name?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty,
                  let location = item.placemark.location else { continue }
            let key = MerchantOffer.merchantKey(name)
            guard seen.insert(key).inserted else { continue }
            let resolved = NearbyCategoryResolver.resolve(name: name, poi: item.pointOfInterestCategory,
                                                          saved: preferences.savedCategory(for: name),
                                                          nameSuggestion: MerchantDatabase.suggestCategory(for: name))
            result.append(NearbyPlace(id: key, name: name, category: resolved.category,
                                      distance: location.distance(from: origin), isSavedCategory: resolved.isSaved))
        }
        return Array(result.sorted { $0.distance < $1.distance }.prefix(maxResults))
    }
}
