import Foundation
import SwiftUI
import os

@MainActor
class CardViewModel: ObservableObject {
    private static let logger = Logger(subsystem: "com.cardwise.app", category: "CardViewModel")
    @Published var allCards: [CreditCard] = []
    @Published var userCards: [UserCard] = []
    @Published var creditUsages: [CreditUsage] = []
    @Published var isLoading = false

    private let store: CloudStore

    init(store: CloudStore) {
        self.store = store
        userCards = store.loadUserCards()
        creditUsages = store.loadCreditUsages()
        allCards = CardCatalog.loadCards()
    }

    var sortedUserCards: [UserCard] {
        userCards.enumerated().sorted {
            if ($0.element.isPinned == true) != ($1.element.isPinned == true) { return $0.element.isPinned == true }
            return $0.offset < $1.offset
        }.map { $0.element }
    }

    func togglePin(for userCard: UserCard) {
        guard let index = userCards.firstIndex(where: { $0.id == userCard.id }) else { return }
        userCards[index].isPinned = !(userCards[index].isPinned ?? false)
        saveUserCards()
    }

    func saveOffer(_ offer: MerchantOffer, for userCard: UserCard) {
        guard offer.isValid, let index = userCards.firstIndex(where: { $0.id == userCard.id }) else { return }
        var offers = userCards[index].merchantOffers ?? []
        if let offerIndex = offers.firstIndex(where: { $0.id == offer.id }) { offers[offerIndex] = offer } else { offers.append(offer) }
        userCards[index].merchantOffers = offers
        saveUserCards()
    }

    func setOfferArchived(_ archived: Bool, offer: MerchantOffer, for userCard: UserCard) {
        guard let index = userCards.firstIndex(where: { $0.id == userCard.id }),
              let offerIndex = userCards[index].merchantOffers?.firstIndex(where: { $0.id == offer.id }) else { return }
        userCards[index].merchantOffers?[offerIndex].isArchived = archived
        saveUserCards()
    }

    func recordAnnualFee(_ amount: Double?, year: Int, for userCard: UserCard) {
        guard amount == nil || (amount?.isFinite == true && (amount ?? -1) >= 0),
              let index = userCards.firstIndex(where: { $0.id == userCard.id }) else { return }
        var fees = userCards[index].annualFeesPaid ?? [:]
        fees[String(year)] = amount
        userCards[index].annualFeesPaid = fees
        saveUserCards()
    }

    // MARK: - Card Database (bundled)

    func reloadCatalog() {
        allCards = CardCatalog.loadCards()
    }

    // MARK: - Persistence (SwiftData via CloudStore)

    private func saveUserCards() {
        try? store.saveUserCards(userCards)
    }

    func clearAllData() {
        userCards = []
        try? store.saveUserCards([])
        creditUsages = []
        try? store.saveCreditUsages([])
    }

    // MARK: - Card Management

    func addCard(_ card: CreditCard, nickname: String? = nil, creditLimit: Double? = nil) {
        // Check if card already exists
        guard !userCards.contains(where: { $0.cardId == card.id }) else { return }

        let newUserCard = UserCard(card: card, nickname: nickname, creditLimit: creditLimit)
        userCards.append(newUserCard)
        saveUserCards()
    }

    func removeCard(_ userCard: UserCard) {
        userCards.removeAll { $0.id == userCard.id }
        saveUserCards()
        // Purge this card's tracked credit usages so they don't resurface if re-added.
        if creditUsages.contains(where: { $0.cardID == userCard.cardId }) {
            creditUsages.removeAll { $0.cardID == userCard.cardId }
            try? store.saveCreditUsages(creditUsages)
        }
    }

    func updateNickname(for userCard: UserCard, nickname: String?) {
        if let index = userCards.firstIndex(where: { $0.id == userCard.id }) {
            userCards[index].nickname = nickname
            saveUserCards()
        }
    }

    func updateSelectedCategories(for userCard: UserCard, categories: [SpendingCategory]) {
        if let index = userCards.firstIndex(where: { $0.id == userCard.id }) {
            userCards[index].selectedCategories = categories
            saveUserCards()
        }
    }

    func updateCreditLimit(for userCard: UserCard, limit: Double?) {
        if let index = userCards.firstIndex(where: { $0.id == userCard.id }) {
            userCards[index].creditLimit = limit
            saveUserCards()
        }
    }

    /// True when any card in the wallet has rotating categories (drives quarter reminders).
    var hasRotatingCards: Bool {
        userCards.contains { userCard in
            allCards.first(where: { $0.id == userCard.cardId })?.rotatingCategories?.isEmpty == false
        }
    }

    /// Mark this quarter's rotating bonus as activated (or not) for a card.
    func setRotatingActivated(for userCard: UserCard, activated: Bool) {
        if let index = userCards.firstIndex(where: { $0.id == userCard.id }) {
            userCards[index].setRotatingActivated(
                activated,
                quarter: RotatingCategory.currentQuarter(),
                year: RotatingCategory.currentYear()
            )
            saveUserCards()
        }
    }

