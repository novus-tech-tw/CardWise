import Foundation
import SwiftUI

@MainActor
class SpendingViewModel: ObservableObject {
    @Published var spendings: [Spending] = []
    @Published var isLoading = false

    private let store: CloudStore

    init(store: CloudStore) {
        self.store = store
        spendings = store.loadSpendings()
    }

    // MARK: - Persistence (SwiftData via CloudStore)

    private func saveSpendings() {
        try? store.saveSpendings(spendings)
    }

    func clearAllData() {
        spendings = []
        try? store.saveSpendings([])
    }

    // MARK: - Spending Management

    enum SpendingError: LocalizedError {
        case cardNotFound
        case invalidAmount

        var errorDescription: String? {
            switch self {
            case .invalidAmount:
                return "Enter a positive, finite purchase amount"
            case .cardNotFound:
                return "Card not found in your wallet"
            }
        }
    }

    func addSpending(
        amount: Double,
        merchant: String,
        category: SpendingCategory,
        cardUsed: String,
        date: Date = Date(),
        note: String? = nil,
        cardViewModel: CardViewModel,
        notifyCapAlerts: Bool = false,
        settings: RecommendationSettings? = nil,
        includeConditionalRewards: Bool = false
    ) throws {
        // Calculate reward earned
        guard let userCard = cardViewModel.getUserCard(byCardId: cardUsed),
              cardViewModel.getCard(byId: cardUsed) != nil else {
            throw SpendingError.cardNotFound
        }

        guard amount.isFinite, amount > 0 else { throw SpendingError.invalidAmount }
        var rewardSettings = settings ?? RecommendationSettingsStore.shared.settings
        // Missed rewards compare this purchase only, independently of sign-up-goal ordering.
        rewardSettings.ranking = .purchaseReward
        let recommendations = RecommendationEngine.shared.getRecommendations(
            for: category, amount: amount, userCards: cardViewModel.userCards,
            allCards: cardViewModel.allCards, spendings: spendings, settings: rewardSettings, asOf: date, includeConditionalRewards: includeConditionalRewards
        )
        let rewardEarned = recommendations.first { $0.userCard.id == userCard.id }?.estimatedReward ?? 0
        let optimalCard = recommendations.first
        let difference = max(0, (optimalCard?.estimatedReward ?? rewardEarned) - rewardEarned)
        let missedReward: Double? = difference > 0 ? difference : nil

        let spending = Spending(
            amount: amount,
            merchant: merchant,
            category: category,
            cardUsed: cardUsed,
            date: date,
            note: note,
            rewardEarned: rewardEarned,
            optimalCardId: difference > 0 ? optimalCard?.card.id : nil,
            missedReward: missedReward
        )

        spendings.insert(spending, at: 0)
        saveSpendings()

        if notifyCapAlerts {
            SpendingCapTracker.shared.checkAndNotify(
                userCards: cardViewModel.userCards,
                allCards: cardViewModel.allCards,
                spendings: spendings
            )
        }
    }

    func deleteSpending(_ spending: Spending) {
        spendings.removeAll { $0.id == spending.id }
        saveSpendings()
    }

    // MARK: - Analytics

    var totalSpending: Double {
        spendings.reduce(0) { $0 + $1.amount }
    }

    var totalRewardsEarned: Double {
        spendings.reduce(0) { $0 + $1.rewardEarned }
    }

    var totalMissedRewards: Double {
        spendings.compactMap { $0.missedReward }.reduce(0, +)
    }

    var spendingsByCategory: [(SpendingCategory, Double)] {
        let grouped = Dictionary(grouping: spendings, by: { $0.category })
        return grouped.map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.1 > $1.1 }
    }

    var spendingsByCard: [(String, Double)] {
        let grouped = Dictionary(grouping: spendings, by: { $0.cardUsed })
        return grouped.map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.1 > $1.1 }
    }

    func spendingsThisMonth() -> [Spending] {
        let startOfMonth = Date().startOfMonth
        return spendings.filter { $0.date >= startOfMonth }
    }

    func spendingsThisQuarter() -> [Spending] {
        let startOfQuarter = Date().startOfQuarter
        return spendings.filter { $0.date >= startOfQuarter }
    }
}
