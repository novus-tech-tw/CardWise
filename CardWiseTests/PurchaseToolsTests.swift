import Foundation
import Testing
import SwiftData
@testable import CardWise

@Suite @MainActor struct PurchaseToolsTests {
    private var now: Date { Date(timeIntervalSince1970: 1_794_916_800) } // 2026-11-17 12:00 UTC

    private func card(_ id: String, base: Double = 1, rewards: [CategoryReward] = [],
                      credits: [StatementCredit]? = nil, rotating: [RotatingCategory]? = nil,
                      bonus: SignUpBonus? = nil) -> CreditCard {
        CreditCard(id: id, name: id, issuer: "Test", network: .visa, annualFee: 0, rewardType: .cashback,
                   baseReward: base, baseIsPercentage: true, categoryRewards: rewards, rotatingCategories: rotating,
                   selectableConfig: nil, signUpBonus: bonus, imageColor: "#000000", imageURL: nil,
                   lastUpdated: nil, credits: credits)
    }

    private func offer(_ amount: Double = 20, activated: Bool = true) -> MerchantOffer {
        MerchantOffer(merchant: "Test Cafe", title: "Test offer", minimumSpend: 100, reward: amount,
                      rewardKind: .cash, expiresAt: now.addingTimeInterval(86400), isActivated: activated)
    }

    @Test func merchantCorrectionPersistsMatchesExactlyAndCanBeForgotten() throws {
        let suite = "CardWisePurchaseTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = MerchantPreferencesStore(defaults: defaults)
        store.save(.grocery, for: "  TEST Café  ")
        store.save(.other, for: "  ")
        let restored = MerchantPreferencesStore(defaults: defaults)
        #expect(restored.category(for: "test cafe") == .grocery)
        #expect(restored.savedCategory(for: "Other Test Cafe") == nil)
        #expect(restored.categories.count == 1)
        restored.remove("TEST CAFE")
        #expect(MerchantPreferencesStore(defaults: defaults).categories.isEmpty)
        #expect(restored.category(for: "Starbucks") == MerchantDatabase.suggestCategory(for: "Starbucks"))
    }

    @Test func lastCheckedPurchasePersistsAndRejectsInvalidEdits() throws {
        let suite = "CardWisePurchaseTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = RecentPurchaseStore(defaults: defaults)
        let purchase = PurchaseContext(merchant: "Test Cafe", category: .dining, amount: 42,
                                       conditions: PurchaseConditions(confirmedRewardIDs: ["one"]))
        store.save(purchase)
        store.save(PurchaseContext(merchant: "Invalid", category: .gas, amount: .nan))
        #expect(RecentPurchaseStore(defaults: defaults).purchase == purchase)
        store.reset()
        #expect(RecentPurchaseStore(defaults: defaults).purchase == nil)
    }

    @Test func specialRateConfirmationDoesNotEnableOtherCardsOrOtherTerms() throws {
        let portal = CategoryReward(category: .travel, multiplier: 5, isPercentage: true, cap: nil,
                                    capPeriod: nil, note: "Booked through Test Travel")
        let luxury = CategoryReward(category: .travel, multiplier: 10, isPercentage: true, cap: nil,
                                    capPeriod: nil, note: "Booked through Test Luxury Hotels")
        let first = card("first", rewards: [portal, luxury])
        let second = card("second", rewards: [portal])
        let conditions = PurchaseConditions(confirmedRewardIDs: [PurchaseConditions.key(cardID: first.id, reward: portal)])
        let result = RecommendationEngine.shared.getRecommendations(
            for: .travel, amount: 100, userCards: [UserCard(card: first), UserCard(card: second)],
            allCards: [first, second], includeConditionalRewards: true, purchaseConditions: conditions
        )
        #expect(result.first?.card.id == first.id)
        #expect(result.first?.estimatedReward == 5)
        #expect(result.last?.estimatedReward == 1)
        let normal = RecommendationEngine.shared.getRecommendations(for: .travel, userCards: [UserCard(card: first)],
                                                                     allCards: [first], purchaseConditions: PurchaseConditions())
        #expect(normal.first?.estimatedReward == 1)
    }