    func updateBalance(for userCard: UserCard, balance: Double?) {
        if let index = userCards.firstIndex(where: { $0.id == userCard.id }) {
            userCards[index].currentBalance = balance
            saveUserCards()
        }
    }

    func updateSignUpOffer(for userCard: UserCard, bonus: SignUpBonus?) {
        guard let index = userCards.firstIndex(where: { $0.id == userCard.id }) else { return }
        userCards[index].customSignUpBonus = bonus
        if bonus == nil && getCard(for: userCard)?.signUpBonus == nil { userCards[index].signUpBonusStartDate = nil }
        if bonus != nil && userCards[index].signUpBonusStartDate == nil {
            userCards[index].signUpBonusStartDate = Calendar.current.startOfDay(for: Date())
        }
        userCards[index].signUpBonusAchieved = false
        saveUserCards()
    }

    func updateSignUpBonus(for userCard: UserCard, startDate: Date?, achieved: Bool) {
        guard let index = userCards.firstIndex(where: { $0.id == userCard.id }) else { return }
        userCards[index].signUpBonusStartDate = startDate.map { Calendar.current.startOfDay(for: $0) }
        userCards[index].signUpBonusAchieved = achieved
        saveUserCards()
    }

    // Calculate total credit utilization across all cards
    var totalCreditUtilization: Double? {
        let cardsWithLimits = userCards.filter { $0.creditLimit != nil && $0.currentBalance != nil }
        guard !cardsWithLimits.isEmpty else { return nil }

        let totalLimit = cardsWithLimits.compactMap { $0.creditLimit }.reduce(0, +)
        let totalBalance = cardsWithLimits.compactMap { $0.currentBalance }.reduce(0, +)

        guard totalLimit > 0 else { return nil }
        return (totalBalance / totalLimit) * 100
    }

    // MARK: - Statement Credit Usage

    func usedAmount(cardID: String, creditID: String, periodKey: String) -> Double {
        let id = "\(cardID)|\(creditID)|\(periodKey)"
        return creditUsages.first { $0.id == id }?.amountUsed ?? 0
    }

    func setUsedAmount(_ amount: Double, cardID: String, creditID: String, periodKey: String) {
        let usage = CreditUsage(cardID: cardID, creditID: creditID, periodKey: periodKey, amountUsed: amount)
        if let index = creditUsages.firstIndex(where: { $0.id == usage.id }) {
            creditUsages[index] = usage
        } else {
            creditUsages.append(usage)
        }
        try? store.saveCreditUsages(creditUsages)
    }

    // MARK: - Credits Aggregation

    struct UnusedCredit: Identifiable {
        let id: String          // "\(cardID)|\(creditID)"
        let cardID: String
        let cardName: String
        let credit: StatementCredit
        let remaining: Double
        var asOf = Date()
        var resetDate: Date { CreditPeriod.nextReset(for: asOf, cadence: credit.cadence) }
    }

    var unusedCreditsThisPeriod: [UnusedCredit] {
        Self.unusedCredits(userCards: userCards, catalog: allCards, usages: creditUsages)
    }

    nonisolated static func unusedCredits(userCards: [UserCard], catalog: [CreditCard], usages: [CreditUsage],
                                          asOf now: Date = Date()) -> [UnusedCredit] {
        var result: [UnusedCredit] = []
        for userCard in userCards {
            guard let card = catalog.first(where: { $0.id == userCard.cardId }), let credits = card.credits else { continue }
            for credit in credits {
                guard credit.amount.isFinite, credit.amount > 0 else { continue }
                let periodKey = CreditPeriod.key(for: now, cadence: credit.cadence)
                let used = usages.first { $0.cardID == card.id && $0.creditID == credit.id && $0.periodKey == periodKey }?.amountUsed ?? 0
                let remaining = max(0, credit.amount - (used.isFinite ? max(0, used) : 0))
                if remaining > 0 {
                    result.append(UnusedCredit(id: "\(card.id)|\(credit.id)",
                                               cardID: card.id, cardName: userCard.nickname ?? card.name, credit: credit,
                                               remaining: remaining, asOf: now))
                }
            }
        }
        let order: [CreditCadence: Int] = [.monthly: 0, .quarterly: 1, .semiannual: 2, .annual: 3]
        return result.sorted {
            let a = order[$0.credit.cadence] ?? 99
            let b = order[$1.credit.cadence] ?? 99
            if $0.resetDate != $1.resetDate { return $0.resetDate < $1.resetDate }
            return a != b ? a < b : $0.remaining > $1.remaining
        }
    }

    var totalUnusedCredits: Double {
        unusedCreditsThisPeriod.reduce(0) { $0 + $1.remaining }
    }

    // MARK: - Helpers

    func getCard(for userCard: UserCard) -> CreditCard? {
        allCards.first { $0.id == userCard.cardId }
    }

    func getCard(byId id: String) -> CreditCard? {
        allCards.first { $0.id == id }
    }

    func getUserCard(byCardId cardId: String) -> UserCard? {
        userCards.first { $0.cardId == cardId }
    }

    var availableCardsToAdd: [CreditCard] {
        allCards.filter { card in
            !userCards.contains { $0.cardId == card.id }
        }
    }
}
