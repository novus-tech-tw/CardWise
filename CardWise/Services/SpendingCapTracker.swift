import Foundation

struct SpendingCapProgress: Identifiable {
    let id: String
    let cardId: String
    let cardName: String
    let category: String
    let currentSpend: Double
    let cap: Double?  // nil means unlimited
    let period: CapPeriod?
    let isRotating: Bool

    var isUnlimited: Bool {
        cap == nil
    }

    var percentage: Double {
        guard let cap = cap, cap > 0 else { return 0 }
        return min((currentSpend / cap) * 100, 100)
    }

    var remaining: Double {
        guard let cap = cap else { return .infinity }
        return max(cap - currentSpend, 0)
    }

    var isNearCap: Bool {
        guard !isUnlimited else { return false }
        return percentage >= 80
    }

    var isAtCap: Bool {
        guard !isUnlimited else { return false }
        return percentage >= 100
    }

    var formattedProgress: String {
        guard let cap = cap else {
            return "$\(Int(currentSpend)) / Unlimited"
        }
        return "$\(Int(currentSpend)) / $\(Int(cap))"
    }

    var formattedRemaining: String {
        guard let cap = cap else {
            return "Unlimited"
        }
        return "$\(Int(max(cap - currentSpend, 0))) remaining"
    }
}

class SpendingCapTracker {
    static let shared = SpendingCapTracker()

    private init() {}

    /// Calculate spending cap progress for all user cards
    func calculateCapProgress(
        userCards: [UserCard],
        allCards: [CreditCard],
        spendings: [Spending],
        asOf date: Date = Date()
    ) -> [SpendingCapProgress] {
        var results: [SpendingCapProgress] = []

        let now = date
        for userCard in userCards {
            guard let card = allCards.first(where: { $0.id == userCard.cardId }) else { continue }
            for rule in card.capRules(userCard: userCard, asOf: now) {
                results.append(SpendingCapProgress(
                    id: "\(card.id)-\(rule.id)", cardId: card.id, cardName: userCard.nickname ?? card.name,
                    category: rule.categories.map(\.displayName).joined(separator: ", "),
                    currentSpend: rule.spent(cardID: card.id, spendings: spendings, asOf: now),
                    cap: rule.cap, period: rule.period, isRotating: rule.isRotating
                ))
            }
        }
        return results.sorted { $0.percentage > $1.percentage }
    }

    /// Check if any caps are near limit and send notifications
    func checkAndNotify(
        userCards: [UserCard],
        allCards: [CreditCard],
        spendings: [Spending]
    ) {
        let progress = calculateCapProgress(userCards: userCards, allCards: allCards, spendings: spendings)

        for cap in progress where cap.isNearCap {
            guard let capValue = cap.cap else { continue }
            NotificationService.shared.scheduleSpendingCapAlert(
                cardName: cap.cardName,
                category: cap.category,
                currentSpend: cap.currentSpend,
                cap: capValue
            )
        }
    }
}
