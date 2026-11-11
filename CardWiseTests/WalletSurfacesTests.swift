import Foundation
import Testing
@testable import CardWise

@Suite @MainActor struct WalletSurfacesTests {
    private let now = Date(timeIntervalSince1970: 1_794_916_800)

    private func card(_ id: String = "Test Card", base: Double = 1, credits: [StatementCredit]? = nil,
                      rewards: [CategoryReward] = []) -> CreditCard {
        CreditCard(id: id, name: id, issuer: "Test", network: .visa, annualFee: 95,
                   rewardType: .cashback, baseReward: base, baseIsPercentage: true,
                   categoryRewards: rewards, rotatingCategories: nil, selectableConfig: nil,
                   signUpBonus: nil, imageColor: "#112233", imageURL: nil, lastUpdated: nil, credits: credits)
    }

    private func offer(id: String = "offer", reward: Double = 20) -> MerchantOffer {
        MerchantOffer(id: id, merchant: "Test Café", title: "Spend and save", minimumSpend: 100,
                      reward: reward, rewardKind: .cash, expiresAt: now.addingTimeInterval(3600), isActivated: true)
    }

    @Test func inventoryExcludesInvalidArchivedUsedAndExpiredButShowsUnconfirmed() {
        let card = card()
        var wallet = UserCard(card: card)
        var expired = offer(id: "expired")
        expired.expiresAt = now
        var archived = offer(id: "archived")
        archived.isArchived = true
        var used = offer(id: "used")
        used.redeemedAt = now
        var invalid = offer(id: "invalid")
        invalid.reward = .nan
        var unconfirmed = offer(id: "unconfirmed")
        unconfirmed.isActivated = false
        wallet.merchantOffers = [offer(), expired, archived, used, invalid, unconfirmed]
        let matches = WalletOfferQuery.matches(userCards: [wallet], catalog: [card], merchant: " TEST cafe ", now: now)
        #expect(matches.map(\.offer.id) == ["offer", "unconfirmed"])
        #expect(matches.first?.estimatedSavings == 20)
        #expect(matches.last?.estimatedSavings == nil)
        #expect(WalletOfferQuery.matches(userCards: [wallet], catalog: [card], merchant: "Other Test Cafe", now: now).isEmpty)
    }

    @Test func bestOfferUsesPurchaseSavingsAndDeterministicExpiryTieBreak() throws {
        let card = card()
        var wallet = UserCard(card: card)
        var percent = offer(id: "percent", reward: 90)
        percent.rewardKind = .percent
        percent.maximumReward = 5
        var later = offer(id: "later")
        later.expiresAt = now.addingTimeInterval(7200)
        wallet.merchantOffers = [percent, later, offer()]
        let matches = WalletOfferQuery.matches(userCards: [wallet], catalog: [card], now: now)
        #expect(matches.first { $0.offer.id == "percent" }?.estimatedSavings == 5)
        let best = try #require(WalletOfferQuery.best(in: matches))
        #expect(best.offer.id == "offer")
        #expect(WalletOfferQuery.best(in: WalletOfferQuery.matches(userCards: [wallet], catalog: [card], amount: 99, now: now)) == nil)
        #expect(WalletOfferQuery.best(in: []) == nil)
    }

    @Test(arguments: [Double.nan, .infinity, 0, -1]) func invalidPurchaseReturnsNoOffers(amount: Double) {
        var wallet = UserCard(card: card())
        wallet.merchantOffers = [offer()]
        #expect(WalletOfferQuery.matches(userCards: [wallet], catalog: [], amount: amount, now: now).isEmpty)
    }

