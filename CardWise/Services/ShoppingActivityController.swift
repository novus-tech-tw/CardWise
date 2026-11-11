import ActivityKit
import Foundation

/// Starts and ends the "shopping mode" Live Activity that keeps the best card for one
/// purchase on the Lock Screen and in the Dynamic Island. Local only: no push token is
/// requested, and the activity goes stale on its own after `lifetime`.
@MainActor
enum ShoppingActivityController {
    enum StartError: LocalizedError, Equatable {
        case disabled
        case noRecommendation
        case systemRefused(String)

        var errorDescription: String? {
            switch self {
            case .disabled:
                return "Live Activities are turned off for CardWise. Turn them on in Settings › CardWise."
            case .noRecommendation:
                return "Add a card to your wallet and enter an amount greater than zero first."
            case .systemRefused(let reason):
                return "iOS could not start shopping mode: \(reason)"
            }
        }
    }

    /// Long enough for one shopping trip; iOS removes the card from the Lock Screen after it ends.
    static let lifetime: TimeInterval = 4 * 60 * 60

    static var isActive: Bool { !Activity<ShoppingActivityAttributes>.activities.isEmpty }

    static func attributes(for purchase: PurchaseContext) -> ShoppingActivityAttributes {
        ShoppingActivityAttributes(merchant: purchase.merchant.trimmingCharacters(in: .whitespacesAndNewlines),
                                   categoryID: purchase.category.rawValue,
                                   categoryName: purchase.category.displayName,
                                   categoryIcon: purchase.category.icon, amount: purchase.amount)
    }

    /// Pure mapping from engine output to the Live Activity state (unit-tested).
    nonisolated static func state(for recommendations: [CardRecommendation]) -> ShoppingActivityAttributes.ContentState? {
        guard let best = recommendations.first else { return nil }
        var note: String?
        if best.needsActivation {
            note = "Confirm quarterly activation with the issuer"
        } else if best.isNearSpendingCap, let remaining = best.spendingCapRemaining {
            note = "Bonus cap: \(remaining.formatted(.currency(code: "USD"))) left"
        } else if recommendations.count > 1 {
            let next = recommendations[1]
            note = "Next: \(next.userCard.nickname ?? next.card.name) · \(next.displayReward)"
        }
        return .init(cardName: best.userCard.nickname ?? best.card.name, cardColor: best.card.imageColor,
                     rewardRate: best.displayReward, estimatedReward: best.formattedEstimatedReward, note: note)
    }

    /// Replaces any running shopping activity with one for `purchase`.
    @discardableResult
    static func start(purchase: PurchaseContext, recommendations: [CardRecommendation],
                      now: Date = Date()) async throws -> String {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { throw StartError.disabled }
        guard purchase.isValid, let state = state(for: recommendations) else { throw StartError.noRecommendation }
        await endAll()
        let content = ActivityContent(state: state, staleDate: now.addingTimeInterval(lifetime))
        do {
            let activity = try Activity.request(attributes: attributes(for: purchase), content: content, pushType: nil)
            return activity.id
        } catch {
            throw StartError.systemRefused(error.localizedDescription)
        }
    }

    static func endAll() async {
        for activity in Activity<ShoppingActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }

    /// Called when the app becomes active: remove activities past their lifetime so a stale
    /// recommendation never lingers on the Lock Screen.
    static func endExpired(now: Date = Date()) async {
        for activity in Activity<ShoppingActivityAttributes>.activities {
            if let stale = activity.content.staleDate, stale <= now {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
}
