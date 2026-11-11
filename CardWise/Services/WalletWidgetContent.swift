import Foundation

enum WalletWidgetContent {
    static func sections(snapshot: ShortcutRecommendation.Snapshot, usages: [CreditUsage],
                         favorites: [FavoritePurchase], now: Date) -> [WalletWidgetSection] {
        let userCards = snapshot.userCards
        let catalog = snapshot.catalog
        let categories = categoryRows(snapshot: snapshot, favorites: favorites, now: now)
        let offers = WalletOfferQuery.matches(userCards: userCards, catalog: catalog, now: now).map { match in
            WalletWidgetRow(id: match.id, title: match.offer.merchant, subtitle: "\(match.cardName) · \(match.offer.title)",
                            value: "Through \(match.offer.expiresAt.addingTimeInterval(-1).formatted(date: .abbreviated, time: .omitted))",
                            url: URL(string: "cardwise://offers"))
        }
        let deadlines = UpcomingActions.items(userCards: userCards, catalog: catalog, usages: usages,
                                             spendings: snapshot.spendings, now: now).map { action in
            let date: Date
            if case .offer = action.kind { date = action.deadline.addingTimeInterval(-1) } else { date = action.deadline }
            return WalletWidgetRow(id: action.id, title: action.title, subtitle: action.cardName,
                                   value: date.formatted(date: .abbreviated, time: .omitted), url: URL(string: "cardwise://deadlines"))
        }
        let credits = creditRows(userCards: userCards, catalog: catalog, usages: usages, now: now)
        let annualFees = userCards.reduce(0.0) { total, wallet in
            total + (catalog.first { $0.id == wallet.cardId }?.annualFee ?? 0)
        }
        let summary = [
            WalletWidgetRow(id: "cards", title: "Saved cards", subtitle: "Your wallet", value: "\(userCards.count)", url: URL(string: "cardwise://cards")),
            WalletWidgetRow(id: "fees", title: "Annual fees", subtitle: "Current catalog rates", value: annualFees.formatted(.currency(code: "USD")), url: URL(string: "cardwise://cards"))
        ]
        return [
            WalletWidgetSection(kind: .categories, title: "Best Cards by Category", emptyMessage: "Add cards in CardWise to compare rewards.", rows: categories),
            WalletWidgetSection(kind: .offers, title: "Saved Offers", emptyMessage: "No current saved offers. Enter offers from your issuer in CardWise.", rows: offers),
            WalletWidgetSection(kind: .deadlines, title: "Coming Up", emptyMessage: "No upcoming card actions.", rows: deadlines),
            WalletWidgetSection(kind: .credits, title: "Unused Credits", emptyMessage: "No unused statement credits this period.", rows: credits),
            WalletWidgetSection(kind: .summary, title: "Wallet Summary", emptyMessage: "Add cards in CardWise.", rows: summary)
        ]
    }

    private static func categoryRows(snapshot: ShortcutRecommendation.Snapshot, favorites: [FavoritePurchase], now: Date) -> [WalletWidgetRow] {
        let settings = snapshot.settings
        let defaults: [SpendingCategory] = [.dining, .grocery, .gas, .travel, .onlineShopping, .drugstore]
        var seen = Set<SpendingCategory>()
        let categories = (favorites.map(\.category) + defaults).filter { seen.insert($0).inserted }
        return categories.compactMap { category in
            guard let best = RecommendationEngine.shared.getRecommendations(
                for: category, amount: settings.validWidgetAmount, userCards: snapshot.userCards, allCards: snapshot.catalog,
                spendings: snapshot.spendings, settings: settings, asOf: now
            ).first else { return nil }
            let purchase = WidgetPayload(topCategory: category.displayName, topCategoryIcon: category.icon,
                                         bestCard: best.card.name, bestCardColor: best.card.imageColor, rewardRate: best.displayReward,
                                         rotatingCategories: [], rotatingCard: nil, spendingThisMonth: 0, rewardsThisMonth: 0,
                                         purchaseCategory: category.rawValue, purchaseAmount: settings.validWidgetAmount)
            return WalletWidgetRow(id: category.rawValue, title: category.displayName,
                                   subtitle: best.userCard.nickname ?? best.card.name,
                                   value: "\(best.formattedEstimatedReward) est. on \(settings.validWidgetAmount.formatted(.currency(code: "USD")))",
                                   url: purchase.recommendationURL)
        }
    }

    private static func creditRows(userCards: [UserCard], catalog: [CreditCard], usages: [CreditUsage], now: Date) -> [WalletWidgetRow] {
        CardViewModel.unusedCredits(userCards: userCards, catalog: catalog, usages: usages, asOf: now).map { item in
            WalletWidgetRow(id: item.id, title: item.credit.description,
                            subtitle: "\(item.cardName) · resets \(item.resetDate.formatted(date: .abbreviated, time: .omitted))",
                            value: "\(item.remaining.formatted(.currency(code: "USD"))) left", url: URL(string: "cardwise://credits"))
        }
    }
}