    @Test func offerEntitiesKeepCardIdentityAndIntrinsicTerms() throws {
        let card = card()
        var first = UserCard(card: card)
        first.nickname = "My Card"
        first.merchantOffers = [offer()]
        var second = UserCard(card: card)
        second.merchantOffers = [offer()]
        let matches = WalletOfferQuery.matches(userCards: [first, second], catalog: [card], amount: 50, now: now)
        #expect(Set(matches.map(\.id)).count == 2)
        let entity = MerchantOfferEntity(match: try #require(matches.first { $0.walletID == first.id }))
        #expect(entity.cardName == "My Card")
        #expect(entity.merchant == "Test Café")
        #expect(entity.isActivated)
        #expect(entity.reward == 20)
        #expect(entity.rewardType == MerchantOffer.RewardKind.cash.title)
        #expect(entity.minimumSpend == 100)
        #expect(entity.maximumReward == nil)
        #expect(entity.expiresAt == now.addingTimeInterval(3600))
    }

    @Test func walletWidgetsUseCapsAndFavoritesAndReopenTheSameCategory() throws {
        let card = card(rewards: [CategoryReward(category: .dining, multiplier: 5, isPercentage: true, cap: 100, capPeriod: .monthly)])
        let wallet = UserCard(card: card)
        let spending = Spending(amount: 80, merchant: "Cafe", category: .dining, cardUsed: card.id, date: now, rewardEarned: 4)
        let payload = WidgetDataManager.makePayload(userCards: [wallet], allCards: [card], spendings: [spending], settings: .init(),
                                                     asOf: now, favorites: [FavoritePurchase(merchant: "", category: .dining)])
        let rows = try #require(payload.walletSections?.first { $0.kind == .categories }?.rows)
        #expect(rows.count == 6)
        let dining = try #require(rows.first)
        #expect(dining.id == SpendingCategory.dining.rawValue)
        #expect(dining.value.contains("$1.80"))
        let url = try #require(dining.url)
        let purchase = try #require(PurchaseContext(url: url))
        #expect(purchase.category == .dining)
        #expect(purchase.amount == 100)
    }

    @Test func widgetCreditsShareUsageAndResetAccountingWithApp() throws {
        let credit = StatementCredit(id: "dining", description: "Dining Credit", amount: 10, cadence: .monthly, category: .dining)
        let card = card(credits: [credit])
        let wallet = UserCard(card: card)
        let usage = CreditUsage(cardID: card.id, creditID: credit.id, periodKey: CreditPeriod.key(for: now, cadence: .monthly), amountUsed: 3.5)
        let payload = WidgetDataManager.makePayload(userCards: [wallet], allCards: [card], spendings: [], settings: .init(), asOf: now, usages: [usage])
        let row = try #require(payload.walletSections?.first { $0.kind == .credits }?.rows.first)
        #expect(row.value == "$6.50 left")
        #expect(row.url?.host == "credits")
        let unused = try #require(CardViewModel.unusedCredits(userCards: [wallet], catalog: [card], usages: [usage], asOf: now).first)
        #expect(unused.remaining == 6.5)
        #expect(unused.resetDate == CreditPeriod.nextReset(for: now, cadence: .monthly))
        let reset = WidgetDataManager.makePayload(userCards: [wallet], allCards: [card], spendings: [], settings: .init(), asOf: unused.resetDate, usages: [usage])
        #expect(reset.walletSections?.first { $0.kind == .credits }?.rows.first?.value == "$10.00 left")
    }

    @Test func widgetSnapshotExpiresBeforeOfferAndIncludesEveryWalletMode() throws {
        let card = card()
        var wallet = UserCard(card: card)
        wallet.merchantOffers = [offer()]
        let payload = WidgetDataManager.makePayload(userCards: [wallet], allCards: [card], spendings: [], settings: .init(), asOf: now)
        #expect(payload.validUntil == now.addingTimeInterval(3600))
        #expect(payload.isStale(at: now.addingTimeInterval(3600)))
        #expect(payload.walletSections?.count == WalletWidgetSectionKind.allCases.count)
        let sections = try #require(payload.walletSections)
        #expect(sections.first { $0.kind == .offers }?.rows.first?.url?.host == "offers")
        #expect(sections.first { $0.kind == .deadlines }?.rows.first?.url?.host == "deadlines")
        #expect(sections.first { $0.kind == .summary }?.rows.last?.value == "$95.00")
        let restored = try JSONDecoder().decode(WidgetPayload.self, from: JSONEncoder().encode(payload))
        #expect(restored == payload)
        #expect(sections.first { $0.kind == .categories }?.destinationURL?.host == "recommend")
        #expect(sections.first { $0.kind == .credits }?.destinationURL?.host == "credits")
        let emptyOffers = WalletWidgetSection(kind: .offers, title: "Offers", emptyMessage: "No offers", rows: [])
        #expect(emptyOffers.destinationURL?.host == "offers")
    }

    @Test func legacyWidgetAndWalletPayloadsStillLoad() throws {
        let legacy = WidgetPayload(topCategory: "Dining", topCategoryIcon: "fork.knife", bestCard: "Card", bestCardColor: "#000000",
                                   rewardRate: "1%", rotatingCategories: [], rotatingCard: nil, spendingThisMonth: 0, rewardsThisMonth: 0)
        let decoded = try JSONDecoder().decode(WidgetPayload.self, from: JSONEncoder().encode(legacy))
        #expect(decoded.walletSections == nil)
        #expect(decoded.isStale(at: now))
        let wallet = UserCard(card: card())
        #expect(WalletOfferQuery.matches(userCards: [wallet], catalog: [], now: now).isEmpty)
    }

    @Test func favoriteOrderPersistsAndUpdatesCategoryWidgetPriority() throws {
        let suite = "CardWiseFavorites.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = QuickAccessStore(defaults: defaults)
        let dining = FavoritePurchase(merchant: "", category: .dining)
        let gas = FavoritePurchase(merchant: "", category: .gas)
        store.toggle(dining)
        store.toggle(gas)
        store.reorder(ids: [gas.id, dining.id])
        store.reorder(ids: [gas.id, gas.id])
        store.reorder(ids: ["missing", dining.id])
        let restored = QuickAccessStore(defaults: defaults)
        #expect(restored.favorites == [gas, dining])
        let card = card()
        let payload = WidgetDataManager.makePayload(userCards: [UserCard(card: card)], allCards: [card], spendings: [],
                                                     settings: .init(), asOf: now, favorites: restored.favorites)
        let rows = try #require(payload.walletSections?.first { $0.kind == .categories }?.rows)
        #expect(rows.prefix(2).map(\.id) == [SpendingCategory.gas.rawValue, SpendingCategory.dining.rawValue])
    }

    @Test func shoppingRefreshUsesUpdatedSpendingAndEndsWhenWalletBecomesEmpty() throws {
        let capped = card("Capped", rewards: [CategoryReward(category: .dining, multiplier: 5, isPercentage: true,
                                                              cap: 100, capPeriod: .monthly)])
        let flat = card("Flat", base: 2)
        let attributes = ShoppingActivityController.attributes(for: PurchaseContext(merchant: "Cafe", category: .dining, amount: 100))
        var snapshot = ShortcutRecommendation.Snapshot(userCards: [UserCard(card: capped), UserCard(card: flat)],
                                                       catalog: [capped, flat], spendings: [], settings: .init())
        #expect(ShoppingActivityController.state(for: attributes, snapshot: snapshot, now: now)?.cardName == "Capped")
        snapshot.spendings = [Spending(amount: 100, merchant: "Cafe", category: .dining, cardUsed: capped.id, date: now, rewardEarned: 5)]
        #expect(ShoppingActivityController.state(for: attributes, snapshot: snapshot, now: now)?.cardName == "Flat")
        snapshot.userCards = []
        #expect(ShoppingActivityController.state(for: attributes, snapshot: snapshot, now: now) == nil)
        var invalid = attributes
        invalid.amount = .nan
        #expect(ShoppingActivityController.state(for: invalid, snapshot: snapshot, now: now) == nil)
    }

    @Test func shoppingRefreshPreservesOnlyExactConfirmedTermsAndDecodesLegacyActivities() throws {
        let special = CategoryReward(category: .travel, multiplier: 5, isPercentage: true, cap: nil,
                                     capPeriod: nil, note: "Booked through Test Travel")
        let card = card(rewards: [special])
        let conditions = PurchaseConditions(confirmedRewardIDs: [PurchaseConditions.key(cardID: card.id, reward: special)])
        let attributes = ShoppingActivityController.attributes(for: PurchaseContext(merchant: "Travel", category: .travel, amount: 100, conditions: conditions))
        let snapshot = ShortcutRecommendation.Snapshot(userCards: [UserCard(card: card)], catalog: [card], spendings: [], settings: .init())
        #expect(ShoppingActivityController.state(for: attributes, snapshot: snapshot, now: now)?.estimatedReward == "$5.00")
        var json = try #require(JSONSerialization.jsonObject(with: JSONEncoder().encode(attributes)) as? [String: Any])
        json.removeValue(forKey: "confirmedRewardIDs")
        let legacy = try JSONDecoder().decode(ShoppingActivityAttributes.self, from: JSONSerialization.data(withJSONObject: json))
        #expect(legacy.confirmedRewardIDs == nil)
        #expect(ShoppingActivityController.state(for: legacy, snapshot: snapshot, now: now)?.estimatedReward == "$1.00")
        var changed = attributes
        changed.confirmedRewardIDs = ["other-card|\(special.id)"]
        #expect(ShoppingActivityController.state(for: changed, snapshot: snapshot, now: now)?.estimatedReward == "$1.00")
    }

    @Test(.timeLimit(.minutes(1))) func shoppingMutationsStayOrderedAcrossSuspension() async throws {
        var events: [String] = []
        var release: CheckedContinuation<Void, Never>?
        let first = Task { @MainActor in
            try await ShoppingActivityRequest.run {
                events.append("first started")
                await withCheckedContinuation { release = $0 }
                events.append("first finished")
                return "first"
            }
        }
        while release == nil { await Task.yield() }
        var secondQueued = false
        let second = Task { @MainActor in
            secondQueued = true
            return try await ShoppingActivityRequest.run {
                events.append("second")
                return "second"
            }
        }
        while !secondQueued { await Task.yield() }
        await Task.yield()
        #expect(events == ["first started"])
        release?.resume()
        let firstResult = try await first.value
        let secondResult = try await second.value
        #expect(firstResult == "first")
        #expect(secondResult == "second")
        #expect(events == ["first started", "first finished", "second"])
    }
}
