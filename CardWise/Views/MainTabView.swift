import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var widgetPurchase: PurchaseContext?
    @State private var purchaseRouteID = UUID()

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
            guard let purchase = PurchaseContext(url: url) else { return }
            widgetPurchase = purchase
            purchaseRouteID = UUID()
            selectedTab = 2
        }
    }
}

#Preview {
    let store = CloudStore.preview()
    return MainTabView()
        .environmentObject(CardViewModel(store: store))
        .environmentObject(SpendingViewModel(store: store))
}
