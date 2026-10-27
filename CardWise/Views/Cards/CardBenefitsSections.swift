import SwiftUI

struct CreditUsageEditor: View {
    @EnvironmentObject var cardViewModel: CardViewModel
    let card: CreditCard
    let credit: StatementCredit
    @State private var draft = ""
    @FocusState private var isFocused: Bool

    private var periodKey: String { CreditPeriod.key(for: Date(), cadence: credit.cadence) }
    private var used: Double { cardViewModel.usedAmount(cardID: card.id, creditID: credit.id, periodKey: periodKey) }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(credit.description, systemImage: credit.category?.icon ?? "creditcard")
                Spacer()
                Text(credit.amount.formatted(.currency(code: "USD")))
                    .foregroundStyle(Theme.success)
            }
            HStack {
                Text("Used this \(credit.cadence.displayName)")
                Spacer()
                Text("$")
                TextField("0", text: $draft)
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
                    .accessibilityLabel("Used amount for \(credit.description)")
                    .onChange(of: draft) { _, text in
                        if let value = Double(text), value.isFinite, value >= 0 {
                            cardViewModel.setUsedAmount(min(value, credit.amount), cardID: card.id, creditID: credit.id, periodKey: periodKey)
                        } else if text.isEmpty {
                            cardViewModel.setUsedAmount(0, cardID: card.id, creditID: credit.id, periodKey: periodKey)
                        }
                    }
            }
            .font(.caption)
            ProgressView(value: min(max(used, 0), credit.amount), total: max(credit.amount, 1))
                .tint(Theme.accent)
            Text("\(max(0, credit.amount - used).formatted(.currency(code: "USD"))) left · resets \(CreditPeriod.nextReset(for: Date(), cadence: credit.cadence).formatted(date: .abbreviated, time: .omitted))")
                .font(.caption2)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.vertical, 4)
        .onAppear { draft = used == 0 ? "" : String(used) }
        .onChange(of: isFocused) { _, focused in
            if !focused { draft = used == 0 ? "" : String(used) }
        }
    }
}

struct SignUpBonusSection: View {
    @EnvironmentObject var cardViewModel: CardViewModel
    @EnvironmentObject var spendingViewModel: SpendingViewModel
    let card: CreditCard
    let userCard: UserCard

    private var current: UserCard { cardViewModel.userCards.first { $0.id == userCard.id } ?? userCard }

    var body: some View {
        Section {
            NavigationLink(current.signUpBonus(for: card) == nil ? "Add Your Sign-up Offer" : "Edit Your Sign-up Offer") {
                SignUpOfferEditor(card: card, userCard: current)
            }
            if let bonus = current.signUpBonus(for: card) {
                Text(bonus.description)
                Toggle("Track this sign-up goal", isOn: Binding(
                    get: { current.signUpBonusStartDate != nil },
                    set: { enabled in cardViewModel.updateSignUpBonus(for: current, startDate: enabled ? Date() : nil, achieved: false) }
                ))
                if let start = current.signUpBonusStartDate {
                    DatePicker("Opened / goal start", selection: Binding(
                        get: { start },
                        set: { cardViewModel.updateSignUpBonus(for: current, startDate: $0, achieved: current.signUpBonusAchieved) }
                    ), in: ...Date(), displayedComponents: .date)
                    if let deadline = current.signUpBonusDeadline(for: card) {
                        LabeledContent("Deadline", value: deadline.formatted(date: .abbreviated, time: .omitted))
                    }
                    if let progress = RecommendationEngine.shared.signUpBonusProgress(
                        card: card, userCard: current, spendings: spendingViewModel.spendings
                    ) {
                        ProgressView(value: progress.percentComplete, total: 100)
                        Text("\(progress.formattedProgress) · \(progress.amountRemaining.formatted(.currency(code: "USD"))) to go")
                            .font(.caption)
                        Text(progress.isAchieved ? "Recorded spending goal met; confirm award with issuer." : (progress.daysRemaining > 0 ? "\(progress.daysRemaining) days remaining" : "Deadline passed"))
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    Toggle("Bonus received (confirmed by you)", isOn: Binding(
                        get: { current.signUpBonusAchieved },
                        set: { cardViewModel.updateSignUpBonus(for: current, startDate: start, achieved: $0) }
                    ))
                }
            }
        } header: {
            Text("Sign-up Bonus")
        } footer: {
            Text("Uses your manually recorded eligible purchases within the goal dates. Record posted purchases only. Issuer exclusions and pending transactions are not inferred; confirm the actual offer and deadline with your issuer.")
        }
    }
}
