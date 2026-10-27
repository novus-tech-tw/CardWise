import SwiftUI

struct SignUpOfferEditor: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var cardViewModel: CardViewModel
    let card: CreditCard
    let userCard: UserCard
    @State private var rewardAmount = ""
    @State private var spendRequirement = ""
    @State private var timeframe = "90"
    @State private var rewardType: RewardType = .points

    private var offer: SignUpBonus? {
        guard let amount = Double(rewardAmount), amount.isFinite, amount > 0, amount <= 1_000_000_000,
              let spend = Double(spendRequirement), spend.isFinite, spend > 0, spend <= 1_000_000_000,
              let days = Int(timeframe), (1...730).contains(days) else { return nil }
        return SignUpBonus(bonusAmount: amount, bonusType: rewardType, spendRequirement: spend, timeframeDays: days,
                           description: "Your offer: \(amount.formatted()) \(rewardType == .cashback ? "dollars" : rewardType.rawValue) after \(spend.formatted(.currency(code: "USD"))) in \(days) days")
    }

    var body: some View {
        Form {
            Section {
                Picker("Reward type", selection: $rewardType) {
                    ForEach(RewardType.allCases, id: \.self) { Text($0.displayName).tag($0) }
                }
                LabeledContent("Bonus amount") {
                    TextField("Amount", text: $rewardAmount)
                        .keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                        .accessibilityLabel("Bonus amount")
                }
                LabeledContent("Required spending ($)") {
                    TextField("Amount", text: $spendRequirement)
                        .keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                        .accessibilityLabel("Required spending")
                }
                LabeledContent("Time limit (1–730 days)") {
                    TextField("90", text: $timeframe)
                        .keyboardType(.numberPad).multilineTextAlignment(.trailing)
                        .accessibilityLabel("Time limit in days")
                }
            } footer: {
                Text("Copy the exact offer from your issuer. CardWise tracks your entries and does not verify eligibility or award payment. Set the opening date on the card details screen after saving.")
            }
            if userCard.customSignUpBonus != nil {
                Section {
                    Button("Remove Custom Offer", role: .destructive) {
                        cardViewModel.updateSignUpOffer(for: userCard, bonus: nil)
                        dismiss()
                    }
                }
            }
        }
        .navigationTitle("Sign-up Offer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    guard let offer else { return }
                    cardViewModel.updateSignUpOffer(for: userCard, bonus: offer)
                    dismiss()
                }
                .disabled(offer == nil)
            }
        }
        .onAppear {
            rewardType = card.rewardType
            if let bonus = userCard.signUpBonus(for: card) {
                rewardAmount = String(bonus.bonusAmount)
                spendRequirement = String(bonus.spendRequirement)
                timeframe = String(bonus.timeframeDays)
                rewardType = bonus.bonusType
            }
        }
    }
}
