import SwiftUI

struct RecommendationContextView: View {
    let recommendation: CardRecommendation

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let remaining = recommendation.spendingCapRemaining {
                Text(remaining == 0 ? "Bonus cap exhausted" : "Bonus cap: \(remaining.formatted(.currency(code: "USD"))) left")
                    .font(.caption)
                    .foregroundStyle(recommendation.isNearSpendingCap ? Theme.warning : Theme.textSecondary)
            }
            if let progress = recommendation.signUpBonusProgress {
                HStack {
                    Text("Sign-up goal")
                    Spacer()
                    Text(progress.isAchieved ? "Spending goal met" : (!progress.hasStarted ? "Not started" : (progress.daysRemaining > 0 ? "\(progress.daysRemaining) days left" : "Deadline passed")))
                }
                .font(.caption)
                ProgressView(value: progress.percentComplete, total: 100)
                    .tint(Theme.accent)
                    .accessibilityLabel("Sign-up spending progress")
                Text("\(progress.formattedProgress) · \(progress.amountRemaining.formatted(.currency(code: "USD"))) to go")
                    .font(.caption2)
                    .foregroundStyle(Theme.textSecondary)
            }
            if !recommendation.context.isEmpty {
                DisclosureGroup("Why this estimate?") {
                    ForEach(recommendation.context, id: \.self) { explanation in
                        Text(explanation)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 2)
                    }
                }
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
            }
        }
    }
}

struct PurchaseConditionsToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle("Assume special rate terms apply", isOn: $isOn)
                .font(.subheadline)
            Text("Enable only when the listed booking channel or merchant conditions match this purchase. Review each card's explanation.")
                .font(.caption2)
                .foregroundStyle(Theme.textSecondary)
        }
    }
}
