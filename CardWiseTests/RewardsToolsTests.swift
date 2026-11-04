import XCTest
import SwiftData
@testable import CardWise

@MainActor
final class RewardsToolsTests: XCTestCase {
    private var calendar: Calendar {
        var value = Calendar(identifier: .gregorian)
        value.timeZone = TimeZone(secondsFromGMT: 0)!
        return value
    }

    private func date(_ year: Int = 2026, _ month: Int = 11, _ day: Int = 2, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    private func card(id: String = "test", cadence: CreditCadence = .monthly) -> CreditCard {
        CreditCard(id: id, name: id, issuer: "Test", network: .visa, annualFee: 95,
                   rewardType: .cashback, baseReward: 1, baseIsPercentage: true,
                   categoryRewards: [], rotatingCategories: nil, selectableConfig: nil,
                   signUpBonus: nil, imageColor: "#000000", imageURL: nil, lastUpdated: nil,
                   credits: [StatementCredit(id: "credit", description: "Dining credit", amount: 10, cadence: cadence, category: .dining)])
    }

    private func offer() -> MerchantOffer {
        MerchantOffer(merchant: "Test Store", title: "Spend $100, get $20", minimumSpend: 100,
                      reward: 20, rewardKind: .cash, expiresAt: date(2026, 12, 1), isActivated: true)
    }

    func testOfferEligibilityBoundariesAndExactMerchantIdentity() {
        var value = offer()
        XCTAssertEqual(value.estimatedSavings(for: 100, at: date()), 20)
        XCTAssertNil(value.estimatedSavings(for: 99.99, at: date()))
        XCTAssertNil(value.estimatedSavings(for: 100, at: value.expiresAt))
        XCTAssertTrue(value.matches("  TEST STORE  "))
        XCTAssertFalse(value.matches("Other Test Store"))
        XCTAssertFalse(value.matches(""))
        value.isActivated = false
        XCTAssertNil(value.estimatedSavings(for: 100, at: date()))
        value.isActivated = true
        value.isArchived = true
        XCTAssertNil(value.estimatedSavings(for: 100, at: date()))
        value.isArchived = false
        value.redeemedAt = date()
        XCTAssertNil(value.estimatedSavings(for: 100, at: date()))
    }

    func testPercentageCapAndMalformedAmounts() {
        var value = offer()
        value.rewardKind = .percent
        value.maximumReward = 15
        XCTAssertEqual(value.estimatedSavings(for: 200, at: date()), 15)
        XCTAssertNil(value.estimatedSavings(for: .infinity, at: date()))
        value.reward = 101
        XCTAssertFalse(value.isValid)
        value.reward = 20
        value.minimumSpend = .nan
        XCTAssertFalse(value.isValid)
        value.minimumSpend = 0
        value.maximumReward = -1
        XCTAssertFalse(value.isValid)
        value.maximumReward = nil
        value.rewardKind = .cash
        value.reward = 100
        XCTAssertEqual(value.estimatedSavings(for: 5, at: date()), 5)
    }

    func testWalletRoundTripAndLegacyDecoding() throws {
        var wallet = UserCard(card: card())
        wallet.isPinned = true
        wallet.merchantOffers = [offer()]
        wallet.annualFeesPaid = ["2026": 95]
        let data = try JSONEncoder().encode(wallet)
        XCTAssertEqual(try JSONDecoder().decode(UserCard.self, from: data), wallet)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        ["isPinned", "merchantOffers", "annualFeesPaid"].forEach { object.removeValue(forKey: $0) }
        let legacy = try JSONDecoder().decode(UserCard.self, from: JSONSerialization.data(withJSONObject: object))
        XCTAssertNil(legacy.isPinned)
        XCTAssertNil(legacy.merchantOffers)
        XCTAssertNil(legacy.annualFeesPaid)
    }

    func testWalletMutationsPersistAndPinsDoNotChangeRecommendationOrder() throws {
        let container = try ModelContainer(for: UserCardRecord.self, SpendingRecord.self, CreditUsageRecord.self,
                                           configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        defer { withExtendedLifetime(container) {} }
        let store = CloudStore(context: ModelContext(container))
        let model = CardViewModel(store: store)
        model.allCards = [card(id: "a"), card(id: "b")]
        model.allCards.forEach { model.addCard($0) }
        let first = try XCTUnwrap(model.userCards.first)
        let second = try XCTUnwrap(model.userCards.last)
        model.togglePin(for: second)
        XCTAssertEqual(model.sortedUserCards.first?.id, second.id)
        model.saveOffer(offer(), for: first)
        model.recordAnnualFee(95, year: 2026, for: first)
        var reloaded = CardViewModel(store: store)
        XCTAssertEqual(reloaded.sortedUserCards.first?.id, second.id)
        XCTAssertEqual(reloaded.userCards.first { $0.id == first.id }?.merchantOffers?.count, 1)
        XCTAssertEqual(reloaded.userCards.first { $0.id == first.id }?.annualFeesPaid?["2026"], 95)
        let orderBefore = RecommendationEngine.shared.getRecommendations(for: .dining, userCards: model.userCards, allCards: model.allCards).map { $0.card.id }
        model.togglePin(for: first)
        XCTAssertEqual(RecommendationEngine.shared.getRecommendations(for: .dining, userCards: model.userCards, allCards: model.allCards).map { $0.card.id }, orderBefore)
        model.setOfferArchived(true, offer: offer(), for: first) // A different ID must not delete the saved offer.
        XCTAssertEqual(model.userCards.first?.merchantOffers?.count, 1)
        let saved = try XCTUnwrap(model.userCards.first?.merchantOffers?.first)
        model.setOfferArchived(true, offer: saved, for: first)
        model.recordAnnualFee(nil, year: 2026, for: first)
        reloaded = CardViewModel(store: store)
        XCTAssertEqual(reloaded.userCards.first { $0.id == first.id }?.merchantOffers?.first?.isArchived, true)
        model.setOfferArchived(false, offer: saved, for: first)
        XCTAssertEqual(store.loadUserCards().first { $0.id == first.id }?.merchantOffers?.first?.isArchived, false)
        XCTAssertNil(reloaded.userCards.first { $0.id == first.id }?.annualFeesPaid?["2026"])
        model.clearAllData()
        XCTAssertTrue(store.loadUserCards().isEmpty)
    }

    func testFavoritesNormalizeMerchantIdentityPersistAndClear() throws {
        let suite = "RewardsToolsTests-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = QuickAccessStore(defaults: defaults)
        store.toggle(FavoritePurchase(merchant: "Test Store", category: .dining))
        XCTAssertTrue(store.contains(FavoritePurchase(merchant: "TEST STORE", category: .other)))
        XCTAssertEqual(QuickAccessStore(defaults: defaults).favorites.count, 1)
        store.toggle(FavoritePurchase(merchant: "test store", category: .dining))
        XCTAssertTrue(store.favorites.isEmpty)
        store.toggle(FavoritePurchase(merchant: "", category: .dining))
        store.toggle(FavoritePurchase(merchant: "", category: .gas))
        XCTAssertEqual(store.favorites.count, 2)
        store.reset()
        XCTAssertTrue(QuickAccessStore(defaults: defaults).favorites.isEmpty)
    }

    func testAnnualValueSeparatesRecordedValuesFromCatalogLimitsAndUnknownFees() {
        let catalog = card()
        var wallet = UserCard(card: catalog)
        var received = offer()
        received.redeemedAt = date(2026, 6, 1)
        received.savingsReceived = 20
        var future = offer()
        future.redeemedAt = date(2026, 12, 1)
        future.savingsReceived = 500
        received.isArchived = true
        wallet.merchantOffers = [received, future, offer()]
        let purchases = [
            Spending(amount: 100, merchant: "Test", category: .other, cardUsed: catalog.id, date: date(2026, 6, 1), rewardEarned: 5),
            Spending(amount: 100, merchant: "Future", category: .other, cardUsed: catalog.id, date: date(2026, 12, 1), rewardEarned: 99),
            Spending(amount: 100, merchant: "Old", category: .other, cardUsed: catalog.id, date: date(2025, 12, 31), rewardEarned: 99),
            Spending(amount: 100, merchant: "Other", category: .other, cardUsed: "other", date: date(), rewardEarned: 99)
        ]
        let usages = [
            CreditUsage(cardID: catalog.id, creditID: "credit", periodKey: "2026-06", amountUsed: 3.5),
            CreditUsage(cardID: catalog.id, creditID: "removed-credit", periodKey: "2026-Q1", amountUsed: 2),
            CreditUsage(cardID: catalog.id, creditID: "credit", periodKey: "2026-12", amountUsed: 99),
            CreditUsage(cardID: catalog.id, creditID: "credit", periodKey: "2025-12", amountUsed: 99)
        ]
        var value = AnnualCardValue.calculate(card: catalog, userCard: wallet, year: 2026,
                                              spendings: purchases, usages: usages, now: date(), calendar: calendar)
        XCTAssertEqual(value.purchaseRewards, 5)
        XCTAssertEqual(value.creditsUsed, 5.5)
        XCTAssertEqual(value.offerSavings, 20)
        XCTAssertEqual(value.recordedValue, 30.5)
        XCTAssertEqual(value.catalogCreditLimit, 120)
        XCTAssertNil(value.netValue)
        wallet.annualFeesPaid = ["2026": 95]
        value = AnnualCardValue.calculate(card: catalog, userCard: wallet, year: 2026,
                                         spendings: purchases, usages: usages, now: date(), calendar: calendar)
        XCTAssertEqual(value.netValue, -64.5)
    }

    func testRemindersUsePartialBalanceSkipUsedPeriodsAndReplenish() throws {
        let catalog = card()
        let wallet = UserCard(card: catalog)
        let usages = [CreditUsage(cardID: catalog.id, creditID: "credit", periodKey: "2026-11", amountUsed: 3.5)]
        let reminders = BenefitReminderPlanner.reminders(userCards: [wallet], catalog: [catalog], usages: usages, now: date(), calendar: calendar)
        let current = reminders.filter { $0.id.contains("2026-11") }
        XCTAssertEqual(current.map(\.date), [date(2026, 11, 24, hour: 9), date(2026, 11, 28, hour: 9), date(2026, 11, 30, hour: 9)])
        XCTAssertTrue(current.allSatisfy { $0.remaining == 6.5 })
        let full = [CreditUsage(cardID: catalog.id, creditID: "credit", periodKey: "2026-11", amountUsed: 10)]
        let updated = BenefitReminderPlanner.reminders(userCards: [wallet], catalog: [catalog], usages: full, now: date(), calendar: calendar)
        XCTAssertFalse(updated.contains { $0.id.contains("2026-11") })
        XCTAssertTrue(updated.contains { $0.id.contains("2026-12") && $0.remaining == 10 })
        XCTAssertTrue(BenefitReminderPlanner.reminders(userCards: [], catalog: [catalog], usages: [], now: date()).isEmpty)
    }

    func testRemindersRespectCadenceBudgetAndNeverScheduleInPast() {
        for cadence in CreditCadence.allCases {
            let catalog = card(cadence: cadence)
            let reminders = BenefitReminderPlanner.reminders(userCards: [UserCard(card: catalog)], catalog: [catalog], usages: [], now: date(), calendar: calendar, limit: 2)
            XCTAssertLessThanOrEqual(reminders.count, 2)
            XCTAssertTrue(reminders.allSatisfy { $0.date > date() })
            XCTAssertEqual(reminders.map(\.date), reminders.map(\.date).sorted())
        }
        let catalog = card()
        let justBeforeReset = date(2026, 11, 30, hour: 10)
        let future = BenefitReminderPlanner.reminders(userCards: [UserCard(card: catalog)], catalog: [catalog], usages: [], now: justBeforeReset, calendar: calendar)
        XCTAssertFalse(future.contains { $0.id.contains("2026-11") })
        XCTAssertEqual(Set(future.map(\.id)).count, future.count)
    }
}
