import Foundation
import Combine

/// Device-local preferences, shared by every purchase entry point.
@MainActor
final class MerchantPreferencesStore: ObservableObject {
    static let shared = MerchantPreferencesStore()
    static let storageKey = "merchantCategoryPreferences"
    private let defaults: UserDefaults
    @Published private(set) var categories: [String: SpendingCategory]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        categories = defaults.data(forKey: Self.storageKey)
            .flatMap { try? JSONDecoder().decode([String: SpendingCategory].self, from: $0) } ?? [:]
    }

    func savedCategory(for merchant: String) -> SpendingCategory? {
        categories[MerchantOffer.merchantKey(merchant)]
    }

    func category(for merchant: String) -> SpendingCategory? {
        savedCategory(for: merchant) ?? MerchantDatabase.suggestCategory(for: merchant)
    }

    func save(_ category: SpendingCategory, for merchant: String) {
        let key = MerchantOffer.merchantKey(merchant)
        guard !key.isEmpty else { return }
        categories[key] = category
        persist()
    }

    func remove(_ merchant: String) {
        categories.removeValue(forKey: MerchantOffer.merchantKey(merchant))
        persist()
    }

    func reset() { categories = [:]; persist() }

    private func persist() {
        if let data = try? JSONEncoder().encode(categories) { defaults.set(data, forKey: Self.storageKey) }
    }
}
