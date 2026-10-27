import Foundation

extension SpendingCategory {
    /// Local category mapping; issuer merchant coding may differ.
    var rewardFallbacks: [SpendingCategory] {
        switch self {
        case .hotels, .airlines: return [.travel]
        case .wholeFoods: return [.grocery]
        case .evCharging: return [.gas]
        case .amazon: return [.onlineShopping]
        case .target: return [.onlineShopping, .grocery]
        case .walmart: return [.grocery]
        case .macys, .kohls, .gap, .nordstrom: return [.onlineShopping]
        default: return []
        }
    }

    func isCovered(by categories: [SpendingCategory]) -> Bool {
        categories.contains(self) || rewardFallbacks.contains(where: categories.contains)
    }
}

struct RewardCapRule {
    let id: String
    let categories: [SpendingCategory]
    let cap: Double
    let period: CapPeriod
    let isRotating: Bool

    func spent(cardID: String, spendings: [Spending], asOf date: Date) -> Double {
        let start = period.interval(containing: date).start
        return max(0, spendings.filter {
            $0.cardUsed == cardID && $0.category.isCovered(by: categories) && $0.date >= start && $0.date <= date
        }.reduce(0) { $0 + $1.amount })
    }

    func remaining(cardID: String, spendings: [Spending], asOf date: Date) -> Double {
        max(0, cap - spent(cardID: cardID, spendings: spendings, asOf: date))
    }

    static func fixed(_ reward: CategoryReward) -> RewardCapRule? {
        guard let cap = reward.cap, let period = reward.capPeriod else { return nil }
        return RewardCapRule(id: reward.id, categories: [reward.category], cap: cap, period: period, isRotating: false)
    }

    static func rotating(_ reward: RotatingCategory) -> RewardCapRule? {
        guard let cap = reward.cap else { return nil }
        return RewardCapRule(id: "rotating-\(reward.id)", categories: reward.categories, cap: cap, period: .quarterly, isRotating: true)
    }

    static func selectable(_ config: SelectableConfig, userCard: UserCard) -> RewardCapRule? {
        let selected = (userCard.selectedCategories ?? []).filter(config.availableCategories.contains)
        guard !selected.isEmpty, let cap = config.cap, let period = config.capPeriod else { return nil }
        return RewardCapRule(id: "selectable", categories: selected, cap: cap, period: period, isRotating: false)
    }
}

extension CapPeriod {
    func interval(containing date: Date, calendar: Calendar = .current) -> DateInterval {
        let component: Calendar.Component
        switch self {
        case .monthly: component = .month
        case .quarterly: component = .quarter
        case .yearly: component = .year
        }
        return calendar.dateInterval(of: component, for: date) ?? DateInterval(start: date, duration: 0)
    }
}

extension CreditCard {
    func rotatingCategory(asOf date: Date) -> RotatingCategory? {
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        return rotatingCategories?.first { $0.year == year && $0.quarter == (month - 1) / 3 + 1 }
    }

    func capRules(userCard: UserCard, asOf date: Date) -> [RewardCapRule] {
        var rules = categoryRewards.compactMap(RewardCapRule.fixed)
        if let rotating = rotatingCategory(asOf: date), let rule = RewardCapRule.rotating(rotating) { rules.append(rule) }
        if let config = selectableConfig, let rule = RewardCapRule.selectable(config, userCard: userCard) { rules.append(rule) }
        return rules
    }
}
