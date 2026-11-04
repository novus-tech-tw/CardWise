import SwiftUI

struct RecommendationSettingsView: View {
    @EnvironmentObject var cardViewModel: CardViewModel
    @ObservedObject private var preferences = RecommendationSettingsStore.shared
    @ObservedObject private var quickAccess = QuickAccessStore.shared
    @ObservedObject private var recent = RecentPurchaseStore.shared
    @ObservedObject private var merchantPreferences = MerchantPreferencesStore.shared

    var body: some View {
        Form {
            Section {
                Picker("Rank cards by", selection: $preferences.settings.ranking) {
                    ForEach(RecommendationRanking.allCases) { policy in
                        Text(policy.title).tag(policy)
                    }
                }
                .pickerStyle(.inline)
            } footer: {
                Text(preferences.settings.ranking.explanation)
            }
            Section {
                if !cardViewModel.userCards.contains(where: { cardViewModel.getCard(for: $0)?.rewardType != .cashback }) {
                    Text("Add a points or miles card to set its value.").foregroundStyle(.secondary)
                }
                ForEach(cardViewModel.userCards) { userCard in
                    if let card = cardViewModel.getCard(for: userCard), card.rewardType != .cashback {
                        PointValueRow(card: card, name: userCard.nickname ?? card.name)
                    }
                }
            } header: {
                Text("Point and mile values")
            } footer: {
                Text("Enter your estimated cents per point for each card. The default is 1¢. These assumptions affect recommendations and new spending records; saved rewards stay unchanged. Cash back percentages are unchanged. Settings are saved on this device.")
            }
            Section {
                Picker("Show", selection: Binding(
                    get: { preferences.settings.widgetSource ?? .configured },
                    set: { preferences.settings.widgetSource = $0 }
                )) {
                    ForEach(WidgetContextSource.allCases) { source in Text(source.title).tag(source) }
                }
                if preferences.settings.widgetSource == .recent {
                    if let purchase = recent.purchase {
                        Text("\(purchase.merchant.isEmpty ? purchase.category.displayName : purchase.merchant) · \(purchase.amount.formatted(.currency(code: "USD")))")
                        Button("Forget last checked purchase", role: .destructive) { recent.reset() }
                    } else {
                        Text("Check a purchase on Recommend first. Until then, widgets use your custom purchase below.")
                    }
                }
                if preferences.settings.widgetSource == .favorite {
                    Picker("Favorite", selection: Binding(
                        get: { quickAccess.favorites.contains(where: { $0.id == preferences.settings.widgetFavoriteID }) ? (preferences.settings.widgetFavoriteID ?? "") : "" },
                        set: { preferences.settings.widgetFavoriteID = $0 }
                    )) {
                        Text("Choose a favorite").tag("")
                        ForEach(quickAccess.favorites) { favorite in Text(favorite.title).tag(favorite.id) }
                    }
                    if !quickAccess.favorites.contains(where: { $0.id == preferences.settings.widgetFavoriteID }) {
                        Text("Save or choose a favorite. Widgets use your custom purchase until one is available.").font(.caption)
                    }
                }
                if preferences.settings.widgetSource != .recent || recent.purchase == nil {
                    if preferences.settings.widgetSource != .favorite || !quickAccess.favorites.contains(where: { $0.id == preferences.settings.widgetFavoriteID }) {
                        Picker("Category", selection: $preferences.settings.widgetCategory) {
                            ForEach(SpendingCategory.allCases, id: \.self) { category in Text(category.displayName).tag(category) }
                        }
                        TextField("Merchant (optional)", text: $preferences.settings.widgetMerchant).autocorrectionDisabled()
                    }
                    WidgetAmountField()
                    PurchaseConditionsView(category: widgetPurchase.category, conditions: Binding(
                        get: { PurchaseConditions(confirmedRewardIDs: preferences.settings.widgetConfirmedRewardIDs ?? []) },
                        set: {
                            preferences.settings.widgetConfirmedRewardIDs = $0.confirmedRewardIDs
                            preferences.settings.widgetConditionalRewards = false
                        }
                    ))
                }
                LabeledContent("Category used", value: widgetPurchase.category.displayName)
                Text("\(widgetPurchase.merchant.isEmpty ? widgetPurchase.category.displayName : widgetPurchase.merchant) · \(widgetPurchase.amount.formatted(.currency(code: "USD")))")
                    .font(.caption).foregroundStyle(.secondary)
            } header: {
                Text("Home and Lock Screen widgets")
            } footer: {
                Text("Choose a custom purchase, your last checked purchase, or a favorite. Saved merchant categories apply. " +
                     "Widgets use current recorded spending and ranking settings. Tap a widget to check the purchase again; " +
                     "confirm special rate terms in the app. Saved estimates expire and need CardWise to refresh.")
            }
            Section {
                Button("Reset Recommendation Settings", role: .destructive) { preferences.reset() }
            }
        }
        .onChange(of: preferences.settings.widgetMerchant) { _, _ in clearWidgetConditions() }
        .onChange(of: preferences.settings.widgetCategory) { _, _ in clearWidgetConditions() }
        .onChange(of: preferences.settings.widgetFavoriteID) { _, _ in clearWidgetConditions() }
        .navigationTitle("Recommendations")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func clearWidgetConditions() {
        preferences.settings.widgetConfirmedRewardIDs = []
        preferences.settings.widgetConditionalRewards = false
    }

    private var widgetPurchase: PurchaseContext {
        WidgetDataManager.resolvedPurchase(settings: preferences.settings, recentPurchase: recent.purchase,
                                            favorites: quickAccess.favorites, merchantCategories: merchantPreferences.categories)
    }
}

private struct PointValueRow: View {
    let card: CreditCard
    let name: String
    @ObservedObject private var preferences = RecommendationSettingsStore.shared
    @State private var text = ""
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
            HStack {
                TextField("1", text: $text)
                    .keyboardType(.decimalPad)
                    .focused($focused)
                    .onChange(of: focused) { _, isFocused in
                        if !isFocused { commit() }
                    }
                    .onSubmit { commit() }
                    .accessibilityLabel("Cents per point for \(name)")
                Text("¢ per point")
                    .foregroundStyle(.secondary)
                Button("Default") {
                    preferences.settings.pointValues.removeValue(forKey: card.id)
                    text = "1"
                }
                .buttonStyle(.borderless)
            }
            if !text.isEmpty && !isValid {
                Text("Enter a value greater than 0 and no more than 100¢.")
                    .font(.caption)
                    .foregroundStyle(Theme.warning)
            }
        }
        .onAppear { text = (preferences.settings.dollarsPerPoint(for: card.id) * 100).formatted(.number.grouping(.never)) }
        .onChange(of: text) { _, _ in if isValid { commit() } }
        .onChange(of: preferences.settings.pointValues[card.id]) { _, _ in
            if !focused { text = String(preferences.settings.dollarsPerPoint(for: card.id) * 100) }
        }
    }

    private var isValid: Bool {
        guard let value = Double(text) else { return false }
        return value.isFinite && value > 0 && value <= 100
    }

    private func commit() {
        if isValid, let value = Double(text) { preferences.settings.pointValues[card.id] = value }
    }
}

private struct WidgetAmountField: View {
    @ObservedObject private var preferences = RecommendationSettingsStore.shared
    @State private var text = ""
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Purchase amount ($)")
                Spacer()
                TextField("100", text: $text)
                    .focused($focused)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
                    .onChange(of: text) { _, value in
                        if let amount = Double(value), amount.isFinite, amount > 0 { preferences.settings.widgetAmount = amount }
                    }
            }
            if Double(text).map({ $0.isFinite && $0 > 0 }) != true {
                Text("Enter a positive purchase amount. The last valid amount is used until you do.")
                    .font(.caption).foregroundStyle(Theme.warning)
            }
        }
        .onAppear { text = String(preferences.settings.validWidgetAmount) }
        .onChange(of: preferences.settings.widgetAmount) { _, amount in
            if !focused { text = String(amount) }
        }
    }
}
