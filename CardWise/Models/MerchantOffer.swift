import Foundation

/// An offer entered and confirmed by the user, attached to one wallet card.
struct MerchantOffer: Codable, Equatable, Identifiable {
    enum RewardKind: String, Codable, CaseIterable {
        case cash, percent
        var title: String { self == .cash ? "Cash back" : "Percent back" }
    }

    var id = UUID().uuidString
    var merchant: String
    var title: String
    var minimumSpend: Double
    var reward: Double
    var rewardKind: RewardKind
    var maximumReward: Double?
    /// Exclusive boundary: midnight following the final eligible day.
    var expiresAt: Date
    var isArchived: Bool?
    var isActivated = false
    var redeemedAt: Date?
    var savingsReceived: Double?

    static func merchantKey(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
    }

    func matches(_ query: String) -> Bool { Self.merchantKey(merchant) == Self.merchantKey(query) }

    var isValid: Bool {
        !merchant.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        minimumSpend.isFinite && minimumSpend >= 0 && reward.isFinite && reward > 0 &&
        (rewardKind != .percent || reward <= 100) &&
        (maximumReward == nil || (maximumReward?.isFinite == true && (maximumReward ?? 0) > 0)) &&
        (savingsReceived == nil || (savingsReceived?.isFinite == true && (savingsReceived ?? -1) >= 0))
    }

    func estimatedSavings(for amount: Double, at date: Date = Date()) -> Double? {
        guard isValid, isArchived != true, isActivated, redeemedAt == nil, date < expiresAt,
              amount.isFinite, amount > 0, amount >= minimumSpend else { return nil }
        let value = rewardKind == .cash ? reward : amount * reward / 100
        return min(value, maximumReward ?? value, amount)
    }
}
