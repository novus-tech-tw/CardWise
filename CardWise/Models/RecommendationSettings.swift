import Foundation
import Combine

enum RecommendationRanking: String, Codable, CaseIterable, Identifiable {
    case signupFirst, purchaseReward

    var id: String { rawValue }
    var title: String { self == .signupFirst ? "Sign-up bonus first" : "Highest purchase reward" }
    var explanation: String {
        self == .signupFirst
            ? "Cards with an unfinished, unexpired sign-up goal come first. Purchase reward breaks ties; bonus value is not added to the estimate."
            : "Cards are sorted by the estimated reward for this purchase. Sign-up goals are shown separately."
    }
}

struct RecommendationSettings: Codable, Equatable {
    var ranking: RecommendationRanking = .signupFirst
    /// Cents per point, keyed by catalog card ID. Cash percentages never use this value.
    var pointValues: [String: Double] = [:]
    var widgetCategory: SpendingCategory = .dining
    var widgetMerchant = ""
    var widgetAmount: Double = 100
    var widgetConditionalRewards = false

    func dollarsPerPoint(for cardID: String) -> Double {
        guard let value = pointValues[cardID], value.isFinite, value > 0, value <= 100 else {
            return RewardConstants.defaultPointsValueCPP
        }
        return value / 100
    }

    var effectiveWidgetCategory: SpendingCategory {
        MerchantDatabase.suggestCategory(for: widgetMerchant) ?? widgetCategory
    }

    var validWidgetAmount: Double {
        widgetAmount.isFinite && widgetAmount > 0 ? widgetAmount : 100
    }
}

@MainActor
final class RecommendationSettingsStore: ObservableObject {
    static let shared = RecommendationSettingsStore()
    static let storageKey = "recommendationSettings"
    private let defaults: UserDefaults
    @Published var settings: RecommendationSettings {
        didSet {
            if let data = try? JSONEncoder().encode(settings) {
                defaults.set(data, forKey: Self.storageKey)
            }
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        settings = defaults.data(forKey: Self.storageKey)
            .flatMap { try? JSONDecoder().decode(RecommendationSettings.self, from: $0) } ?? RecommendationSettings()
    }

    func reset() { settings = RecommendationSettings() }
}
