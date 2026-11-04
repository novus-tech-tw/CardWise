import Foundation

/// Each confirmation belongs to one catalog card and one exact set of rate terms.
struct PurchaseConditions: Codable, Equatable {
    var confirmedRewardIDs: Set<String> = []

    static func key(cardID: String, reward: CategoryReward) -> String { "\(cardID)|\(reward.id)" }

    func confirms(cardID: String, reward: CategoryReward) -> Bool {
        confirmedRewardIDs.contains(Self.key(cardID: cardID, reward: reward))
    }
}

struct PurchaseContext: Codable, Equatable {
    var merchant: String
    var category: SpendingCategory
    var amount: Double
    var conditions = PurchaseConditions()

    var isValid: Bool { amount.isFinite && amount > 0 }

    init(merchant: String, category: SpendingCategory, amount: Double, conditions: PurchaseConditions = PurchaseConditions()) {
        self.merchant = merchant
        self.category = category
        self.amount = amount
        self.conditions = conditions
    }

    init?(url: URL) {
        guard url.scheme == "cardwise", url.host == "recommend",
              let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
              let raw = items.first(where: { $0.name == "category" })?.value,
              let category = SpendingCategory(rawValue: raw),
              let text = items.first(where: { $0.name == "amount" })?.value,
              let amount = Double(text), amount.isFinite, amount > 0 else { return nil }
        let merchant = items.first(where: { $0.name == "merchant" })?.value ?? ""
        guard merchant.count <= 500 else { return nil }
        self.init(merchant: merchant, category: category, amount: amount)
    }
}

enum WidgetContextSource: String, Codable, CaseIterable, Identifiable {
    case configured, recent, favorite
    var id: String { rawValue }
    var title: String {
        switch self {
        case .configured: return "Custom purchase"
        case .recent: return "Last checked purchase"
        case .favorite: return "Favorite merchant or category"
        }
    }
}
