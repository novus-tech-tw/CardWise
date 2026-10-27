import Foundation

struct CardRecommendation: Identifiable, Equatable {
    let id: String
    let card: CreditCard
    let userCard: UserCard
    let effectiveReward: Double
    let isPercentage: Bool
    let estimatedReward: Double  // for a given amount
    let reason: String
    let isRotating: Bool
    let isSelectable: Bool
    let needsActivation: Bool

    // Additional context for improved recommendations
    let signUpBonusProgress: SignUpBonusProgress?
    let spendingCapRemaining: Double?
    let isNearSpendingCap: Bool
    var context: [String] = []

    var displayReward: String {
        if isPercentage {
            return "\(effectiveReward.formatted(.number.precision(.fractionLength(0...2))))%"
        } else {
            return "\(effectiveReward.formatted(.number.precision(.fractionLength(0...2))))x"
        }
    }

    var formattedEstimatedReward: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: estimatedReward)) ?? "$\(estimatedReward)"
    }

    var hasSignUpBonusInProgress: Bool {
        guard let progress = signUpBonusProgress else { return false }
        return progress.isInProgress
    }
}

/// Tracks sign-up bonus progress
struct SignUpBonusProgress: Equatable {
    let spentSoFar: Double
    let requirement: Double
    let daysRemaining: Int
    let isAchieved: Bool
    var deadline: Date?
    var hasStarted: Bool = true

    var isInProgress: Bool { hasStarted && !isAchieved && daysRemaining > 0 }

    var percentComplete: Double {
        requirement > 0 ? min(100, max(0, (spentSoFar / requirement) * 100)) : 100
    }

    var amountRemaining: Double {
        max(0, requirement - spentSoFar)
    }

    var formattedProgress: String {
        "$\(Int(spentSoFar)) / $\(Int(requirement))"
    }
}

final class RecommendationEngine {
    static let shared = RecommendationEngine()
    private init() {}

