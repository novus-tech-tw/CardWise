import SwiftUI
import os

struct MainTabView: View {
    private static let logger = Logger(subsystem: "studio.tmj.cardwise", category: "Navigation")
    @EnvironmentObject var cardViewModel: CardViewModel
    @State private var selectedTab = 0
    @State private var widgetPurchase: PurchaseContext?
    @State private var purchaseRouteID = UUID()
    @State private var walletRoute: WalletRoute?

    private enum WalletDestination: String {
        case offers, deadlines, credits
    }

    private struct WalletRoute: Identifiable {
        let id = UUID()
        let destination: WalletDestination
        let offer: WalletOfferDestination?
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
                    walletRoute = nil
                    selectedTab = 1
                    return
                }
                if let destination = url.host.flatMap(WalletDestination.init(rawValue:)) {
                    Self.logger.notice("Wallet link received for \(destination.rawValue, privacy: .public)")
                    selectedTab = 0
                    walletRoute = WalletRoute(destination: destination, offer: WalletOfferDestination(url: url))
                    return
                }
            }
            guard let purchase = PurchaseContext(url: url) else { return }
            walletRoute = nil
            widgetPurchase = purchase
            purchaseRouteID = UUID()
            selectedTab = 2
        }
        .sheet(item: $walletRoute) { route in
            NavigationStack {
                Group {
                    switch route.destination {
                    case .offers: WalletOffersView(initialDestination: route.offer)
                    case .deadlines:
                        ScrollView {
                            if cardViewModel.userCards.isEmpty { Text("Add a card to see upcoming actions.").padding() }
                            UpcomingActionsCard().padding()
                        }.navigationTitle("Coming Up")
                    case .credits: UnusedCreditsWidgetDestination()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) { Button("Done") { walletRoute = nil } }
                }
            }
            .id(route.id)
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
