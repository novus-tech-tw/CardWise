import AppIntents
import Foundation

extension SpendingCategory: AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Spending Category"
    static var caseDisplayRepresentations: [SpendingCategory: DisplayRepresentation] = [
        .dining: "Dining",
        .grocery: "Grocery",
        .gas: "Gas",
        .travel: "Travel",
        .streaming: "Streaming",
        .drugstore: "Drugstore",
        .homeImprovement: "Home Improvement",
        .entertainment: "Entertainment",
        .onlineShopping: "Online Shopping",
        .transit: "Transit",
        .utilities: "Utilities",
        .wholesale: "Wholesale Clubs",
        .paypal: "PayPal",
        .amazon: "Amazon",
        .fitness: "Fitness",
        .phone: "Phone/Internet",
        .internet: "Internet/Cable",
        .shipping: "Shipping",
        .advertising: "Advertising",
        .officeSupplies: "Office Supplies",
        .evCharging: "EV Charging",
        .apple: "Devices & Services",
        .wholeFoods: "Whole Foods",
        .target: "Target",
        .walmart: "Walmart",
        .macys: "Macys",
        .kohls: "Kohls",
        .gap: "Gap",
        .nordstrom: "Nordstrom",
        .electronics: "Electronics",
        .hotels: "Hotels",
        .airlines: "Airlines",
        .disney: "Disney",
        .other: "Other"
    ]
}

/// Both entry points use the same saved spending, caps and valuation policy as the UI.
enum ShortcutRecommendation {
    struct Snapshot {
        var userCards: [UserCard]
        var catalog: [CreditCard]
        var spendings: [Spending]
        var settings: RecommendationSettings
    }

    static func message(category: SpendingCategory, amount: Double, snapshot: Snapshot, now: Date = Date()) -> String {
        guard amount.isFinite, amount > 0 else { return "Enter a purchase amount greater than zero." }
        guard let best = RecommendationEngine.shared.getRecommendations(
            for: category, amount: amount, userCards: snapshot.userCards, allCards: snapshot.catalog,
            spendings: snapshot.spendings, settings: snapshot.settings, asOf: now
        ).first else { return "Add a card to your CardWise wallet first." }
        let name = best.userCard.nickname ?? best.card.name
        return "\(name): estimated \(best.estimatedReward.formatted(.currency(code: "USD"))) " +
            "on \(amount.formatted(.currency(code: "USD"))) for \(category.displayName). \(best.reason). " +
            "\(snapshot.settings.ranking.explanation) Uses your recorded spending; issuer coding and redemption values can differ."
    }

    @MainActor
    static func savedMessage(category: SpendingCategory, amount: Double, merchant: String = "") -> String {
        let store = CloudStore(context: AppContainer.shared.mainContext)
        store.migrateFromKeychainIfNeeded()
        let snapshot = Snapshot(userCards: store.loadUserCards(), catalog: CardCatalog.loadCards(),
                                spendings: store.loadSpendings(), settings: RecommendationSettingsStore.shared.settings)
        if !snapshot.userCards.isEmpty {
            RecentPurchaseStore.shared.save(PurchaseContext(merchant: merchant, category: category, amount: amount))
        }
        return message(category: category, amount: amount, snapshot: snapshot)
    }
}

struct BestCardForMerchantIntent: AppIntent {
    static var title: LocalizedStringResource = "Best Card for a Merchant"
    static var description = IntentDescription("Find a card using your wallet, saved spending and reward preferences.")
    static var openAppWhenRun = true
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Merchant") var merchant: String
    @Parameter(title: "Purchase Amount", default: 100) var amount: Double

    static var parameterSummary: some ParameterSummary { Summary("Find a card for \(\.$merchant) spending \(\.$amount)") }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        guard let category = MerchantPreferencesStore.shared.category(for: merchant) else {
            throw $merchant.needsValueError("Enter a recognized merchant, or use Best Card for a Category.")
        }
        guard amount.isFinite, amount > 0 else { throw $amount.needsValueError("Enter an amount greater than zero.") }
        let message = ShortcutRecommendation.savedMessage(category: category, amount: amount, merchant: merchant)
        return .result(value: message, dialog: IntentDialog(stringLiteral: message))
    }
}

struct BestCardForCategoryIntent: AppIntent {
    static var title: LocalizedStringResource = "Best Card for a Category"
    static var description = IntentDescription("Compare your cards for a category and purchase amount.")
    static var openAppWhenRun = true
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Category") var category: SpendingCategory
    @Parameter(title: "Purchase Amount", default: 100) var amount: Double

    static var parameterSummary: some ParameterSummary { Summary("Find a card for \(\.$category) spending \(\.$amount)") }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        guard amount.isFinite, amount > 0 else { throw $amount.needsValueError("Enter an amount greater than zero.") }
        let message = ShortcutRecommendation.savedMessage(category: category, amount: amount)
        return .result(value: message, dialog: IntentDialog(stringLiteral: message))
    }
}

struct CardWiseShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: BestCardForMerchantIntent(), phrases: ["Find my best card with \(.applicationName)"],
                    shortTitle: "Best Card for Merchant", systemImageName: "creditcard")
        AppShortcut(intent: BestCardForCategoryIntent(), phrases: ["Compare my cards with \(.applicationName)"],
                    shortTitle: "Best Card for Category", systemImageName: "star")
        AppShortcut(intent: StartShoppingModeIntent(), phrases: ["Start shopping mode in \(.applicationName)"],
                    shortTitle: "Start Shopping Mode", systemImageName: "lock.rectangle.on.rectangle")
        AppShortcut(intent: EndShoppingModeIntent(), phrases: ["End shopping mode in \(.applicationName)"],
                    shortTitle: "End Shopping Mode", systemImageName: "xmark.circle")
        AppShortcut(intent: UnusedCreditsIntent(), phrases: ["Show unused credits in \(.applicationName)"],
                    shortTitle: "Unused Credits", systemImageName: "dollarsign.circle")
        AppShortcut(intent: UpcomingActionsIntent(), phrases: ["Show card deadlines in \(.applicationName)"],
                    shortTitle: "Card Deadlines", systemImageName: "calendar.badge.clock")
        AppShortcut(intent: BonusCategoriesIntent(), phrases: ["Show bonus categories in \(.applicationName)"],
                    shortTitle: "Bonus Categories", systemImageName: "arrow.triangle.2.circlepath")
    }
}
