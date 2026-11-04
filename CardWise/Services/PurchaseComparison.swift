import Foundation

struct PurchaseComparison: Identifiable {
    let recommendation: CardRecommendation
    let offers: [MerchantOffer]
    let amount: Double
    let date: Date
    var id: String { recommendation.id }

    /// Multiple issuer offers are alternatives; never assume they stack together.
    var bestOfferSavings: Double {
        offers.compactMap { $0.estimatedSavings(for: amount, at: date) }.max() ?? 0
    }

    var combinedEstimate: Double { recommendation.estimatedReward + bestOfferSavings }

    static func rows(recommendations: [CardRecommendation], merchant: String, amount: Double,
                     asOf date: Date = Date(), includeOffers: Bool = false) -> [PurchaseComparison] {
        guard amount.isFinite, amount > 0 else { return [] }
        let rows = recommendations.map { recommendation in
            PurchaseComparison(recommendation: recommendation,
                               offers: (recommendation.userCard.merchantOffers ?? []).filter {
                                   $0.isValid && $0.isArchived != true && $0.matches(merchant) && $0.expiresAt > date && $0.redeemedAt == nil
                               }, amount: amount, date: date)
        }
        return rows.enumerated().sorted {
            let left = includeOffers ? $0.element.combinedEstimate : $0.element.recommendation.estimatedReward
            let right = includeOffers ? $1.element.combinedEstimate : $1.element.recommendation.estimatedReward
            return left == right ? $0.offset < $1.offset : left > right
        }.map(\.element)
    }
}
