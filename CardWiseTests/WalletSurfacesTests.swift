import Foundation
import Testing
@testable import CardWise

@Suite @MainActor struct WalletSurfacesTests {
    private let now = Date(timeIntervalSince1970: 1_794_916_800)

    private func card(_ id: String = "Test Card", credits: [StatementCredit]? = nil,
                      rewards: [CategoryReward] = []) -> CreditCard {
        CreditCard(id: id, name: id, issuer: "Test", network: .visa, annualFee: 95,
                   rewardType: .cashback, baseReward: 1, baseIsPercentage: true,
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
}
