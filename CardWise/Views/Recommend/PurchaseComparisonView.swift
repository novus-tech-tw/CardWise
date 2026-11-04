import SwiftUI

struct PurchaseComparisonView: View {
    let recommendations: [CardRecommendation]
    let merchant: String
    let amount: Double
    @State private var includeOffers = false

    private var rows: [PurchaseComparison] {
        PurchaseComparison.rows(recommendations: recommendations, merchant: merchant, amount: amount, includeOffers: includeOffers)
    }

    var body: some View {
        Section("Compare this purchase") {
            if rows.contains(where: { $0.bestOfferSavings > 0 }) {
                Toggle("Include one eligible offer", isOn: $includeOffers)
                Text("Includes the best saved offer per card. Confirm your issuer allows it with these rewards.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            if let first = rows.first, let second = rows.dropFirst().first {
                let difference = includeOffers ? first.combinedEstimate - second.combinedEstimate
                    : first.recommendation.estimatedReward - second.recommendation.estimatedReward
                Text(difference < 0.005 ? "The top two cards have the same estimated value."
                     : "\(first.recommendation.userCard.nickname ?? first.recommendation.card.name) earns about \(difference.formatted(.currency(code: "USD"))) more than the next card.")
                    .font(.subheadline)
            }
            ForEach(rows) { row in
                DisclosureGroup {
                    LabeledContent("Purchase reward", value: row.recommendation.formattedEstimatedReward)
                    if includeOffers, row.bestOfferSavings > 0 {
                        LabeledContent("One eligible offer", value: row.bestOfferSavings.formatted(.currency(code: "USD")))
                    }
                    ForEach(row.offers) { offer in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(offer.title).font(.subheadline)
                            Text(offerStatus(offer)).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    if row.offers.isEmpty { Text("No matching saved merchant offers.").font(.caption).foregroundStyle(.secondary) }
                    NavigationLink("Review saved offers") {
                        MerchantOffersView(userCard: row.recommendation.userCard)
                    }
                    RecommendationContextView(recommendation: row.recommendation)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(row.recommendation.userCard.nickname ?? row.recommendation.card.name)
                            .font(.subheadline.weight(.semibold))
                        Text("\((includeOffers ? row.combinedEstimate : row.recommendation.estimatedReward).formatted(.currency(code: "USD"))) estimated\(includeOffers ? " with offer" : " purchase reward")")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            Text("Sorted by purchase value. Sign-up goals stay separate. Uses recorded spending and your confirmed offers.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .onChange(of: merchant) { _, _ in includeOffers = false }
    }

    private func offerStatus(_ offer: MerchantOffer) -> String {
        if !offer.isActivated { return "Saved · issuer activation not confirmed" }
        if amount < offer.minimumSpend {
            return "Activation confirmed by you · needs \((offer.minimumSpend - amount).formatted(.currency(code: "USD"))) more spending"
        }
        return "Activation confirmed by you · \((offer.estimatedSavings(for: amount) ?? 0).formatted(.currency(code: "USD"))) potential savings"
    }
}
