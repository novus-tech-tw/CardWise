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
                                       spendings: spendingViewModel.spendings, settings: RecommendationSettingsStore.shared.settings,
                                       recentPurchase: RecentPurchaseStore.shared.purchase, favorites: QuickAccessStore.shared.favorites,
                                       merchantCategories: MerchantPreferencesStore.shared.categories, usages: cardViewModel.creditUsages)
        if let data = try? JSONEncoder().encode(payload) { defaults?.set(data, forKey: Self.widgetDataKey) }
        WidgetCenter.shared.reloadAllTimelines()
    }

    static func makePayload(userCards: [UserCard], allCards: [CreditCard], spendings: [Spending],
                            settings: RecommendationSettings, asOf date: Date = Date(), recentPurchase: PurchaseContext? = nil,
                            favorites: [FavoritePurchase] = [], merchantCategories: [String: SpendingCategory] = [:],
                            usages: [CreditUsage] = []) -> WidgetPayload {
        let purchase = resolvedPurchase(settings: settings, recentPurchase: recentPurchase, favorites: favorites,
                                        merchantCategories: merchantCategories)
        let category = purchase.category
        let top = RecommendationEngine.shared.getRecommendations(
            for: category, amount: purchase.amount, userCards: userCards, allCards: allCards,
            spendings: spendings, settings: settings, asOf: date, purchaseConditions: purchase.conditions
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
        let offerExpiries = WalletOfferQuery.matches(userCards: userCards, catalog: allCards, now: date).map { $0.offer.expiresAt }
        let validUntil = min(nextDay, (deadlines + offerExpiries).min() ?? nextDay)
        let merchant = purchase.merchant.trimmingCharacters(in: .whitespacesAndNewlines)
        let context = "\(merchant.isEmpty ? category.displayName : merchant) · \(purchase.amount.formatted(.currency(code: "USD")))"
        return WidgetPayload(
            topCategory: category.displayName, topCategoryIcon: category.icon,
            bestCard: top.map { $0.userCard.nickname ?? $0.card.name } ?? "Add Cards",
            bestCardColor: top?.card.imageColor ?? "#808080", rewardRate: top?.displayReward ?? "–",
            rotatingCategories: rotating?.1.categories.map(\.displayName) ?? [], rotatingCard: rotating?.0,
            spendingThisMonth: monthlySpending.reduce(0) { $0 + $1.amount },
            rewardsThisMonth: monthlySpending.reduce(0) { $0 + $1.rewardEarned },
            purchaseContext: context,
            explanation: top.map { "\($0.formattedEstimatedReward) est. · \(settings.ranking.title)" },
            generatedAt: date, validUntil: validUntil,
            purchaseMerchant: purchase.merchant, purchaseCategory: category.rawValue, purchaseAmount: purchase.amount,
            walletSections: WalletWidgetContent.sections(snapshot: ShortcutRecommendation.Snapshot(
                userCards: userCards, catalog: allCards, spendings: spendings, settings: settings
            ), usages: usages, favorites: favorites, now: date)
        )
    }

    static func resolvedPurchase(settings: RecommendationSettings, recentPurchase: PurchaseContext?,
                                 favorites: [FavoritePurchase], merchantCategories: [String: SpendingCategory]) -> PurchaseContext {
        var purchase = PurchaseContext(merchant: settings.widgetMerchant, category: settings.effectiveWidgetCategory,
                                       amount: settings.validWidgetAmount,
                                       conditions: PurchaseConditions(confirmedRewardIDs: settings.widgetConfirmedRewardIDs ?? []))
        switch settings.widgetSource ?? .configured {
        case .configured: break
        case .recent:
            if let recentPurchase, recentPurchase.isValid { purchase = recentPurchase }
        case .favorite:
            if let favorite = favorites.first(where: { $0.id == settings.widgetFavoriteID }) {
                purchase.merchant = favorite.merchant
                purchase.category = favorite.category
            }
        }
        if let saved = merchantCategories[MerchantOffer.merchantKey(purchase.merchant)] { purchase.category = saved }
        return purchase
    }

    static func loadWidgetPayload() -> WidgetPayload? {
        guard let data = UserDefaults(suiteName: appGroupID)?.data(forKey: widgetDataKey) else { return nil }
        return try? JSONDecoder().decode(WidgetPayload.self, from: data)
    }
}
