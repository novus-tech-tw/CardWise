import Foundation
import UserNotifications

struct BenefitReminder: Equatable, Identifiable {
    let id: String
    let date: Date
    let cardName: String
    let creditName: String
    let remaining: Double
}

enum BenefitReminderPlanner {
    /// Keep space below iOS's notification limit for quarter and cap alerts.
    static func reminders(userCards: [UserCard], catalog: [CreditCard], usages: [CreditUsage],
                          now: Date = Date(), calendar: Calendar = Calendar(identifier: .gregorian),
                          limit: Int = 48) -> [BenefitReminder] {
        var result: [BenefitReminder] = []
        for wallet in userCards {
            guard let card = catalog.first(where: { $0.id == wallet.cardId }) else { continue }
            for credit in card.credits ?? [] where credit.amount.isFinite && credit.amount > 0 {
                var periodDate = now
                // Pre-schedule the coming year; opening the app replenishes the nearest alerts.
                for _ in 0..<credit.cadence.periodsPerYear {
                    let key = CreditPeriod.key(for: periodDate, cadence: credit.cadence, calendar: calendar)
                    let used = usages.first { $0.cardID == card.id && $0.creditID == credit.id && $0.periodKey == key }?.amountUsed ?? 0
                    let remaining = max(0, credit.amount - (used.isFinite ? max(0, used) : 0))
                    let reset = CreditPeriod.nextReset(for: periodDate, cadence: credit.cadence, calendar: calendar)
                    if remaining > 0 {
                        for days in [7, 3, 1] {
                            guard let day = calendar.date(byAdding: .day, value: -days, to: reset),
                                  let fire = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: day), fire > now else { continue }
                            result.append(BenefitReminder(id: "benefit-\(wallet.id)-\(credit.id)-\(key)-\(days)",
                                                          date: fire, cardName: wallet.nickname ?? card.name,
                                                          creditName: credit.description, remaining: remaining))
                        }
                    }
                    periodDate = reset
                }
            }
        }
        return Array(result.sorted { $0.date == $1.date ? $0.id < $1.id : $0.date < $1.date }.prefix(max(0, limit)))
    }
}

@MainActor
final class BenefitReminderScheduler {
    static let shared = BenefitReminderScheduler()
    private var refreshTask: Task<Void, Never>?

    func refresh(userCards: [UserCard], catalog: [CreditCard], usages: [CreditUsage], defaults: UserDefaults = .standard) {
        let enabled = (defaults.object(forKey: "notificationsEnabled") as? Bool ?? true) &&
            (defaults.object(forKey: "benefitReminders") as? Bool ?? false)
        let reminders = enabled ? BenefitReminderPlanner.reminders(userCards: userCards, catalog: catalog, usages: usages) : []
        // Serialize replacement, including any in-flight UNUserNotificationCenter.add,
        // so a canceled older refresh cannot restore a used benefit's alert.
        let previous = refreshTask
        previous?.cancel()
        refreshTask = Task {
            await previous?.value
            guard !Task.isCancelled else { return }
            let center = UNUserNotificationCenter.current()
            let pending = await center.pendingNotificationRequests()
            guard !Task.isCancelled else { return }
            center.removePendingNotificationRequests(withIdentifiers: pending.map(\.identifier).filter { $0.hasPrefix("benefit-") })
            for reminder in reminders {
                guard !Task.isCancelled else { return }
                let content = UNMutableNotificationContent()
                content.title = "Use your credit before it resets"
                content.body = "\(reminder.cardName): \(reminder.remaining.formatted(.currency(code: "USD"))) left for \(reminder.creditName)."
                content.sound = .default
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.date), repeats: false
                )
                try? await center.add(UNNotificationRequest(identifier: reminder.id, content: content, trigger: trigger))
            }
        }
    }
}
