import Foundation
import Combine

struct FavoritePurchase: Codable, Equatable, Identifiable {
    var merchant: String
    var category: SpendingCategory
    var id: String { merchant.isEmpty ? "category:\(category.rawValue)" : "merchant:\(MerchantOffer.merchantKey(merchant))" }
    var title: String { merchant.isEmpty ? category.displayName : merchant }
}

/// Favorites are device preferences; wallet pins travel with each card's payload.
@MainActor
final class QuickAccessStore: ObservableObject {
    static let shared = QuickAccessStore()
    static let storageKey = "favoritePurchases"
    private let defaults: UserDefaults
    @Published private(set) var favorites: [FavoritePurchase]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        favorites = defaults.data(forKey: Self.storageKey)
            .flatMap { try? JSONDecoder().decode([FavoritePurchase].self, from: $0) } ?? []
    }

    func contains(_ item: FavoritePurchase) -> Bool { favorites.contains { $0.id == item.id } }

    func toggle(_ item: FavoritePurchase) {
        if contains(item) { favorites.removeAll { $0.id == item.id } } else { favorites.append(item) }
        persist()
    }

    func reset() { favorites = []; persist() }

    private func persist() {
        if let data = try? JSONEncoder().encode(favorites) { defaults.set(data, forKey: Self.storageKey) }
    }
}
