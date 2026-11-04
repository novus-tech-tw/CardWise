import Foundation

/// Shared contract between the app and its widget. Optional context fields decode older saved payloads.
struct WidgetPayload: Codable, Equatable {
    let topCategory: String
    let topCategoryIcon: String
    let bestCard: String
    let bestCardColor: String
    let rewardRate: String
    let rotatingCategories: [String]
    let rotatingCard: String?
    let spendingThisMonth: Double
    let rewardsThisMonth: Double
    var purchaseContext: String?
    var explanation: String?
    var generatedAt: Date?
    var validUntil: Date?

    var purchaseMerchant: String?
    var purchaseCategory: String?
    var purchaseAmount: Double?

    var recommendationURL: URL? {
        guard let purchaseCategory, let purchaseAmount, purchaseAmount.isFinite, purchaseAmount > 0 else { return nil }
        var components = URLComponents()
        components.scheme = "cardwise"
        components.host = "recommend"
        components.queryItems = [URLQueryItem(name: "merchant", value: purchaseMerchant ?? ""),
                                 URLQueryItem(name: "category", value: purchaseCategory),
                                 URLQueryItem(name: "amount", value: String(purchaseAmount))]
        return components.url
    }

    func isStale(at date: Date) -> Bool {
        guard let validUntil else { return true }
        return date >= validUntil
    }
}
