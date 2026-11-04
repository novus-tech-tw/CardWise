import SwiftUI

struct PurchaseConditionsView: View {
    @EnvironmentObject var cardViewModel: CardViewModel
    let category: SpendingCategory
    @Binding var conditions: PurchaseConditions

    private struct RateTerms: Identifiable {
        let id: String
        let card: String
        let rate: String
        let note: String
    }

    private var terms: [RateTerms] {
        cardViewModel.userCards.flatMap { wallet -> [RateTerms] in
            guard let card = cardViewModel.getCard(for: wallet) else { return [] }
            return card.categoryRewards.filter { category.isCovered(by: [$0.category]) && $0.requiresPurchaseConfirmation }.map {
                RateTerms(id: PurchaseConditions.key(cardID: card.id, reward: $0), card: wallet.nickname ?? card.name,
                          rate: $0.displayMultiplier, note: $0.note ?? "")
            }
        }.reduce(into: [RateTerms]()) { result, row in
            if !result.contains(where: { $0.id == row.id }) { result.append(row) }
        }
    }

    var body: some View {
        if !terms.isEmpty {
            DisclosureGroup("Purchase conditions") {
                Text("Standard rates apply until you confirm the terms for this purchase. Each confirmation applies only to the named card and rate.")
                    .font(.caption).foregroundStyle(.secondary)
                ForEach(terms) { term in
                    Toggle(isOn: Binding(
                        get: { conditions.confirmedRewardIDs.contains(term.id) },
                        set: { confirmed in
                            if confirmed { conditions.confirmedRewardIDs.insert(term.id) } else { conditions.confirmedRewardIDs.remove(term.id) }
                        }
                    )) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(term.card) · \(term.rate)").font(.subheadline)
                            Text(term.note).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}
