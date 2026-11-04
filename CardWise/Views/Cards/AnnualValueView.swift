import SwiftUI

struct AnnualValueView: View {
    @EnvironmentObject var cardViewModel: CardViewModel
    @EnvironmentObject var spendingViewModel: SpendingViewModel
    @State private var year = Calendar.current.component(.year, from: Date())

    private var years: [Int] {
        let current = Calendar.current.component(.year, from: Date())
        let spendingYears = spendingViewModel.spendings.map { Calendar.current.component(.year, from: $0.date) }
        let usageYears = cardViewModel.creditUsages.compactMap { Int($0.periodKey.prefix(4)) }
        let feeYears = cardViewModel.userCards.flatMap { ($0.annualFeesPaid ?? [:]).keys.compactMap { Int($0) } }
        let offerYears = cardViewModel.userCards.flatMap { ($0.merchantOffers ?? []).compactMap(\.redeemedAt) }
            .map { Calendar.current.component(.year, from: $0) }
        return Array(Set([current] + spendingYears + usageYears + feeYears + offerYears)).filter { $0 <= current }.sorted(by: >)
    }

    var body: some View {
        List {
            Section {
                Picker("Calendar Year", selection: $year) {
                    ForEach(years, id: \.self) { Text(String($0)).tag($0) }
                }
            } footer: {
                Text("Based on your recorded purchase rewards, credit usage and received offer savings. Missing records are not inferred. Catalog limits are potential value, not savings.")
            }
            if cardViewModel.userCards.isEmpty {
                Text("Add a card to start tracking its annual value.")
            }
            ForEach(cardViewModel.sortedUserCards) { wallet in
                if let card = cardViewModel.getCard(for: wallet) {
                    AnnualCardValueSection(card: card, userCard: wallet, year: year)
                }
            }
        }
        .navigationTitle("Annual Card Value")
    }
}

private struct AnnualCardValueSection: View {
    @EnvironmentObject var cardViewModel: CardViewModel
    @EnvironmentObject var spendingViewModel: SpendingViewModel
    let card: CreditCard
    let userCard: UserCard
    let year: Int
    @State private var feeDraft = ""
    @FocusState private var feeFocused: Bool
    private var current: UserCard { cardViewModel.userCards.first { $0.id == userCard.id } ?? userCard }
    private var value: AnnualCardValue {
        AnnualCardValue.calculate(card: card, userCard: current, year: year,
                                  spendings: spendingViewModel.spendings, usages: cardViewModel.creditUsages)
    }
    private var validFee: Bool { feeDraft.isEmpty || Double(feeDraft).map { $0.isFinite && $0 >= 0 } == true }

    var body: some View {
        Section {
            LabeledContent("Recorded purchase rewards", value: value.purchaseRewards.formatted(.currency(code: "USD")))
            LabeledContent("Credits used", value: value.creditsUsed.formatted(.currency(code: "USD")))
            LabeledContent("Offer savings received", value: value.offerSavings.formatted(.currency(code: "USD")))
            LabeledContent("Recorded value", value: value.recordedValue.formatted(.currency(code: "USD")))
            LabeledContent("Annual Fees Paid ($)") {
                TextField("Not recorded", text: $feeDraft)
                    .keyboardType(.decimalPad).focused($feeFocused)
                    .multilineTextAlignment(.trailing)
                    .accessibilityLabel("Annual fees paid for \(card.name) in \(year)")
            }
            Button(feeDraft.isEmpty ? "Clear fee total" : "Save fee total") { saveFee(); feeFocused = false }.disabled(!validFee)
            if !validFee { Text("Enter a fee total of zero or greater.").font(.caption).foregroundStyle(Theme.danger) }
            if let net = value.netValue {
                LabeledContent("Net recorded value", value: net.formatted(.currency(code: "USD")))
                    .foregroundStyle(net >= 0 ? Theme.success : Theme.danger)
            } else {
                Text("Enter fees paid to calculate net value. Enter 0 for a waived or no-fee year.")
                    .font(.caption).foregroundStyle(Theme.textSecondary)
            }
            LabeledContent("Catalog annual credit limit", value: value.catalogCreditLimit.formatted(.currency(code: "USD")))
                .font(.caption)
        } header: {
            Text(userCard.nickname ?? card.name)
        } footer: {
            Text("Usage is assigned to its credit period. Purchase rewards are saved estimates, not verified redemptions. Do not record the same savings as both an offer and a credit. Archived offers retain their received savings in this history.")
        }
        .onAppear { loadFee() }
        .onChange(of: year) { _, _ in loadFee() }
        .onChange(of: current.annualFeesPaid) { _, _ in if !feeFocused { loadFee() } }
    }

    private func loadFee() { feeDraft = current.annualFeesPaid?[String(year)].map { String($0) } ?? "" }
    private func saveFee() {
        guard validFee else { return }
        cardViewModel.recordAnnualFee(feeDraft.isEmpty ? nil : Double(feeDraft), year: year, for: current)
    }
}
