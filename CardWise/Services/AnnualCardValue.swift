import Foundation

struct AnnualCardValue {
    let purchaseRewards: Double
    let creditsUsed: Double
    let offerSavings: Double
    let feePaid: Double?
    let catalogCreditLimit: Double
    var recordedValue: Double { purchaseRewards + creditsUsed + offerSavings }
    var netValue: Double? { feePaid.map { recordedValue - $0 } }

    static func calculate(card: CreditCard, userCard: UserCard, year: Int,
                          spendings: [Spending], usages: [CreditUsage], now: Date = Date(),
                          calendar: Calendar = Calendar(identifier: .gregorian)) -> AnnualCardValue {
        let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) ?? now
        let end = calendar.date(byAdding: .year, value: 1, to: start) ?? now
        let rewards = spendings.filter {
            $0.cardUsed == card.id && $0.date >= start && $0.date < end && $0.date <= now && $0.rewardEarned.isFinite
        }.reduce(0) { $0 + max(0, $1.rewardEarned) }
        // Resolve exact period keys rather than matching arbitrary prefixes. Historical
        // credit rows absent from today's catalog retain their recorded values.
        let validKeys = Set((0..<12).compactMap { calendar.date(byAdding: .month, value: $0, to: start) }
            .filter { $0 <= now }.flatMap { date in
                CreditCadence.allCases.map { CreditPeriod.key(for: date, cadence: $0, calendar: calendar) }
            })
        let credits = usages.filter { $0.cardID == card.id && validKeys.contains($0.periodKey) && $0.amountUsed.isFinite }
            .reduce(0) { $0 + max(0, $1.amountUsed) }
        let offers = (userCard.merchantOffers ?? []).filter {
            guard let date = $0.redeemedAt else { return false }
            return date >= start && date < end && date <= now
        }.reduce(0.0) { total, offer in
            let amount = offer.savingsReceived ?? 0
            return total + (amount.isFinite ? max(0, amount) : 0)
        }
        let fee = userCard.annualFeesPaid?[String(year)].flatMap { $0.isFinite && $0 >= 0 ? $0 : nil }
        return AnnualCardValue(purchaseRewards: rewards, creditsUsed: credits, offerSavings: offers,
                               feePaid: fee, catalogCreditLimit: card.annualizedCreditTotal)
    }
}
