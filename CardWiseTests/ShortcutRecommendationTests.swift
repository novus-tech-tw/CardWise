import XCTest
@testable import CardWise

final class ShortcutRecommendationTests: XCTestCase {
    private func card(id: String, base: Double, points: Bool = false, fixed: [CategoryReward] = []) -> CreditCard {
        CreditCard(id: id, name: id, issuer: "Test", network: .visa, annualFee: 0,
                   rewardType: points ? .points : .cashback, baseReward: base, baseIsPercentage: !points,
                   categoryRewards: fixed, rotatingCategories: nil, selectableConfig: nil,
                   signUpBonus: nil, imageColor: "#000000", imageURL: nil, lastUpdated: nil)
    }

    func testShortcutUsesSpendingCapsAndMatchesEngineWinner() {
        let capped = card(id: "Capped", base: 1, fixed: [CategoryReward(category: .dining, multiplier: 5,
                                                                     isPercentage: true, cap: 100, capPeriod: .monthly)])
        let fallback = card(id: "Fallback", base: 2)
        let spending = Spending(amount: 100, merchant: "Food", category: .dining, cardUsed: capped.id, rewardEarned: 5)
        let snapshot = ShortcutRecommendation.Snapshot(userCards: [UserCard(card: capped), UserCard(card: fallback)],
                                                        catalog: [capped, fallback], spendings: [spending], settings: RecommendationSettings())
        let result = ShortcutRecommendation.message(category: .dining, amount: 100, snapshot: snapshot)
        XCTAssertTrue(result.hasPrefix("Fallback:"))
        XCTAssertTrue(result.contains("2.00"))
    }

    func testShortcutUsesCustomValuationAndNeverChangesStoredData() {
        let points = card(id: "Points", base: 2, points: true)
        let cash = card(id: "Cash", base: 3)
        var settings = RecommendationSettings()
        settings.ranking = .purchaseReward
        settings.pointValues[points.id] = 2
        let snapshot = ShortcutRecommendation.Snapshot(userCards: [UserCard(card: points), UserCard(card: cash)],
                                                        catalog: [points, cash], spendings: [], settings: settings)
        XCTAssertTrue(ShortcutRecommendation.message(category: .other, amount: 100, snapshot: snapshot).hasPrefix("Points:"))
        XCTAssertTrue(ShortcutRecommendation.message(category: .other, amount: .nan, snapshot: snapshot).contains("greater than zero"))
        XCTAssertTrue(snapshot.spendings.isEmpty)
        XCTAssertEqual(snapshot.settings, settings)
    }

    func testEmptyWalletHasActionableResponse() {
        let snapshot = ShortcutRecommendation.Snapshot(userCards: [], catalog: [], spendings: [], settings: RecommendationSettings())
        XCTAssertEqual(ShortcutRecommendation.message(category: .dining, amount: 100, snapshot: snapshot),
                       "Add a card to your CardWise wallet first.")
    }
}
