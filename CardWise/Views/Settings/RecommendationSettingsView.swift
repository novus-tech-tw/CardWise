import SwiftUI

struct RecommendationSettingsView: View {
    @EnvironmentObject var cardViewModel: CardViewModel
    @ObservedObject private var preferences = RecommendationSettingsStore.shared

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
                Picker("Category", selection: $preferences.settings.widgetCategory) {
                    ForEach(SpendingCategory.allCases, id: \.self) { category in
                        Text(category.displayName).tag(category)
                    }
                }
                TextField("Merchant (optional)", text: $preferences.settings.widgetMerchant)
                    .autocorrectionDisabled()
                LabeledContent("Detected category", value: preferences.settings.effectiveWidgetCategory.displayName)
                WidgetAmountField()
                PurchaseConditionsToggle(isOn: $preferences.settings.widgetConditionalRewards)
            } header: {
                Text("Home and Lock Screen widgets")
            } footer: {
                Text("A recognized merchant overrides the category. Widgets use this purchase amount, recorded spending, and your ranking settings. Open CardWise to refresh after a day or a period reset. Merchant categories are estimates; issuer coding can differ.")
            }
            Section {
                Button("Reset Recommendation Settings", role: .destructive) { preferences.reset() }
            }
        }
        .navigationTitle("Recommendations")
        .navigationBarTitleDisplayMode(.inline)
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
