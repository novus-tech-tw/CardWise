import AppIntents
import Foundation

/// Read-only wallet answers for Siri and Shortcuts. Message builders are pure so they can be
/// unit-tested; the intents only load the saved wallet and format the answer.
enum WalletShortcutMessages {
    static func unusedCredits(_ credits: [CardViewModel.UnusedCredit], limit: Int = 5) -> String {
        guard !credits.isEmpty else { return "No statement credits left to use this period." }
        let total = credits.reduce(0) { $0 + $1.remaining }
        let lines = credits.prefix(limit).map { credit in
            "\(credit.cardName): \(credit.remaining.formatted(.currency(code: "USD"))) \(credit.credit.description), resets " +
                credit.resetDate.formatted(date: .abbreviated, time: .omitted)
        }
        let more = credits.count > limit ? " Plus \(credits.count - limit) more in CardWise." : ""
        return "\(total.formatted(.currency(code: "USD"))) in credits left. " + lines.joined(separator: ". ") + "." + more
    }

    static func upcomingActions(_ actions: [UpcomingAction], limit: Int = 5) -> String {
        guard !actions.isEmpty else { return "Nothing needs attention in the next 30 days." }
        let lines = actions.prefix(limit).map { action in
            "\(action.cardName): \(action.title), \(action.displayDate.formatted(date: .abbreviated, time: .omitted))"
        }
        let more = actions.count > limit ? " Plus \(actions.count - limit) more in CardWise." : ""
        return lines.joined(separator: ". ") + "." + more
    }

    static func bonusCategories(userCards: [UserCard], catalog: [CreditCard], now: Date = Date()) -> String {
        let lines: [String] = userCards.compactMap { wallet in
            guard let card = catalog.first(where: { $0.id == wallet.cardId }),
                  let rotating = card.rotatingCategory(asOf: now) else { return nil }
            let categories = ListFormatter.localizedString(byJoining: rotating.categories.map(\.displayName))
            var line = "\(wallet.nickname ?? card.name): \(rotating.displayMultiplier) on \(categories) in Q\(rotating.quarter)"
            if rotating.activationRequired && !wallet.hasActivatedRotating(quarter: rotating.quarter, year: rotating.year) {
                line += " (activation not confirmed)"
            }
            return line
        }
        guard !lines.isEmpty else { return "None of your cards has a rotating bonus this quarter." }
        return lines.joined(separator: ". ") + "."
    }
}

@MainActor
enum WalletSnapshotLoader {
    static func store() -> CloudStore {
        let store = CloudStore(context: AppContainer.shared.mainContext)
        store.migrateFromKeychainIfNeeded()
        return store
    }
}

struct UnusedCreditsIntent: AppIntent {
    static var title: LocalizedStringResource = "Unused Statement Credits"
    static var description = IntentDescription("List statement credits you have not used this period.")
    static var openAppWhenRun = true
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let message = WalletShortcutMessages.unusedCredits(CardViewModel(store: WalletSnapshotLoader.store()).unusedCreditsThisPeriod)
        return .result(value: message, dialog: IntentDialog(stringLiteral: message))
    }
}

struct UpcomingActionsIntent: AppIntent {
    static var title: LocalizedStringResource = "Upcoming Card Deadlines"
    static var description = IntentDescription("Credits about to reset, activations, sign-up goals and offers expiring in 30 days.")
    static var openAppWhenRun = true
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let store = WalletSnapshotLoader.store()
        let actions = UpcomingActions.items(userCards: store.loadUserCards(), catalog: CardCatalog.loadCards(),
                                            usages: store.loadCreditUsages(), spendings: store.loadSpendings())
        let message = WalletShortcutMessages.upcomingActions(actions)
        return .result(value: message, dialog: IntentDialog(stringLiteral: message))
    }
}

struct BonusCategoriesIntent: AppIntent {
    static var title: LocalizedStringResource = "This Quarter's Bonus Categories"
    static var description = IntentDescription("Rotating bonus categories on your cards and whether you confirmed activation.")
    static var openAppWhenRun = true
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let message = WalletShortcutMessages.bonusCategories(userCards: WalletSnapshotLoader.store().loadUserCards(),
                                                             catalog: CardCatalog.loadCards())
        return .result(value: message, dialog: IntentDialog(stringLiteral: message))
    }
}

struct StartShoppingModeIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Shopping Mode"
    static var description = IntentDescription("Put the best card for a merchant on your Lock Screen and Dynamic Island.")
    static var openAppWhenRun = true
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Merchant") var merchant: String
    @Parameter(title: "Purchase Amount", default: 100) var amount: Double

    static var parameterSummary: some ParameterSummary { Summary("Start shopping mode at \(\.$merchant) for \(\.$amount)") }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        guard let category = MerchantPreferencesStore.shared.category(for: merchant) else {
            throw $merchant.needsValueError("Enter a recognized merchant.")
        }
        guard amount.isFinite, amount > 0 else { throw $amount.needsValueError("Enter an amount greater than zero.") }
        let store = WalletSnapshotLoader.store()
        let purchase = PurchaseContext(merchant: merchant, category: category, amount: amount)
        let recommendations = RecommendationEngine.shared.getRecommendations(
            for: category, amount: amount, userCards: store.loadUserCards(), allCards: CardCatalog.loadCards(),
            spendings: store.loadSpendings(), settings: RecommendationSettingsStore.shared.settings
        )
        let message: String
        do {
            try await ShoppingActivityController.start(purchase: purchase, recommendations: recommendations)
            RecentPurchaseStore.shared.save(purchase)
            let best = recommendations.first.map { $0.userCard.nickname ?? $0.card.name } ?? "Your best card"
            message = "Shopping mode on: use \(best) at \(merchant)."
        } catch {
            message = error.localizedDescription
        }
        return .result(value: message, dialog: IntentDialog(stringLiteral: message))
    }
}
