import Foundation
import MapKit
import Testing
@testable import CardWise

@Suite struct LocalIntegrationsTests {
    private func date(_ day: Int, month: Int = 11, year: Int = 2026) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }

    private func card(id: String, base: Double = 1, fixed: [CategoryReward] = [],
                      rotating: [RotatingCategory]? = nil) -> CreditCard {
        CreditCard(id: id, name: id, issuer: "Test", network: .visa, annualFee: 0,
                   rewardType: .cashback, baseReward: base, baseIsPercentage: true,
                   categoryRewards: fixed, rotatingCategories: rotating, selectableConfig: nil,
                   signUpBonus: nil, imageColor: "#112233", imageURL: nil, lastUpdated: nil)
    }

    // MARK: Shopping mode Live Activity

    @Test func activityStateUsesEngineWinnerAndNamesRunnerUp() throws {
        let dining = card(id: "Dining", fixed: [CategoryReward(category: .dining, multiplier: 4, isPercentage: true, cap: nil, capPeriod: nil)])
        let flat = card(id: "Flat", base: 2)
        let recs = RecommendationEngine.shared.getRecommendations(
            for: .dining, amount: 50, userCards: [UserCard(card: flat), UserCard(card: dining)], allCards: [dining, flat])
        let state = try #require(ShoppingActivityController.state(for: recs))
        #expect(state.cardName == "Dining")
        #expect(state.cardColor == "#112233")
        #expect(state.rewardRate == "4%")
        #expect(state.note == "Next: Flat · 2%")
    }

    @Test func activityStateWarnsAboutNearlyExhaustedCap() throws {
        let capped = card(id: "Capped", fixed: [CategoryReward(category: .dining, multiplier: 5, isPercentage: true,
                                                               cap: 100, capPeriod: .monthly)])
        let spending = [Spending(amount: 90, merchant: "Food", category: .dining, cardUsed: capped.id, date: date(2), rewardEarned: 4.5)]
        let recs = RecommendationEngine.shared.getRecommendations(
            for: .dining, amount: 5, userCards: [UserCard(card: capped)], allCards: [capped], spendings: spending, asOf: date(10))
        let state = try #require(ShoppingActivityController.state(for: recs))
        #expect(state.note?.hasPrefix("Bonus cap:") == true)
    }

    @Test func activityStateIsNilWithoutRecommendations() {
        #expect(ShoppingActivityController.state(for: []) == nil)
    }

    @Test @MainActor func activityDeepLinkReopensSamePurchase() throws {
        let purchase = PurchaseContext(merchant: " Blue Bottle ", category: .dining, amount: 12.5)
        let attributes = ShoppingActivityController.attributes(for: purchase)
        #expect(attributes.title == "Blue Bottle")
        let url = try #require(attributes.recommendURL)
        let parsed = try #require(PurchaseContext(url: url))
        #expect(parsed.merchant == "Blue Bottle")
        #expect(parsed.category == .dining)
        #expect(parsed.amount == 12.5)

        let categoryOnly = ShoppingActivityController.attributes(for: PurchaseContext(merchant: "", category: .gas, amount: 40))
        #expect(categoryOnly.title == SpendingCategory.gas.displayName)
    }

    // MARK: Nearby category mapping

    @Test func savedPreferenceWinsOverEverything() {
        let result = NearbyCategoryResolver.resolve(name: "Costco", poi: .gasStation, saved: .gas, nameSuggestion: .wholesale)
        #expect(result.category == .gas)
        #expect(result.isSaved)
    }

    @Test func brandCategoryBeatsGenericPlaceType() {
        #expect(NearbyCategoryResolver.resolve(name: "Whole Foods Market", poi: .foodMarket, saved: nil,
                                               nameSuggestion: .wholeFoods).category == .wholeFoods)
        #expect(NearbyCategoryResolver.resolve(name: "Target", poi: .store, saved: nil, nameSuggestion: .target).category == .target)
    }

    @Test func placeTypeBeatsAmbiguousNameKeyword() {
        // A restaurant whose name happens to contain a gas brand keyword stays dining.
        #expect(NearbyCategoryResolver.resolve(name: "Shell's Seafood", poi: .restaurant, saved: nil,
                                               nameSuggestion: .gas).category == .dining)
        #expect(NearbyCategoryResolver.resolve(name: "CVS", poi: .pharmacy, saved: nil, nameSuggestion: nil).category == .drugstore)
        #expect(NearbyCategoryResolver.resolve(name: "Hilton", poi: .hotel, saved: nil, nameSuggestion: nil).category == .hotels)
    }

    @Test func unknownStoreFallsBackToNameThenOther() {
        #expect(NearbyCategoryResolver.resolve(name: "Home Depot", poi: .store, saved: nil,
                                               nameSuggestion: .homeImprovement).category == .homeImprovement)
        #expect(NearbyCategoryResolver.resolve(name: "Corner Shop", poi: .store, saved: nil, nameSuggestion: nil).category == .other)
    }

    @Test func everySearchedPlaceTypeExceptStoreHasACategory() {
        for poi in NearbyCategoryResolver.searchedCategories where poi != .store {
            #expect(NearbyCategoryResolver.category(for: poi) != nil, "\(poi.rawValue) is searched but unmapped")
        }
    }

    // MARK: Wallet shortcut messages

    @Test func bonusCategoriesFlagUnconfirmedActivation() {
        let rotating = card(id: "Flex", rotating: [RotatingCategory(quarter: 4, year: 2026, categories: [.gas, .dining],
                                                                    multiplier: 5, isPercentage: true, cap: 1500,
                                                                    activationRequired: true)])
        var wallet = UserCard(card: rotating)
        let message = WalletShortcutMessages.bonusCategories(userCards: [wallet], catalog: [rotating], now: date(10))
        #expect(message.contains("Flex: 5% on"))
        #expect(message.contains("Q4"))
        #expect(message.contains("activation not confirmed"))

        wallet.setRotatingActivated(true, quarter: 4, year: 2026)
        let confirmed = WalletShortcutMessages.bonusCategories(userCards: [wallet], catalog: [rotating], now: date(10))
        #expect(!confirmed.contains("activation not confirmed"))
    }

    @Test func emptyWalletMessagesAreExplicit() {
        #expect(WalletShortcutMessages.bonusCategories(userCards: [], catalog: [], now: date(10))
                == "None of your cards has a rotating bonus this quarter.")
        #expect(WalletShortcutMessages.unusedCredits([]) == "No statement credits left to use this period.")
        #expect(WalletShortcutMessages.upcomingActions([]) == "Nothing needs attention in the next 30 days.")
    }

    @Test func upcomingActionsMessageTruncatesWithCount() {
        let actions = (1...7).map { index in
            UpcomingAction(id: "a\(index)", walletID: "w", cardName: "Card \(index)", title: "Task \(index)",
                           detail: "", deadline: date(index), kind: .activation)
        }
        let message = WalletShortcutMessages.upcomingActions(actions, limit: 5)
        #expect(message.contains("Card 5: Task 5"))
        #expect(!message.contains("Card 6"))
        #expect(message.hasSuffix("Plus 2 more in CardWise."))
    }
}
