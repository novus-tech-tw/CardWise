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
        case superseded
        case systemRefused(String)

        var errorDescription: String? {
            switch self {
            case .disabled:
                return "Live Activities are turned off for CardWise. Turn them on in Settings › CardWise."
            case .noRecommendation:
                return "Add a card to your wallet and enter an amount greater than zero first."
            case .superseded:
                return "A newer shopping-mode request replaced this one."
            case .systemRefused(let reason):
                return "iOS could not start shopping mode: \(reason)"
            }
        }
    }

    /// Long enough for one shopping trip; iOS removes the card from the Lock Screen after it ends.
    static let lifetime: TimeInterval = 4 * 60 * 60
    private static var refreshTask: Task<Void, Never>?
    private static var refreshID = UUID()
    private static var latestSnapshot: ShortcutRecommendation.Snapshot?

    static var isActive: Bool {
        Activity<ShoppingActivityAttributes>.activities.contains { $0.activityState == .active || $0.activityState == .stale }
    }

    static func attributes(for purchase: PurchaseContext) -> ShoppingActivityAttributes {
        ShoppingActivityAttributes(merchant: purchase.merchant.trimmingCharacters(in: .whitespacesAndNewlines),
                                   categoryID: purchase.category.rawValue,
                                   categoryName: purchase.category.displayName,
                                   categoryIcon: purchase.category.icon, amount: purchase.amount,
                                   confirmedRewardIDs: purchase.conditions.confirmedRewardIDs.isEmpty ? nil : purchase.conditions.confirmedRewardIDs)
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

    nonisolated static func state(for attributes: ShoppingActivityAttributes, snapshot: ShortcutRecommendation.Snapshot,
                                  now: Date = Date()) -> ShoppingActivityAttributes.ContentState? {
        guard let category = SpendingCategory(rawValue: attributes.categoryID),
              attributes.amount.isFinite, attributes.amount > 0 else { return nil }
        let recommendations = RecommendationEngine.shared.getRecommendations(
            for: category, amount: attributes.amount, userCards: snapshot.userCards, allCards: snapshot.catalog,
            spendings: snapshot.spendings, settings: snapshot.settings, asOf: now,
            purchaseConditions: PurchaseConditions(confirmedRewardIDs: attributes.confirmedRewardIDs ?? [])
        )
        return state(for: recommendations)
    }

    /// Refresh saved recommendations after wallet, spending, catalog or preference changes.
    /// Updates retain the activity identity and its original expiry.
    static func scheduleRefresh(snapshot: ShortcutRecommendation.Snapshot) {
        latestSnapshot = snapshot
        refreshID = UUID()
        let currentID = refreshID
        let previous = refreshTask
        previous?.cancel()
        refreshTask = Task {
            await previous?.value
            guard !Task.isCancelled else { return }
            _ = try? await ShoppingActivityRequest.run {
                for activity in Activity<ShoppingActivityAttributes>.activities {
                    guard currentID == refreshID else { return nil }
                    let now = Date()
                    guard let expiry = activity.content.staleDate, expiry > now,
                          let state = state(for: activity.attributes, snapshot: snapshot, now: now) else {
                        await activity.end(nil, dismissalPolicy: .immediate)
                        continue
                    }
                    await activity.update(ActivityContent(state: state, staleDate: expiry))
                }
                return nil
            }
        }
    }

    /// Replaces any running shopping activity with one for `purchase`.
    @discardableResult
    static func start(purchase: PurchaseContext, recommendations: [CardRecommendation],
                      now: Date = Date()) async throws -> String {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { throw StartError.disabled }
        guard purchase.isValid, !recommendations.isEmpty else { throw StartError.noRecommendation }
        let generation = ShoppingActivityRequest.advance()
        let attributes = attributes(for: purchase)
        guard let id = try await ShoppingActivityRequest.run({
            try await startActivity(attributes: attributes, recommendations: recommendations, now: now, generation: generation)
        }) else { throw StartError.noRecommendation }
        return id
    }

    private static func startActivity(attributes: ShoppingActivityAttributes, recommendations: [CardRecommendation],
                                      now: Date, generation: UUID) async throws -> String {
        guard generation == ShoppingActivityRequest.generation else { throw StartError.superseded }
        let existing = Activity<ShoppingActivityAttributes>.activities.first {
            $0.attributes == attributes && ($0.content.staleDate ?? .distantPast) > now &&
                ($0.activityState == .active || $0.activityState == .stale)
        }
        for activity in Activity<ShoppingActivityAttributes>.activities where activity.id != existing?.id {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        guard generation == ShoppingActivityRequest.generation else { throw StartError.superseded }
        let currentState: ShoppingActivityAttributes.ContentState?
        if let latestSnapshot {
            currentState = state(for: attributes, snapshot: latestSnapshot)
        } else {
            currentState = state(for: recommendations)
        }
        guard let currentState else { throw StartError.noRecommendation }
        let content = ActivityContent(state: currentState, staleDate: now.addingTimeInterval(lifetime))
        if let existing {
            guard existing.activityState == .active || existing.activityState == .stale else {
                throw StartError.systemRefused("The activity was dismissed while shopping mode was starting.")
            }
            await existing.update(content)
            guard generation == ShoppingActivityRequest.generation else { throw StartError.superseded }
            return existing.id
        }
        do {
            let activity = try Activity.request(attributes: attributes, content: content, pushType: nil)
            return activity.id
        } catch {
            throw StartError.systemRefused(error.localizedDescription)
        }
    }

    static func endAll() async {
        await ShoppingActivityRequest.endAll()
    }

    /// Called when the app becomes active: remove activities past their lifetime so a stale
    /// recommendation never lingers on the Lock Screen.
    static func endExpired(now: Date = Date()) async {
        _ = try? await ShoppingActivityRequest.run {
            for activity in Activity<ShoppingActivityAttributes>.activities {
                if let stale = activity.content.staleDate, stale <= now {
                    await activity.end(nil, dismissalPolicy: .immediate)
                }
            }
            return nil
        }
    }
}
