import AppIntents
import Foundation

struct SavedWalletCardEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Saved Card"
    static var defaultQuery = SavedWalletCardEntityQuery()

    var id: String
    @Property(title: "Card") var name: String

    var displayRepresentation: DisplayRepresentation { DisplayRepresentation(title: "\(name)") }

    init(wallet: UserCard, catalog: [CreditCard]) {
        id = wallet.id
        name = wallet.nickname ?? catalog.first { $0.id == wallet.cardId }?.name ?? "Saved card"
    }
}

struct SavedWalletCardEntityQuery: EntityQuery {
    @MainActor
    func entities(for identifiers: [String]) async throws -> [SavedWalletCardEntity] {
        let cards = Self.savedCards()
        return identifiers.compactMap { id in cards.first { $0.id == id } }
    }

    @MainActor
    func suggestedEntities() async throws -> [SavedWalletCardEntity] { Self.savedCards() }

    @MainActor
    private static func savedCards() -> [SavedWalletCardEntity] {
        let catalog = CardCatalog.loadCards()
        return WalletSnapshotLoader.store().loadUserCards().map { SavedWalletCardEntity(wallet: $0, catalog: catalog) }
    }
}

struct MerchantOfferEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Saved Merchant Offer"
    static var defaultQuery = MerchantOfferEntityQuery()

    var id: String
    @Property(title: "Merchant") var merchant: String
    @Property(title: "Offer") var title: String
    @Property(title: "Card") var cardName: String
    @Property(title: "Expiration Boundary") var expiresAt: Date
    @Property(title: "Activation Confirmed") var isActivated: Bool
    @Property(title: "Reward") var reward: Double
    @Property(title: "Reward Type") var rewardType: String
    @Property(title: "Minimum Spend (USD)") var minimumSpend: Double
    @Property(title: "Maximum Reward (USD)") var maximumReward: Double?

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)", subtitle: "\(cardName) · \(merchant)")
    }

    init(match: WalletOfferMatch) {
        id = match.id
        merchant = match.offer.merchant
        title = match.offer.title
        cardName = match.cardName
        expiresAt = match.offer.expiresAt
        isActivated = match.offer.isActivated
        reward = match.offer.reward
        rewardType = match.offer.rewardKind.title
        minimumSpend = match.offer.minimumSpend
        maximumReward = match.offer.maximumReward
    }
}

struct MerchantOfferEntityQuery: EntityQuery {
    @MainActor
    func entities(for identifiers: [String]) async throws -> [MerchantOfferEntity] {
        let matches = Self.savedMatches()
        return identifiers.compactMap { id in matches.first { $0.id == id }.map(MerchantOfferEntity.init) }
    }

    @MainActor
    func suggestedEntities() async throws -> [MerchantOfferEntity] {
        Self.savedMatches().map(MerchantOfferEntity.init)
    }

    @MainActor
    static func savedMatches(merchant: String = "", amount: Double = 100, walletID: String? = nil) -> [WalletOfferMatch] {
        WalletOfferQuery.matches(userCards: WalletSnapshotLoader.store().loadUserCards(), catalog: CardCatalog.loadCards(),
                                 merchant: merchant, amount: amount, walletID: walletID)
    }
}

struct SavedMerchantOffersIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Saved Merchant Offers"
    static var description = IntentDescription("Return current manually saved offers and their terms. Leave Merchant empty to list all.")
    static var openAppWhenRun = true
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Merchant", default: "") var merchant: String
    @Parameter(title: "Card") var card: SavedWalletCardEntity?

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<[MerchantOfferEntity]> & ProvidesDialog {
        let matches = MerchantOfferEntityQuery.savedMatches(merchant: merchant, walletID: card?.id)
        let message = "\(matches.count) current saved offers. Eligibility and savings use your records and issuer terms."
        return .result(value: matches.map(MerchantOfferEntity.init), dialog: IntentDialog(stringLiteral: message))
    }
}

struct BestSavedMerchantOfferIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Best Saved Merchant Offer"
    static var description = IntentDescription("Find the largest eligible savings for one purchase among your manually saved merchant offers.")
    static var openAppWhenRun = true
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Merchant") var merchant: String
    @Parameter(title: "Purchase Amount", default: 100) var amount: Double
    @Parameter(title: "Card") var card: SavedWalletCardEntity?

    enum OfferError: LocalizedError {
        case noEligibleOffer
        var errorDescription: String? { "No eligible saved offer for this purchase. Check the merchant, minimum spend, expiry and activation confirmation in CardWise." }
    }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<MerchantOfferEntity> & ProvidesDialog {
        guard !MerchantOffer.merchantKey(merchant).isEmpty else { throw $merchant.needsValueError("Enter a merchant.") }
        guard amount.isFinite, amount > 0 else { throw $amount.needsValueError("Enter an amount greater than zero.") }
        guard let best = WalletOfferQuery.best(in: MerchantOfferEntityQuery.savedMatches(merchant: merchant, amount: amount, walletID: card?.id)) else {
            throw OfferError.noEligibleOffer
        }
        let value = MerchantOfferEntity(match: best)
        let savings = (best.estimatedSavings ?? 0).formatted(.currency(code: "USD"))
        let message = "\(value.title) on \(value.cardName): \(savings) estimated offer savings. Confirm issuer eligibility."
        return .result(value: value, dialog: IntentDialog(stringLiteral: message))
    }
}
