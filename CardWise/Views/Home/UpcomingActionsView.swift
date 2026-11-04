import SwiftUI

struct UpcomingActionsCard: View {
    @EnvironmentObject var cardViewModel: CardViewModel
    @EnvironmentObject var spendingViewModel: SpendingViewModel
    @State private var selected: UpcomingAction?
    @State private var expanded = false

    private var items: [UpcomingAction] {
        UpcomingActions.items(userCards: cardViewModel.userCards, catalog: cardViewModel.allCards,
                              usages: cardViewModel.creditUsages, spendings: spendingViewModel.spendings)
    }

    var body: some View {
        if !cardViewModel.userCards.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Coming Up").font(.headline)
                if items.isEmpty {
                    Label("Nothing due in the next 30 days", systemImage: "checkmark.circle")
                        .font(.subheadline).foregroundStyle(.secondary)
                    Text("Quarterly activation checks also appear here when needed.").font(.caption).foregroundStyle(.secondary)
                }
                ForEach(expanded ? items : Array(items.prefix(3))) { item in
                    Button { selected = item } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.textPrimary)
                            Text(item.cardName).font(.caption).foregroundStyle(.secondary)
                            Text("\(item.detail) \(displayDate(item).formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                        .contentShape(Rectangle())
                    }.buttonStyle(.plain)
                    Divider()
                }
                if items.count > 3 {
                    Button(expanded ? "Show fewer" : "Show all \(items.count) actions") { expanded.toggle() }
                        .font(.subheadline)
                }
            }
            .sectionCard()
            .sheet(item: $selected) { item in UpcomingActionDetail(action: item) }
        }
    }

    private func displayDate(_ item: UpcomingAction) -> Date {
        if case .offer = item.kind { return item.deadline.addingTimeInterval(-1) }
        return item.deadline
    }
}

private struct UpcomingActionDetail: View {
    let action: UpcomingAction
    @EnvironmentObject var cardViewModel: CardViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if let wallet = cardViewModel.userCards.first(where: { $0.id == action.walletID }),
                   let card = cardViewModel.getCard(for: wallet) {
                    detail(wallet: wallet, card: card)
                } else {
                    Text("This card is no longer in your wallet.")
                }
            }
            .navigationTitle(action.cardName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }
    }

    @ViewBuilder
    private func detail(wallet: UserCard, card: CreditCard) -> some View {
        switch action.kind {
        case .credit(let id):
            Form {
                if let credit = card.credits?.first(where: { $0.id == id }) {
                    CreditUsageEditor(card: card, credit: credit)
                } else { Text("This credit is no longer listed in the card catalog.") }
            }
        case .activation:
            Form {
                if let rotating = card.rotatingCategory(asOf: Date()) {
                    Text("Q\(rotating.quarter) · \(rotating.categories.map(\.displayName).joined(separator: ", "))")
                    Toggle("Activated with issuer (confirmed by you)", isOn: Binding(
                        get: { wallet.hasActivatedRotating(quarter: rotating.quarter, year: rotating.year) },
                        set: { cardViewModel.setRotatingActivated(for: wallet, activated: $0) }
                    ))
                    Text("Activate with your card issuer first, then record confirmation here.").font(.caption).foregroundStyle(.secondary)
                }
            }
        case .signup:
            Form { SignUpBonusSection(card: card, userCard: wallet) }
        case .offer(let id):
            MerchantOffersView(userCard: wallet, initialOfferID: id)
        }
    }
}
