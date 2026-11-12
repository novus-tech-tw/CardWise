import Foundation

struct UpcomingAction: Identifiable, Equatable {
    enum Kind: Equatable { case credit(String), activation, signup, offer(String) }
    let id: String
    let walletID: String
    let cardName: String
    let title: String
    let detail: String
    let deadline: Date
    let kind: Kind

    var displayDate: Date {
        if case .offer = kind { return deadline.addingTimeInterval(-1) }
        return deadline
    }
}

enum UpcomingActions {
    static func items(userCards: [UserCard], catalog: [CreditCard], usages: [CreditUsage], spendings: [Spending],
                      now: Date = Date(), calendar: Calendar = .current) -> [UpcomingAction] {
        guard let horizon = calendar.date(byAdding: .day, value: 30, to: now) else { return [] }
        var result: [UpcomingAction] = []
        for wallet in userCards {
            guard let card = catalog.first(where: { $0.id == wallet.cardId }) else { continue }
            let name = wallet.nickname ?? card.name
            for credit in card.credits ?? [] where credit.amount.isFinite && credit.amount > 0 {
                let key = CreditPeriod.key(for: now, cadence: credit.cadence, calendar: calendar)
                let used = usages.first { $0.cardID == card.id && $0.creditID == credit.id && $0.periodKey == key }?.amountUsed ?? 0
                let remaining = max(0, credit.amount - (used.isFinite ? max(0, used) : 0))
                let reset = CreditPeriod.nextReset(for: now, cadence: credit.cadence, calendar: calendar)
                if remaining > 0, reset <= horizon {
                    result.append(UpcomingAction(id: "credit|\(wallet.id)|\(credit.id)", walletID: wallet.id, cardName: name,
                                                 title: "Use \(credit.description)", detail: "\(remaining.formatted(.currency(code: "USD"))) remaining · resets",
                                                 deadline: reset, kind: .credit(credit.id)))
                }
            }
            if let rotating = card.rotatingCategory(asOf: now), rotating.activationRequired,
               !wallet.hasActivatedRotating(quarter: rotating.quarter, year: rotating.year),
               let end = calendar.dateInterval(of: .quarter, for: now)?.end {
                result.append(UpcomingAction(id: "activation|\(wallet.id)", walletID: wallet.id, cardName: name,
                                             title: "Confirm quarterly activation", detail: "Q\(rotating.quarter) bonus · quarter ends",
                                             deadline: end, kind: .activation))
            }
            if let progress = RecommendationEngine.shared.signUpBonusProgress(card: card, userCard: wallet, spendings: spendings, asOf: now),
               progress.isInProgress, let deadline = progress.deadline, deadline <= horizon {
                result.append(UpcomingAction(id: "signup|\(wallet.id)", walletID: wallet.id, cardName: name,
                                             title: "Finish your sign-up spending goal", detail: "\(progress.amountRemaining.formatted(.currency(code: "USD"))) to go · due",
                                             deadline: deadline, kind: .signup))
            }
            for offer in wallet.merchantOffers ?? [] where offer.isValid && offer.isArchived != true && offer.redeemedAt == nil && offer.expiresAt > now && offer.expiresAt <= horizon {
                result.append(UpcomingAction(id: "offer|\(wallet.id)|\(offer.id)", walletID: wallet.id, cardName: name,
                                             title: offer.merchant, detail: "\(offer.isActivated ? "Activation confirmed by you" : "Check issuer activation") · expires",
                                             deadline: offer.expiresAt, kind: .offer(offer.id)))
            }
        }
        return result.sorted { $0.deadline == $1.deadline ? $0.id < $1.id : $0.deadline < $1.deadline }
    }
}
