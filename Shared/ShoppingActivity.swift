import ActivityKit
import AppIntents
import Foundation

/// Live Activity contract shared by the app (which starts and updates it) and the widget
/// extension (which renders it). Everything is computed on-device; nothing is pushed remotely.
struct ShoppingActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var cardName: String
        var cardColor: String
        var rewardRate: String
        var estimatedReward: String
        /// Short secondary line, e.g. the runner-up card or a cap/activation caveat.
        var note: String?
    }

    var merchant: String
    /// `SpendingCategory.rawValue`, kept as a string because the widget does not compile the model layer.
    var categoryID: String
    var categoryName: String
    var categoryIcon: String
    var amount: Double

    /// Merchant when known, otherwise the category name.
    var title: String {
        let trimmed = merchant.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? categoryName : trimmed
    }

    /// Reopens the same purchase in the Recommend tab (`PurchaseContext(url:)` parses it).
    var recommendURL: URL? {
        var components = URLComponents()
        components.scheme = "cardwise"
        components.host = "recommend"
        components.queryItems = [URLQueryItem(name: "merchant", value: merchant),
                                 URLQueryItem(name: "category", value: categoryID),
                                 URLQueryItem(name: "amount", value: String(amount))]
        return components.url
    }
}

/// Ends every CardWise shopping Live Activity. Runs in the app process, so the Lock Screen
/// button and Siri share one implementation.
struct EndShoppingModeIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "End Shopping Mode"
    static var description = IntentDescription("Remove the CardWise best-card card from the Lock Screen.")

    func perform() async throws -> some IntentResult {
        for activity in Activity<ShoppingActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        return .result()
    }
}
