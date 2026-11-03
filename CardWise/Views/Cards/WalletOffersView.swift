import SwiftUI

struct WalletOffersView: View {
    @EnvironmentObject var cardViewModel: CardViewModel
    var body: some View {
        List {
            if cardViewModel.userCards.isEmpty { Text("Add a card before entering an offer.") }
            ForEach(cardViewModel.sortedUserCards) { wallet in
                NavigationLink {
                    MerchantOffersView(userCard: wallet)
                } label: {
                    LabeledContent(wallet.nickname ?? cardViewModel.getCard(for: wallet)?.name ?? "Card",
                                   value: "\((wallet.merchantOffers ?? []).filter { $0.isArchived != true }.count) offers")
                }
            }
        }
        .navigationTitle("Your Offers")
    }
}