    @Test func comparisonUsesCapSplitAndOneConfirmedOfferWithoutSignupValue() throws {
        let capped = card("capped", rewards: [CategoryReward(category: .dining, multiplier: 5, isPercentage: true,
                                                            cap: 100, capPeriod: .monthly)])
        let flat = card("flat", base: 2)
        var wallet = UserCard(card: capped)
        var unconfirmed = offer(90, activated: false)
        unconfirmed.id = "unconfirmed"
        var expired = offer(99)
        expired.expiresAt = now
        wallet.merchantOffers = [offer(20), offer(10), unconfirmed, expired]
        let spending = Spending(amount: 80, merchant: "Past", category: .dining, cardUsed: capped.id, date: now, rewardEarned: 4)
        let recommendations = RecommendationEngine.shared.getRecommendations(
            for: .dining, amount: 100, userCards: [wallet, UserCard(card: flat)], allCards: [capped, flat],
            spendings: [spending], asOf: now
        )
        let ordinary = PurchaseComparison.rows(recommendations: recommendations, merchant: "TEST CAFE", amount: 100, asOf: now)
        #expect(ordinary.first?.recommendation.card.id == flat.id)
        let withOffers = PurchaseComparison.rows(recommendations: recommendations, merchant: "Test Cafe", amount: 100,
                                                  asOf: now, includeOffers: true)
        let winner = try #require(withOffers.first)
        #expect(winner.recommendation.card.id == capped.id)
        #expect(abs(winner.recommendation.estimatedReward - 1.8) < 0.000001)
        #expect(abs(winner.combinedEstimate - 21.8) < 0.000001)
        #expect(winner.bestOfferSavings == 20)
        #expect(PurchaseComparison.rows(recommendations: recommendations, merchant: "Other Test Cafe", amount: 100,
                                       asOf: now, includeOffers: true).first?.recommendation.card.id == flat.id)
        #expect(PurchaseComparison.rows(recommendations: recommendations, merchant: "Test Cafe", amount: .nan).isEmpty)
    }

    @Test func upcomingActionsExcludeUsedExpiredAndCompletedItemsAndSortByDeadline() throws {
        let credit = StatementCredit(id: "credit", description: "Dining credit", amount: 10, cadence: .monthly, category: .dining)
        let rotating = RotatingCategory(quarter: 4, year: 2026, categories: [.dining], multiplier: 5,
                                       isPercentage: true, cap: 1500, activationRequired: true)
        let bonus = SignUpBonus(bonusAmount: 200, bonusType: .cashback, spendRequirement: 100,
                               timeframeDays: 10, description: "Test goal")
        let card = card("test", credits: [credit], rotating: [rotating], bonus: bonus)
        var wallet = UserCard(card: card)
        wallet.signUpBonusStartDate = now.addingTimeInterval(-86400)
        wallet.merchantOffers = [offer()]
        let items = UpcomingActions.items(userCards: [wallet], catalog: [card], usages: [], spendings: [], now: now)
        #expect(items.count == 4)
        #expect(items.map(\.deadline) == items.map(\.deadline).sorted())
        let firstOffer = try #require(wallet.merchantOffers?.first)
        #expect(items.first?.kind == .offer(firstOffer.id))
        wallet.setRotatingActivated(true, quarter: 4, year: 2026)
        wallet.merchantOffers?[0].redeemedAt = now
        let usage = CreditUsage(cardID: card.id, creditID: credit.id,
                                periodKey: CreditPeriod.key(for: now, cadence: .monthly), amountUsed: 10)
        let spending = Spending(amount: 100, merchant: "Cafe", category: .dining, cardUsed: card.id, date: now, rewardEarned: 5)
        #expect(UpcomingActions.items(userCards: [wallet], catalog: [card], usages: [usage], spendings: [spending], now: now).isEmpty)
        #expect(UpcomingActions.items(userCards: [], catalog: [card], usages: [], spendings: [], now: now).isEmpty)
    }

    @Test func widgetSourcesReuseCurrentLedgerAndSavedCategoryAndFallBackAfterDeletion() throws {
        let card = card("test", rewards: [CategoryReward(category: .grocery, multiplier: 5, isPercentage: true,
                                                         cap: 100, capPeriod: .monthly)])
        let wallet = UserCard(card: card)
        var settings = RecommendationSettings()
        settings.widgetSource = .recent
        let recent = PurchaseContext(merchant: "My Store", category: .dining, amount: 50)
        let spending = Spending(amount: 80, merchant: "Other", category: .grocery, cardUsed: card.id, date: now, rewardEarned: 4)
        let payload = WidgetDataManager.makePayload(userCards: [wallet], allCards: [card], spendings: [spending], settings: settings,
                                                     asOf: now, recentPurchase: recent, merchantCategories: ["my store": .grocery])
        #expect(payload.topCategory == "Grocery")
        #expect(payload.purchaseAmount == 50)
        #expect(payload.explanation?.contains("$1.30") == true)
        let link = try #require(payload.recommendationURL)
        #expect(PurchaseContext(url: link)?.merchant == "My Store")
        #expect(PurchaseContext(url: link)?.category == .grocery)
        let favorite = FavoritePurchase(merchant: "Favorite", category: .gas)
        settings.widgetSource = .favorite
        settings.widgetFavoriteID = favorite.id
        let favoriteContext = WidgetDataManager.resolvedPurchase(settings: settings, recentPurchase: recent,
                                                                  favorites: [favorite], merchantCategories: [:])
        #expect(favoriteContext.merchant == favorite.merchant)
        #expect(favoriteContext.category == .gas)
        let fallback = WidgetDataManager.resolvedPurchase(settings: settings, recentPurchase: nil, favorites: [], merchantCategories: [:])
        #expect(fallback.category == settings.widgetCategory)
        #expect(fallback.amount == 100)
    }

    @Test func widgetURLRoundTripsSpecialCharactersAndRejectsInvalidInputWithoutRateConfirmations() throws {
        let payload = WidgetPayload(topCategory: "Dining", topCategoryIcon: "fork.knife", bestCard: "Card", bestCardColor: "#000000",
                                    rewardRate: "1%", rotatingCategories: [], rotatingCard: nil, spendingThisMonth: 0, rewardsThisMonth: 0,
                                    purchaseMerchant: "Café & Tea #1", purchaseCategory: SpendingCategory.dining.rawValue, purchaseAmount: 12.34)
        let url = try #require(payload.recommendationURL)
        let context = try #require(PurchaseContext(url: url))
        #expect(context.merchant == "Café & Tea #1")
        #expect(context.amount == 12.34)
        #expect(context.conditions.confirmedRewardIDs.isEmpty)
        #expect(PurchaseContext(url: URL(string: "cardwise://recommend?category=dining&amount=nan")!) == nil)
        #expect(PurchaseContext(url: URL(string: "cardwise://recommend?category=unknown&amount=10")!) == nil)
        #expect(PurchaseContext(url: URL(string: "https://recommend?category=dining&amount=10")!) == nil)
    }

    @Test func oldSettingsDecodeWithoutNewWidgetFields() throws {
        let data = Data(#"{"ranking":"signupFirst","pointValues":{},"widgetCategory":"dining","widgetMerchant":"","widgetAmount":100,"widgetConditionalRewards":false}"#.utf8)
        let settings = try JSONDecoder().decode(RecommendationSettings.self, from: data)
        #expect(settings.widgetSource == nil)
        #expect(settings.widgetConfirmedRewardIDs == nil)
        #expect(settings.validWidgetAmount == 100)
    }

    @Test func recordedSpendingUsesOnlyTheConfirmedRate() throws {
        let portal = CategoryReward(category: .travel, multiplier: 5, isPercentage: true, cap: nil,
                                    capPeriod: nil, note: "Booked through Test Travel")
        let card = card("test", rewards: [portal])
        let container = try ModelContainer(for: UserCardRecord.self, SpendingRecord.self, CreditUsageRecord.self,
                                           configurations: ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none))
        defer { withExtendedLifetime(container) {} }
        let store = CloudStore(context: ModelContext(container))
        let cards = CardViewModel(store: store)
        cards.allCards = [card]
        cards.addCard(card)
        let spending = SpendingViewModel(store: store)
        try spending.addSpending(amount: 100, merchant: "Hotel", category: .travel, cardUsed: card.id, date: now,
                                  cardViewModel: cards, purchaseConditions: PurchaseConditions())
        #expect(spending.spendings.first?.rewardEarned == 1)
        try spending.addSpending(amount: 100, merchant: "Hotel", category: .travel, cardUsed: card.id, date: now,
                                  cardViewModel: cards, purchaseConditions: PurchaseConditions(confirmedRewardIDs: [PurchaseConditions.key(cardID: card.id, reward: portal)]))
        #expect(spending.spendings.first?.rewardEarned == 5)
    }
}
