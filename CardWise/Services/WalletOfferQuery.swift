import Foundation

struct WalletOfferMatch: Identifiable {
    let walletID: String
    let cardName: String
    let offer: MerchantOffer
    let estimatedSavings: Double?
    var id: String { "\(walletID)|\(offer.id)" }
    var destination: WalletOfferDestination { WalletOfferDestination(walletID: walletID, offerID: offer.id) }
}

struct WalletOfferDestination: Hashable {
    let walletID: String
    let offerID: String

    var url: URL? {
        var components = URLComponents()
        components.scheme = "cardwise"
        components.host = "offers"
        components.queryItems = [URLQueryItem(name: "wallet", value: walletID), URLQueryItem(name: "offer", value: offerID)]
        return components.url
    }

    init(walletID: String, offerID: String) {
        self.walletID = walletID
        self.offerID = offerID
    }

    init?(url: URL) {
        guard url.scheme == "cardwise", url.host == "offers",
              let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else { return nil }
        let wallets = items.filter { $0.name == "wallet" }
        let offers = items.filter { $0.name == "offer" }
        guard wallets.count == 1, offers.count == 1,
              let wallet = wallets.first?.value, !wallet.isEmpty, wallet.count <= 500,
              let offer = offers.first?.value, !offer.isEmpty, offer.count <= 500 else { return nil }
        self.init(walletID: wallet, offerID: offer)
    }
}

enum WalletOfferScope: String, CaseIterable, Identifiable {
    case current = "Current", used = "Used", expired = "Expired", archived = "Archived"
    var id: String { rawValue }

    func includes(_ offer: MerchantOffer, at now: Date) -> Bool {
        guard offer.isValid else { return false }
        if self == .archived { return offer.isArchived == true }
        guard offer.isArchived != true else { return false }
        switch self {
        case .current: return offer.redeemedAt == nil && offer.expiresAt > now
        case .used: return offer.redeemedAt != nil
        case .expired: return offer.redeemedAt == nil && offer.expiresAt <= now
        case .archived: return false
        }
    }
}

enum WalletOfferQuery {
    static func inventory(userCards: [UserCard], catalog: [CreditCard], scope: WalletOfferScope = .current,
                          walletID: String? = nil, now: Date = Date()) -> [WalletOfferMatch] {
        userCards.filter { walletID == nil || $0.id == walletID }.flatMap { wallet in
            (wallet.merchantOffers ?? []).compactMap { offer -> WalletOfferMatch? in
                guard scope.includes(offer, at: now) else { return nil }
                let name = wallet.nickname ?? catalog.first { $0.id == wallet.cardId }?.name ?? "Saved card"
                return WalletOfferMatch(walletID: wallet.id, cardName: name, offer: offer, estimatedSavings: nil)
            }
        }.sorted {
            if $0.offer.expiresAt != $1.offer.expiresAt { return $0.offer.expiresAt < $1.offer.expiresAt }
            return $0.id < $1.id
        }
    }

    /// Empty merchant returns the current wallet inventory. Savings use the same eligibility
    /// and single-purchase calculation as the purchase comparison screen.
    static func matches(userCards: [UserCard], catalog: [CreditCard], merchant: String = "",
                        amount: Double = 100, walletID: String? = nil, now: Date = Date()) -> [WalletOfferMatch] {
        guard amount.isFinite, amount > 0 else { return [] }
        let merchantKey = MerchantOffer.merchantKey(merchant)
        return inventory(userCards: userCards, catalog: catalog, walletID: walletID, now: now).compactMap { match in
            guard merchantKey.isEmpty || match.offer.matches(merchant) else { return nil }
            return WalletOfferMatch(walletID: match.walletID, cardName: match.cardName, offer: match.offer,
                                    estimatedSavings: match.offer.estimatedSavings(for: amount, at: now))
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
