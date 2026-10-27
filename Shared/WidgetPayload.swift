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

    func isStale(at date: Date) -> Bool {
        guard let validUntil else { return true }
        return date >= validUntil
    }
}
