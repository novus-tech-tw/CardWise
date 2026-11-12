import SwiftUI

struct WalletOffersView: View {
    @EnvironmentObject var cardViewModel: CardViewModel
    var initialDestination: WalletOfferDestination?
    @State private var scope = WalletOfferScope.current
    @State private var walletID: String?
    @State private var search = ""
    @State private var destination: WalletOfferDestination?
    @State private var openedInitialDestination = false

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { timeline in
            let matches = WalletOfferQuery.inventory(userCards: cardViewModel.userCards, catalog: cardViewModel.allCards,
                                                      scope: scope, walletID: walletID, now: timeline.date)
            let query = search.trimmingCharacters(in: .whitespacesAndNewlines)
            let visible = matches.filter { match in
                query.isEmpty || [match.offer.merchant, match.offer.title, match.cardName].contains { $0.localizedStandardContains(query) }
            }
            List {
                Section {
                    Picker("Status", selection: $scope) {
                        ForEach(WalletOfferScope.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .accessibilityIdentifier("offer-status-filter")
                    Picker("Card", selection: $walletID) {
                        Text("All cards").tag(String?.none)
                        ForEach(cardViewModel.sortedUserCards) { wallet in
                            Text(cardName(wallet)).tag(Optional(wallet.id))
                        }
                    }
                    .accessibilityIdentifier("offer-card-filter")
                }
                Section {
                    if visible.isEmpty {
                        Text(query.isEmpty ? "No \(scope.rawValue.lowercased()) offers for these cards." : "No offers match your search.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(visible) { match in
                        Button { destination = match.destination } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                MerchantOfferRow(offer: match.offer)
                                Text(match.cardName).font(.caption).foregroundStyle(.secondary)
                            }.frame(maxWidth: .infinity, alignment: .leading)
                        }.tint(Theme.textPrimary)
                            .accessibilityIdentifier(match.id)
                    }
                } header: {
                    Text("\(visible.count) \(scope.rawValue.lowercased()) \(visible.count == 1 ? "offer" : "offers")")
                } footer: {
                    Text("Current offers exclude used, expired and archived entries. Activation and savings are confirmed by you; check issuer terms before purchasing.")
                }
                Section("Manage Offers by Card") {
                    if cardViewModel.userCards.isEmpty { Text("Add a card before entering an offer.") }
                    ForEach(cardViewModel.sortedUserCards) { wallet in
                        NavigationLink(cardName(wallet)) { MerchantOffersView(userCard: wallet) }
                    }
                }
            }
        }
        .navigationTitle("Your Offers")
        .searchable(text: $search, placement: .navigationBarDrawer(displayMode: .always), prompt: "Merchant, offer or card")
        .onChange(of: cardViewModel.userCards.map(\.id)) { _, ids in
            if let walletID, !ids.contains(walletID) { self.walletID = nil }
        }
        .onAppear {
            if !openedInitialDestination, let initialDestination {
                openedInitialDestination = true
                destination = initialDestination
            }
        }
        .navigationDestination(item: $destination) { target in
            if let wallet = cardViewModel.userCards.first(where: { $0.id == target.walletID }),
               (wallet.merchantOffers ?? []).contains(where: { $0.id == target.offerID }) {
                MerchantOffersView(userCard: wallet, initialOfferID: target.offerID)
            } else {
                ContentUnavailableView("Offer Unavailable", systemImage: "tag",
                                       description: Text("This offer or card is no longer in your wallet."))
            }
        }
    }

    private func cardName(_ wallet: UserCard) -> String {
        wallet.nickname ?? cardViewModel.getCard(for: wallet)?.name ?? "Saved card"
    }
}