    func getRecommendations(
        for category: SpendingCategory,
        amount: Double = 100,
        userCards: [UserCard],
        allCards: [CreditCard],
        spendings: [Spending] = [],
        settings: RecommendationSettings = RecommendationSettings(),
        asOf date: Date = Date(),
        includeConditionalRewards: Bool = false
    ) -> [CardRecommendation] {
        guard amount.isFinite, amount > 0 else { return [] }
        let recommendations = userCards.compactMap { userCard -> CardRecommendation? in
            guard let card = allCards.first(where: { $0.id == userCard.cardId }) else { return nil }
            let request = Request(category: category, amount: amount, spendings: spendings, settings: settings, date: date, includeConditionalRewards: includeConditionalRewards)
            return recommendation(card: card, userCard: userCard, request: request)
        }
        return recommendations.enumerated().sorted { lhs, rhs in
            let first = lhs.element
            let second = rhs.element
            if settings.ranking == .signupFirst, first.hasSignUpBonusInProgress != second.hasSignUpBonusInProgress {
                return first.hasSignUpBonusInProgress
            }
            if first.estimatedReward != second.estimatedReward { return first.estimatedReward > second.estimatedReward }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    func getRecommendations(
        for merchantName: String,
        amount: Double = 100,
        userCards: [UserCard],
        allCards: [CreditCard],
        spendings: [Spending] = [],
        settings: RecommendationSettings = RecommendationSettings(),
        asOf date: Date = Date(),
        includeConditionalRewards: Bool = false
    ) -> (recommendations: [CardRecommendation], detectedCategory: SpendingCategory?) {
        let detectedCategory = MerchantDatabase.suggestCategory(for: merchantName)
        return (getRecommendations(for: detectedCategory ?? .other, amount: amount, userCards: userCards,
                                   allCards: allCards, spendings: spendings, settings: settings, asOf: date, includeConditionalRewards: includeConditionalRewards), detectedCategory)
    }

    private struct RewardOption {
        let multiplier: Double
        let isPercentage: Bool
        let reason: String
        var cap: RewardCapRule?
        var isRotating = false
        var isSelectable = false
    }

    private func estimate(_ option: RewardOption, amount: Double, value: Double) -> Double {
        amount * option.multiplier * (option.isPercentage ? 0.01 : value)
    }

    private func estimate(_ option: RewardOption, base: RewardOption, amount: Double,
                          remaining: Double?, value: Double) -> Double {
        let bonusAmount = min(amount, remaining ?? amount)
        return estimate(option, amount: bonusAmount, value: value) + estimate(base, amount: amount - bonusAmount, value: value)
    }

    private struct Request {
        let category: SpendingCategory
        let amount: Double
        let spendings: [Spending]
        let settings: RecommendationSettings
        let date: Date
        let includeConditionalRewards: Bool
    }

    private struct EligibleOptions {
        var options: [RewardOption] = []
        var context: [String] = []
        var needsActivation = false
    }

    private struct EvaluatedOption {
        let option: RewardOption
        let remaining: Double?
        let estimate: Double
    }

    private func recommendation(card: CreditCard, userCard: UserCard, request: Request) -> CardRecommendation {
        let amount = request.amount
        let date = request.date
        let settings = request.settings
        let spendings = request.spendings
        let base = RewardOption(multiplier: card.baseReward, isPercentage: card.baseIsPercentage, reason: "Base reward")
        let eligible = eligibleOptions(card: card, userCard: userCard, request: request)
        var context = eligible.context
        let activation = eligible.needsActivation
        let options = [base] + eligible.options
        let value = settings.dollarsPerPoint(for: card.id)
        let evaluated = options.map { option -> EvaluatedOption in
            let remaining = option.cap?.remaining(cardID: card.id, spendings: spendings, asOf: date)
            return EvaluatedOption(option: option, remaining: remaining,
                                   estimate: estimate(option, base: base, amount: amount, remaining: remaining, value: value))
        }
        // Prefer a category explanation over the base explanation when their dollar estimates tie.
        let best = evaluated.enumerated().max {
            $0.element.estimate == $1.element.estimate ? $0.offset < $1.offset : $0.element.estimate < $1.element.estimate
        }?.element ?? EvaluatedOption(option: base, remaining: nil, estimate: estimate(base, amount: amount, value: value))
        let option = best.option
        let remaining = best.remaining
        let estimated = best.estimate
        if let remaining, let rule = option.cap {
            context.append("\(remaining.formatted(.currency(code: "USD"))) bonus spending left; resets \(rule.period.interval(containing: date).end.formatted(date: .abbreviated, time: .omitted)).")
            if remaining == 0 {
                context.append("Bonus cap exhausted. This purchase earns the base rate.")
            } else if remaining < amount {
                context.append("\(remaining.formatted(.currency(code: "USD"))) earns the bonus; the rest earns the base rate.")
            }
        }
        if !option.isPercentage || !card.baseIsPercentage {
            context.append("Points valued at \((value * 100).formatted(.number.precision(.fractionLength(0...2))))¢ each (your estimate).")
        }
        let progress = signUpBonusProgress(card: card, userCard: userCard, spendings: spendings, asOf: date)
        if settings.ranking == .signupFirst, progress?.isInProgress == true {
            context.append("Sign-up goal prioritized; bonus value is excluded from this purchase estimate.")
        }
        let exhausted = remaining == 0
        return CardRecommendation(
            id: userCard.id, card: card, userCard: userCard,
            effectiveReward: exhausted ? base.multiplier : option.multiplier,
            isPercentage: exhausted ? base.isPercentage : option.isPercentage,
            estimatedReward: estimated, reason: option.reason,
            isRotating: option.isRotating || activation,
            isSelectable: option.isSelectable,
            needsActivation: activation,
            signUpBonusProgress: progress, spendingCapRemaining: remaining,
            isNearSpendingCap: remaining.map { $0 < amount || $0 < (option.cap?.cap ?? 0) * 0.2 } ?? false,
            context: context
        )
    }

    private func eligibleOptions(card: CreditCard, userCard: UserCard, request: Request) -> EligibleOptions {
        let category = request.category
        let date = request.date
        var result = EligibleOptions()
        for reward in card.categoryRewards where category.isCovered(by: [reward.category]) {
            if let note = reward.note {
                if reward.requiresPurchaseConfirmation && !request.includeConditionalRewards {
                    result.context.append("Not included: \(reward.displayMultiplier) requires \(note). Enable special rate assumptions only if these terms apply.")
                    continue
                }
                result.context.append("Rate terms: \(note).")
            }
            result.options.append(RewardOption(multiplier: reward.multiplier, isPercentage: reward.isPercentage,
                                        reason: "\(reward.displayMultiplier) on \(reward.category.displayName)", cap: RewardCapRule.fixed(reward)))
        }
        var needsActivation = false
        if let rotating = card.rotatingCategory(asOf: date), category.isCovered(by: rotating.categories) {
            needsActivation = rotating.activationRequired && !userCard.hasActivatedRotating(quarter: rotating.quarter, year: rotating.year)
            if needsActivation {
                result.context.append("Q\(rotating.quarter) \(rotating.year) bonus needs issuer activation. Base or other eligible rewards apply until you confirm it.")
            } else {
                result.options.append(RewardOption(multiplier: rotating.multiplier, isPercentage: rotating.isPercentage,
                                            reason: "\(rotating.displayMultiplier) Q\(rotating.quarter) \(rotating.year) rotating category",
                                            cap: RewardCapRule.rotating(rotating), isRotating: true))
            }
        } else if card.rotatingCategories?.contains(where: { category.isCovered(by: $0.categories) }) == true {
            result.context.append("No matching rotating bonus published for this quarter. Older schedules are not applied.")
        }
        if let config = card.selectableConfig, category.isCovered(by: config.availableCategories) {
            let selected = (userCard.selectedCategories ?? []).filter(config.availableCategories.contains)
            if category.isCovered(by: selected) {
                result.options.append(RewardOption(multiplier: config.multiplier, isPercentage: config.isPercentage,
                                            reason: "\(config.multiplier.formatted())\(config.isPercentage ? "%" : "x") selected category",
                                            cap: RewardCapRule.selectable(config, userCard: userCard), isSelectable: true))
                result.context.append("Uses your saved category choice. Confirm the same choice and effective date with the issuer.")
            } else {
                result.context.append("\(category.displayName) is not selected. Your saved issuer category choice is required for the selectable bonus.")
            }
        }
        result.needsActivation = needsActivation
        return result
    }

    func signUpBonusProgress(card: CreditCard, userCard: UserCard, spendings: [Spending], asOf date: Date = Date()) -> SignUpBonusProgress? {
        guard let bonus = userCard.signUpBonus(for: card), let start = userCard.signUpBonusStartDate,
              let deadline = userCard.signUpBonusDeadline(for: card), !userCard.signUpBonusAchieved else { return nil }
        let spent = max(0, spendings.filter {
            $0.cardUsed == card.id && $0.date >= start && $0.date < deadline && $0.date <= date
        }.reduce(0) { $0 + $1.amount })
        let days = max(0, Int(ceil(deadline.timeIntervalSince(date) / 86400)))
        return SignUpBonusProgress(spentSoFar: spent, requirement: bonus.spendRequirement, daysRemaining: days,
                                  isAchieved: spent >= bonus.spendRequirement, deadline: deadline, hasStarted: date >= start)
    }

    func suggestCategorySelections(userCards: [UserCard], allCards: [CreditCard], spendingHistory: [Spending]) -> [String: [SpendingCategory]] {
        var suggestions: [String: [SpendingCategory]] = [:]
        for userCard in userCards {
            guard let card = allCards.first(where: { $0.id == userCard.cardId }), let config = card.selectableConfig else { continue }
            let totals = config.availableCategories.map { category in
                (category, spendingHistory.filter { $0.category.isCovered(by: [category]) }.reduce(0) { $0 + $1.amount })
            }
            let categories = totals.filter { $0.1 > 0 }.sorted {
                $0.1 == $1.1 ? $0.0.rawValue < $1.0.rawValue : $0.1 > $1.1
            }.prefix(config.maxSelections).map(\.0)
            if !categories.isEmpty { suggestions[userCard.id] = categories }
        }
        return suggestions
    }
}
