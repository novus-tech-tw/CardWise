import Foundation
import WidgetKit

@MainActor
final class WidgetDataManager {
    static let shared = WidgetDataManager()
    private static let appGroupID = "group.com.cardwise.app"
    private static let widgetDataKey = "widget_data"
    private let defaults = UserDefaults(suiteName: appGroupID)
    private init() {}

    func updateWidgetData(cardViewModel: CardViewModel, spendingViewModel: SpendingViewModel) {
        let payload = Self.makePayload(userCards: cardViewModel.userCards, allCards: cardViewModel.allCards,
                                       spendings: spendingViewModel.spendings, settings: RecommendationSettingsStore.shared.settings)
        if let data = try? JSONEncoder().encode(payload) { defaults?.set(data, forKey: Self.widgetDataKey) }
        WidgetCenter.shared.reloadAllTimelines()
    }

    static func makePayload(userCards: [UserCard], allCards: [CreditCard], spendings: [Spending],
                            settings: RecommendationSettings, asOf date: Date = Date()) -> WidgetPayload {
        let category = settings.effectiveWidgetCategory
        let top = RecommendationEngine.shared.getRecommendations(
            for: category, amount: settings.validWidgetAmount, userCards: userCards, allCards: allCards,
            spendings: spendings, settings: settings, asOf: date, includeConditionalRewards: settings.widgetConditionalRewards
        ).first
        let rotating = userCards.compactMap { userCard -> (String, RotatingCategory)? in
            guard let card = allCards.first(where: { $0.id == userCard.cardId }), let rotating = card.rotatingCategory(asOf: date) else { return nil }
            return (userCard.nickname ?? card.name, rotating)
        }.first
        let month = Calendar.current.dateInterval(of: .month, for: date)
        let monthlySpending = spendings.filter { $0.date >= (month?.start ?? date) && $0.date <= date }
        let nextDay = Calendar.current.dateInterval(of: .day, for: date)?.end ?? date.addingTimeInterval(86400)
        let deadlines = userCards.compactMap { userCard in
            allCards.first(where: { $0.id == userCard.cardId }).flatMap { userCard.signUpBonusDeadline(for: $0) }
        }.filter { $0 > date }
        let validUntil = min(nextDay, deadlines.min() ?? nextDay)
        let merchant = settings.widgetMerchant.trimmingCharacters(in: .whitespacesAndNewlines)
        let context = "\(merchant.isEmpty ? category.displayName : merchant) · \(settings.validWidgetAmount.formatted(.currency(code: "USD")))"
        return WidgetPayload(
            topCategory: category.displayName, topCategoryIcon: category.icon,
            bestCard: top.map { $0.userCard.nickname ?? $0.card.name } ?? "Add Cards",
            bestCardColor: top?.card.imageColor ?? "#808080", rewardRate: top?.displayReward ?? "–",
            rotatingCategories: rotating?.1.categories.map(\.displayName) ?? [], rotatingCard: rotating?.0,
            spendingThisMonth: monthlySpending.reduce(0) { $0 + $1.amount },
            rewardsThisMonth: monthlySpending.reduce(0) { $0 + $1.rewardEarned },
            purchaseContext: context,
            explanation: top.map { "\($0.formattedEstimatedReward) est. · \(settings.ranking.title)" },
            generatedAt: date, validUntil: validUntil
        )
    }

    static func loadWidgetPayload() -> WidgetPayload? {
        guard let data = UserDefaults(suiteName: appGroupID)?.data(forKey: widgetDataKey) else { return nil }
        return try? JSONDecoder().decode(WidgetPayload.self, from: data)
    }
}
