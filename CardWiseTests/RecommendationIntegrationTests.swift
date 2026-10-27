import Testing
import SwiftData
@testable import CardWise

@Suite struct RecommendationIntegrationTests {
    @Test @MainActor func recordedSpendingChangesTheBestCardAndRecordedReward() throws {
        let capped = CreditCard(
            id: "cap", name: "Capped", issuer: "Test", network: .visa, annualFee: 0,
            rewardType: .cashback, baseReward: 1, baseIsPercentage: true,
            categoryRewards: [CategoryReward(category: .grocery, multiplier: 6, isPercentage: true, cap: 100, capPeriod: .monthly)],
            rotatingCategories: nil, selectableConfig: nil, signUpBonus: nil,
            imageColor: "#000000", imageURL: nil, lastUpdated: nil
        )
        let flat = CreditCard(
            id: "flat", name: "Flat", issuer: "Test", network: .visa, annualFee: 0,
            rewardType: .cashback, baseReward: 2, baseIsPercentage: true, categoryRewards: [],
            rotatingCategories: nil, selectableConfig: nil, signUpBonus: nil,
            imageColor: "#000000", imageURL: nil, lastUpdated: nil
        )
        let container = try ModelContainer(for: UserCardRecord.self, SpendingRecord.self, CreditUsageRecord.self,
                                           configurations: ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none))
        defer { withExtendedLifetime(container) {} }
        let store = CloudStore(context: ModelContext(container))
        let cards = CardViewModel(store: store)
        cards.allCards = [capped, flat]
        cards.addCard(capped)
        cards.addCard(flat)
        let spending = SpendingViewModel(store: store)
        spending.spendings = [Spending(amount: 100, merchant: "Store", category: .grocery, cardUsed: capped.id, rewardEarned: 6)]
        try spending.addSpending(amount: 50, merchant: "Store", category: .grocery, cardUsed: capped.id, cardViewModel: cards)
        let recorded = try #require(spending.spendings.first)
        #expect(recorded.rewardEarned == 0.5)
        #expect(recorded.optimalCardId == flat.id)
        #expect(recorded.missedReward == 0.5)
    }
}
