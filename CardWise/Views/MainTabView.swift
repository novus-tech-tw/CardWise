import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var cardViewModel: CardViewModel
    @State private var selectedTab = 0
    @State private var widgetPurchase: PurchaseContext?
    @State private var purchaseRouteID = UUID()
    @State private var walletDestination: WalletDestination?
    @State private var offerDestination: WalletOfferDestination?
    @State private var walletRouteID = UUID()

    private enum WalletDestination: String, Identifiable {
        case offers, deadlines, credits
        var id: String { rawValue }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            CardListView()
                .tabItem {
                    Label("My Cards", systemImage: "creditcard.fill")
                }
                .tag(1)

            RecommendView(initialPurchase: widgetPurchase)
                .id(purchaseRouteID)
                .tabItem {
                    Label("Recommend", systemImage: "star.fill")
                }
                .tag(2)

            SpendingListView()
                .tabItem {
                    Label("Spending", systemImage: "chart.bar.fill")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .tint(Theme.accent)
        .onOpenURL { url in
            if url.scheme == "cardwise" {
                if url.host == "cards" {
                    walletDestination = nil
                    selectedTab = 1
                    return
                }
                if let destination = url.host.flatMap(WalletDestination.init(rawValue:)) {
                    offerDestination = WalletOfferDestination(url: url)
                    walletRouteID = UUID()
                    selectedTab = 0
                    walletDestination = destination
                    return
                }
            }
            guard let purchase = PurchaseContext(url: url) else { return }
            walletDestination = nil
            widgetPurchase = purchase
            purchaseRouteID = UUID()
            selectedTab = 2
        }
        .sheet(item: $walletDestination) { destination in
            NavigationStack {
                Group {
                    switch destination {
                    case .offers: WalletOffersView(initialDestination: offerDestination)
                    case .deadlines:
                        ScrollView {
                            if cardViewModel.userCards.isEmpty { Text("Add a card to see upcoming actions.").padding() }
                            UpcomingActionsCard().padding()
                        }.navigationTitle("Coming Up")
                    case .credits: UnusedCreditsWidgetDestination()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) { Button("Done") { walletDestination = nil } }
                }
            }
            .id(walletRouteID)
        }
    }
}

private struct UnusedCreditsWidgetDestination: View {
    @EnvironmentObject var cardViewModel: CardViewModel

    var body: some View {
        List {
            if cardViewModel.unusedCreditsThisPeriod.isEmpty { Text("No unused statement credits this period.") }
            ForEach(cardViewModel.unusedCreditsThisPeriod) { item in
                if let card = cardViewModel.getCard(byId: item.cardID) {
                    Section(item.cardName) { CreditUsageEditor(card: card, credit: item.credit) }
                }
            }
        }.navigationTitle("Unused Credits")
    }
}

#Preview {
    let store = CloudStore.preview()
    return MainTabView()
        .environmentObject(CardViewModel(store: store))
        .environmentObject(SpendingViewModel(store: store))
}
