import Foundation
import Testing
import SwiftData
@testable import CardWise

@Suite struct RewardPolicyTests {
    private let engine = RecommendationEngine.shared

    private func date(_ day: Int, month: Int = 10, year: Int = 2026) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }

    private func card(id: String = "test", points: Bool = false, base: Double = 1,
                      fixed: [CategoryReward] = [], rotating: [RotatingCategory]? = nil,
                      selectable: SelectableConfig? = nil, bonus: SignUpBonus? = nil) -> CreditCard {
        CreditCard(id: id, name: id, issuer: "Test", network: .visa, annualFee: 0,
                   rewardType: points ? .points : .cashback, baseReward: base, baseIsPercentage: !points,
                   categoryRewards: fixed, rotatingCategories: rotating, selectableConfig: selectable,
                   signUpBonus: bonus, imageColor: "#000000", imageURL: nil, lastUpdated: nil)
    }

    @Test func rotatingCapIsSharedAcrossCategoriesAndExcludesFutureSpending() throws {
        let card = card(rotating: [RotatingCategory(quarter: 4, year: 2026, categories: [.gas, .dining],
                                                   multiplier: 5, isPercentage: true, cap: 100, activationRequired: false)])
        let spending = [
            Spending(amount: 80, merchant: "Restaurant", category: .dining, cardUsed: card.id, date: date(1), rewardEarned: 4),
            Spending(amount: 500, merchant: "Future", category: .gas, cardUsed: card.id, date: date(20), rewardEarned: 25),
            Spending(amount: 500, merchant: "Past", category: .gas, cardUsed: card.id, date: date(1, month: 9), rewardEarned: 25)
        ]
        let rec = try #require(engine.getRecommendations(for: .gas, amount: 50, userCards: [UserCard(card: card)],
                                                         allCards: [card], spendings: spending, asOf: date(15)).first)
        #expect(rec.spendingCapRemaining == 20)
        #expect(abs(rec.estimatedReward - 1.3) < 0.00001)
        #expect(rec.context.contains { $0.contains("the rest earns the base rate") })
    }

    @Test func broadFixedCapIncludesSubcategorySpending() throws {
        let card = card(fixed: [CategoryReward(category: .grocery, multiplier: 6, isPercentage: true, cap: 100, capPeriod: .monthly)])
        let spending = [Spending(amount: 80, merchant: "Whole Foods", category: .wholeFoods, cardUsed: card.id, date: date(1), rewardEarned: 4.8)]
        let rec = try #require(engine.getRecommendations(for: .grocery, amount: 50, userCards: [UserCard(card: card)],
                                                         allCards: [card], spendings: spending, asOf: date(15)).first)
        #expect(rec.spendingCapRemaining == 20)
        #expect(abs(rec.estimatedReward - 1.5) < 0.00001)
    }

    @Test func selectableCapIsSharedAndUnselectedBonusIsExplained() throws {
        let config = SelectableConfig(maxSelections: 2, availableCategories: [.gas, .dining], multiplier: 5,
                                      isPercentage: true, cap: 100, capPeriod: .monthly)
        let card = card(selectable: config)
        var user = UserCard(card: card)
        user.selectedCategories = [.gas, .dining]
        let spending = [Spending(amount: 100, merchant: "Food", category: .dining, cardUsed: card.id, date: date(1), rewardEarned: 5)]
        let rec = try #require(engine.getRecommendations(for: .gas, amount: 50, userCards: [user], allCards: [card],
                                                         spendings: spending, asOf: date(15)).first)
        #expect(rec.estimatedReward == 0.5)
        #expect(rec.displayReward == "1%")
        #expect(rec.context.contains { $0.contains("exhausted") })
        user.selectedCategories = []
        let unselected = try #require(engine.getRecommendations(for: .gas, amount: 50, userCards: [user], allCards: [card], asOf: date(15)).first)
        #expect(unselected.estimatedReward == 0.5)
        #expect(unselected.context.contains { $0.contains("not selected") })
    }

    @Test func expiredQuarterIsNeverReused() throws {
        let card = card(rotating: [RotatingCategory(quarter: 4, year: 2025, categories: [.gas], multiplier: 5,
                                                   isPercentage: true, cap: 100, activationRequired: false)])
        let rec = try #require(engine.getRecommendations(for: .gas, userCards: [UserCard(card: card)], allCards: [card], asOf: date(15)).first)
        #expect(rec.estimatedReward == 1)
        #expect(!rec.isRotating)
        #expect(rec.context.contains { $0.contains("Older schedules are not applied") })
    }

    @Test func eligibleRotatingRewardCanBeatFixedReward() throws {
        let card = card(fixed: [CategoryReward(category: .gas, multiplier: 3, isPercentage: true, cap: nil, capPeriod: nil)],
                        rotating: [RotatingCategory(quarter: 4, year: 2026, categories: [.gas], multiplier: 5,
                                                    isPercentage: true, cap: nil, activationRequired: true)])
        var user = UserCard(card: card)
        let inactive = try #require(engine.getRecommendations(for: .gas, userCards: [user], allCards: [card], asOf: date(15)).first)
        #expect(inactive.estimatedReward == 3)
        #expect(inactive.needsActivation)
        user.setRotatingActivated(true, quarter: 4, year: 2026)
        let active = try #require(engine.getRecommendations(for: .gas, userCards: [user], allCards: [card], asOf: date(15)).first)
        #expect(active.estimatedReward == 5)
        #expect(!active.needsActivation)
    }

    @Test func customPointValueChangesRankingWithoutChangingCashback() throws {
        let points = card(id: "points", points: true, base: 2.5)
        let cash = card(id: "cash", base: 3)
        let wallet = [UserCard(card: points), UserCard(card: cash)]
        var settings = RecommendationSettings()
        #expect(engine.getRecommendations(for: .other, userCards: wallet, allCards: [points, cash]).first?.card.id == cash.id)
        settings.pointValues[points.id] = 2
        settings.pointValues[cash.id] = 100
        let recs = engine.getRecommendations(for: .other, userCards: wallet, allCards: [points, cash], settings: settings)
        #expect(recs.first?.card.id == points.id)
        #expect(recs.first?.estimatedReward == 5)
        #expect(recs.first?.displayReward == "2.5x")
        #expect(recs.last?.estimatedReward == 3)
    }

    @Test func signupRankingCanBeDisabledAndDoesNotAddBonusValue() throws {
        let bonus = SignUpBonus(bonusAmount: 200, bonusType: .cashback, spendRequirement: 500, timeframeDays: 30, description: "Test goal")
        let goal = card(id: "goal", bonus: bonus)
        let cash = card(id: "cash", base: 3)
        var user = UserCard(card: goal)
        user.signUpBonusStartDate = date(1)
        var settings = RecommendationSettings()
        let goalFirst = engine.getRecommendations(for: .other, userCards: [user, UserCard(card: cash)], allCards: [goal, cash], settings: settings, asOf: date(15))
        #expect(goalFirst.first?.card.id == goal.id)
        #expect(goalFirst.first?.estimatedReward == 1)
        settings.ranking = .purchaseReward
        #expect(engine.getRecommendations(for: .other, userCards: [user, UserCard(card: cash)], allCards: [goal, cash], settings: settings, asOf: date(15)).first?.card.id == cash.id)
    }

    @Test func signupUsesExclusiveDeadlineAndRejectsNotYetStartedGoal() throws {
        let card = card(bonus: SignUpBonus(bonusAmount: 200, bonusType: .cashback, spendRequirement: 500, timeframeDays: 10, description: "Goal"))
        var user = UserCard(card: card)
        user.signUpBonusStartDate = date(1)
        let spending = [
            Spending(amount: 100, merchant: "Eligible", category: .other, cardUsed: card.id, date: date(10), rewardEarned: 1),
            Spending(amount: 500, merchant: "At deadline", category: .other, cardUsed: card.id, date: date(11), rewardEarned: 5)
        ]
        let progress = try #require(engine.signUpBonusProgress(card: card, userCard: user, spendings: spending, asOf: date(11)))
        #expect(progress.spentSoFar == 100)
        #expect(!progress.isInProgress)
        let justBefore = try #require(engine.signUpBonusProgress(card: card, userCard: user, spendings: spending, asOf: date(11).addingTimeInterval(-1)))
        #expect(justBefore.isInProgress)
        #expect(justBefore.daysRemaining == 1)
        let notStarted = try #require(engine.signUpBonusProgress(card: card, userCard: user, spendings: spending, asOf: date(1).addingTimeInterval(-1)))
        #expect(!notStarted.isInProgress)
        #expect(notStarted.spentSoFar == 0)
    }

    @Test(arguments: [Double.nan, Double.infinity, -10, 0]) func invalidPurchaseAmountProducesNoEstimate(amount: Double) {
        let card = card()
        #expect(engine.getRecommendations(for: .other, amount: amount, userCards: [UserCard(card: card)], allCards: [card]).isEmpty)
    }

    @Test(arguments: [Double.nan, Double.infinity, -1, 0, 101]) func invalidPointValueFallsBackToOneCent(value: Double) {
        var settings = RecommendationSettings()
        settings.pointValues["test"] = value
        #expect(settings.dollarsPerPoint(for: "test") == 0.01)
    }

    @Test @MainActor func widgetUsesSameSpendingValuationAndMerchantContext() throws {
        let card = card(points: true, fixed: [CategoryReward(category: .dining, multiplier: 4, isPercentage: false, cap: 100, capPeriod: .monthly)])
        let user = UserCard(card: card)
        let spending = [Spending(amount: 80, merchant: "Cafe", category: .dining, cardUsed: card.id, date: date(1), rewardEarned: 3.2)]
        var settings = RecommendationSettings()
        settings.widgetCategory = .gas
        settings.widgetMerchant = "Starbucks"
        settings.widgetAmount = 50
        settings.pointValues[card.id] = 2
        let payload = WidgetDataManager.makePayload(userCards: [user], allCards: [card], spendings: spending, settings: settings, asOf: date(15))
        let expected = try #require(engine.getRecommendations(for: .dining, amount: 50, userCards: [user], allCards: [card], spendings: spending, settings: settings, asOf: date(15)).first)
        #expect(payload.topCategory == "Dining")
        #expect(payload.purchaseContext?.contains("Starbucks") == true)
        #expect(payload.explanation?.contains(expected.formattedEstimatedReward) == true)
        #expect(!payload.isStale(at: date(15)))
        #expect(payload.isStale(at: date(16)))
    }

    @Test @MainActor func settingsPersistAndReset() throws {
        let suite = "CardWiseTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = RecommendationSettingsStore(defaults: defaults)
        store.settings.pointValues["card"] = 1.75
        store.settings.widgetAmount = 45
        store.settings.ranking = .purchaseReward
        let reloaded = RecommendationSettingsStore(defaults: defaults)
        #expect(reloaded.settings == store.settings)
        reloaded.reset()
        #expect(RecommendationSettingsStore(defaults: defaults).settings == RecommendationSettings())
    }

    @Test(arguments: CreditCadence.allCases) func benefitResetMovesToNextPeriod(cadence: CreditCadence) {
        let now = date(31, month: 12)
        let next = CreditPeriod.nextReset(for: now, cadence: cadence)
        #expect(next > now)
        #expect(CreditPeriod.key(for: next, cadence: cadence) != CreditPeriod.key(for: now, cadence: cadence))
        #expect(Calendar.current.component(.year, from: next) == 2027)
        #expect(Calendar.current.component(.month, from: next) == 1)
    }

    @Test func legacyWidgetPayloadDecodesAndRequiresRefresh() throws {
        let payload = WidgetPayload(topCategory: "Dining", topCategoryIcon: "fork.knife", bestCard: "Card", bestCardColor: "#000000", rewardRate: "3%", rotatingCategories: [], rotatingCard: nil, spendingThisMonth: 0, rewardsThisMonth: 0)
        let decoded = try JSONDecoder().decode(WidgetPayload.self, from: JSONEncoder().encode(payload))
        #expect(decoded.isStale(at: Date()))
    }
    @Test func conditionalCatalogRatesRequireAnExplicitPurchaseAssumption() throws {
        let standard = CategoryReward(category: .travel, multiplier: 2, isPercentage: true, cap: nil, capPeriod: nil)
        let portal = CategoryReward(category: .travel, multiplier: 5, isPercentage: true, cap: nil, capPeriod: nil, note: "Booked through Chase Travel")
        let card = card(fixed: [standard, portal])
        let user = UserCard(card: card)
        let ordinary = try #require(engine.getRecommendations(for: .travel, userCards: [user], allCards: [card]).first)
        #expect(ordinary.estimatedReward == 2)
        #expect(ordinary.context.contains { $0.contains("Not included") && $0.contains("Chase Travel") })
        let conditional = try #require(engine.getRecommendations(for: .travel, userCards: [user], allCards: [card], includeConditionalRewards: true).first)
        #expect(conditional.estimatedReward == 5)
        #expect(standard.id != portal.id)
        let roundTrip = try JSONDecoder().decode(CategoryReward.self, from: JSONEncoder().encode(portal))
        #expect(roundTrip.note == portal.note)
    }

    @Test func capDashboardAndEngineShareTheSameCategoryLedger() throws {
        let card = card(fixed: [CategoryReward(category: .grocery, multiplier: 6, isPercentage: true, cap: 100, capPeriod: .monthly)])
        let user = UserCard(card: card)
        let spending = [Spending(amount: 80, merchant: "Whole Foods", category: .wholeFoods, cardUsed: card.id, date: date(1), rewardEarned: 4.8)]
        let progress = try #require(SpendingCapTracker.shared.calculateCapProgress(userCards: [user], allCards: [card], spendings: spending, asOf: date(15)).first)
        let rec = try #require(engine.getRecommendations(for: .grocery, userCards: [user], allCards: [card], spendings: spending, asOf: date(15)).first)
        #expect(progress.remaining == rec.spendingCapRemaining)
        #expect(progress.currentSpend == 80)
    }

    @Test @MainActor func customSignupOfferPersistsWithoutCatalogOrSchemaChanges() throws {
        let container = try ModelContainer(for: UserCardRecord.self, SpendingRecord.self, CreditUsageRecord.self,
                                           configurations: ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none))
        defer { withExtendedLifetime(container) {} }
        let store = CloudStore(context: ModelContext(container))
        let model = CardViewModel(store: store)
        let card = card()
        model.allCards = [card]
        model.addCard(card)
        let user = try #require(model.userCards.first)
        let offer = SignUpBonus(bonusAmount: 200, bonusType: .cashback, spendRequirement: 500, timeframeDays: 90, description: "My offer")
        model.updateSignUpOffer(for: user, bonus: offer)
        let saved = try #require(store.loadUserCards().first)
        #expect(saved.customSignUpBonus == offer)
        #expect(saved.signUpBonusStartDate != nil)
        let rec = try #require(engine.getRecommendations(for: .other, userCards: [saved], allCards: [card]).first)
        #expect(rec.hasSignUpBonusInProgress)
        model.updateSignUpOffer(for: saved, bonus: nil)
        #expect(model.userCards.first?.signUpBonusStartDate == nil)
        var legacy = try #require(JSONSerialization.jsonObject(with: JSONEncoder().encode(saved)) as? [String: Any])
        legacy.removeValue(forKey: "customSignUpBonus")
        let decoded = try JSONDecoder().decode(UserCard.self, from: JSONSerialization.data(withJSONObject: legacy))
        #expect(decoded.customSignUpBonus == nil)
    }

}
