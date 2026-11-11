import SwiftUI

/// Best card for each place around the user. Location is used once per search, only while
/// this screen is open, and is never saved.
struct NearbyView: View {
    @EnvironmentObject var cardViewModel: CardViewModel
    @EnvironmentObject var spendingViewModel: SpendingViewModel
    @ObservedObject private var preferences = RecommendationSettingsStore.shared
    @StateObject private var searcher = NearbyPlacesSearcher()
    @Environment(\.openURL) private var openURL
    @State private var amount = "50"
    @State private var selected: NearbyPlace?
    @State private var activityMessage: String?

    private var amountValue: Double { Double(amount) ?? 0 }

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Purchase amount")
                    Spacer()
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 120)
                        .accessibilityLabel("Purchase amount in dollars")
                }
            } footer: {
                Text("Places come from Apple Maps within about \(Int(NearbyPlacesSearcher.radius)) m. Categories are a best guess; issuers decide how a purchase codes.")
            }
            content
        }
        .navigationTitle("Nearby")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { searcher.search() } label: { Image(systemName: "location.circle") }
                    .accessibilityLabel("Search nearby again")
            }
        }
        .onAppear { if searcher.state == .idle { searcher.search() } }
        .confirmationDialog(selected?.name ?? "", isPresented: Binding(get: { selected != nil },
                                                                       set: { if !$0 { selected = nil } }),
                            titleVisibility: .visible, presenting: selected) { place in
            Button("Start Shopping Mode") { startActivity(for: place) }
            Button("Compare All Cards") { open(place) }
            Button("Cancel", role: .cancel) {}
        } message: { place in
            Text("Shopping mode keeps the best card for \(place.name) on your Lock Screen for up to 4 hours.")
        }
        .alert("Shopping Mode", isPresented: Binding(get: { activityMessage != nil },
                                                     set: { if !$0 { activityMessage = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(activityMessage ?? "")
        }
    }

    @ViewBuilder private var content: some View {
        switch searcher.state {
        case .idle, .locating, .searching:
            HStack { ProgressView(); Text("Finding places near you…").foregroundStyle(Theme.textSecondary) }
        case .needsPermission:
            permissionRow(message: "CardWise uses your location only while you use this screen to find nearby stores. It is never saved or sent to us.",
                          action: "Allow Location") { searcher.search() }
        case .denied:
            permissionRow(message: "Location access is off. Turn it on in Settings to see the best card for nearby places.",
                          action: "Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
            }
        case .failed(let message):
            permissionRow(message: message, action: "Try Again") { searcher.search() }
        case .loaded(let places) where places.isEmpty:
            Text("No supported places found nearby.").foregroundStyle(Theme.textSecondary)
        case .loaded(let places):
            if cardViewModel.userCards.isEmpty {
                Text("Add cards to your wallet to see recommendations.").foregroundStyle(Theme.textSecondary)
            }
            Section("Around You") {
                ForEach(places) { place in
                    Button { selected = place } label: { row(place) }
                        .buttonStyle(.plain)
                }
            }
        }
    }

    private func permissionRow(message: String, action: String, perform: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(message).font(.callout).foregroundStyle(Theme.textSecondary)
            Button(action, action: perform).buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 4)
    }

    private func recommendations(for place: NearbyPlace) -> [CardRecommendation] {
        RecommendationEngine.shared.getRecommendations(
            for: place.category, amount: amountValue, userCards: cardViewModel.userCards,
            allCards: cardViewModel.allCards, spendings: spendingViewModel.spendings, settings: preferences.settings
        )
    }

    private func row(_ place: NearbyPlace) -> some View {
        let best = recommendations(for: place).first
        return HStack(spacing: 12) {
            Image(systemName: place.category.icon)
                .frame(width: 28)
                .foregroundStyle(Theme.accent)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(place.name).font(.app(.body, weight: .medium)).lineLimit(1)
                Text("\(place.category.displayName)\(place.isSavedCategory ? " (saved)" : "") · \(place.formattedDistance)")
                    .font(.app(.caption)).foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            if let best {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(best.displayReward).font(.app(.body, weight: .semibold))
                    Text(best.userCard.nickname ?? best.card.name).font(.app(.caption))
                        .foregroundStyle(Theme.textSecondary).lineLimit(1)
                }
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Shows shopping mode and comparison options")
    }

    private func purchase(for place: NearbyPlace) -> PurchaseContext {
        PurchaseContext(merchant: place.name, category: place.category, amount: amountValue)
    }

    private func open(_ place: NearbyPlace) {
        let purchase = purchase(for: place)
        var components = URLComponents()
        components.scheme = "cardwise"
        components.host = "recommend"
        components.queryItems = [URLQueryItem(name: "merchant", value: purchase.merchant),
                                 URLQueryItem(name: "category", value: purchase.category.rawValue),
                                 URLQueryItem(name: "amount", value: String(purchase.amount))]
        if let url = components.url { openURL(url) }
    }

    private func startActivity(for place: NearbyPlace) {
        let purchase = purchase(for: place)
        let recs = recommendations(for: place)
        Task {
            do {
                try await ShoppingActivityController.start(purchase: purchase, recommendations: recs)
                RecentPurchaseStore.shared.save(purchase)
                activityMessage = "\(recs.first.map { $0.userCard.nickname ?? $0.card.name } ?? "Your best card") is now on your Lock Screen."
            } catch {
                activityMessage = error.localizedDescription
            }
        }
    }
}
