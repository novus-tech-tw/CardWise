import Foundation

struct WalletOfferMatch: Identifiable {
    let walletID: String
    let cardName: String
    let offer: MerchantOffer
    let estimatedSavings: Double?
    var id: String { "\(walletID)|\(offer.id)" }
}

enum WalletOfferQuery {
    /// Empty merchant returns the current wallet inventory. Savings use the same eligibility
    /// and single-purchase calculation as the purchase comparison screen.
    static func matches(userCards: [UserCard], catalog: [CreditCard], merchant: String = "",
                        amount: Double = 100, now: Date = Date()) -> [WalletOfferMatch] {
        guard amount.isFinite, amount > 0 else { return [] }
        let merchantKey = MerchantOffer.merchantKey(merchant)
        return userCards.flatMap { wallet in
            (wallet.merchantOffers ?? []).compactMap { offer -> WalletOfferMatch? in
                guard offer.isValid, offer.isArchived != true, offer.redeemedAt == nil, offer.expiresAt > now,
                      merchantKey.isEmpty || offer.matches(merchant) else { return nil }
                let name = wallet.nickname ?? catalog.first { $0.id == wallet.cardId }?.name ?? "Saved card"
                return WalletOfferMatch(walletID: wallet.id, cardName: name, offer: offer,
                                        estimatedSavings: offer.estimatedSavings(for: amount, at: now))
            }
        }.sorted {
            if $0.offer.expiresAt != $1.offer.expiresAt { return $0.offer.expiresAt < $1.offer.expiresAt }
            return $0.id < $1.id
        }
    }

    /// Expiry and identity provide a deterministic tie-break without combining offers.
    static func best(in matches: [WalletOfferMatch]) -> WalletOfferMatch? {
        matches.filter { ($0.estimatedSavings ?? 0) > 0 }.sorted {
            if $0.estimatedSavings != $1.estimatedSavings {
                return ($0.estimatedSavings ?? 0) > ($1.estimatedSavings ?? 0)
            }
            if $0.offer.expiresAt != $1.offer.expiresAt { return $0.offer.expiresAt < $1.offer.expiresAt }
            return $0.id < $1.id
        }.first
    }
}
