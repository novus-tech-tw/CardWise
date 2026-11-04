import Foundation
import Combine

@MainActor
final class RecentPurchaseStore: ObservableObject {
    static let shared = RecentPurchaseStore()
    static let storageKey = "lastCheckedPurchase"
    private let defaults: UserDefaults
    @Published private(set) var purchase: PurchaseContext?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        purchase = defaults.data(forKey: Self.storageKey)
            .flatMap { try? JSONDecoder().decode(PurchaseContext.self, from: $0) }
    }

    func save(_ context: PurchaseContext) {
        guard context.isValid, context != purchase, let data = try? JSONEncoder().encode(context) else { return }
        purchase = context
        defaults.set(data, forKey: Self.storageKey)
    }

    func reset() { purchase = nil; defaults.removeObject(forKey: Self.storageKey) }
}
