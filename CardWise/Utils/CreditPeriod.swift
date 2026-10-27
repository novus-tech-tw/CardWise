import Foundation

/// Calendar-period identifier for a credit's cadence. A new period yields a new key,
/// so usage naturally resets without any scheduled job.
enum CreditPeriod {
    static func key(for date: Date, cadence: CreditCadence,
                    calendar: Calendar = Calendar(identifier: .gregorian)) -> String {
        let comps = calendar.dateComponents([.year, .month], from: date)
        let year = comps.year ?? 0
        let month = comps.month ?? 1
        switch cadence {
        case .monthly:    return String(format: "%04d-%02d", year, month)
        case .quarterly:  return "\(year)-Q\((month - 1) / 3 + 1)"
        case .semiannual: return "\(year)-H\(month <= 6 ? 1 : 2)"
        case .annual:     return "\(year)"
        }
    }
}

extension CreditPeriod {
    static func nextReset(for date: Date, cadence: CreditCadence,
                          calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        let months = 12 / cadence.periodsPerYear
        let components = calendar.dateComponents([.year, .month], from: date)
        let startMonth = ((components.month ?? 1) - 1) / months * months + 1
        let start = calendar.date(from: DateComponents(year: components.year, month: startMonth, day: 1)) ?? date
        return calendar.date(byAdding: .month, value: months, to: start) ?? date
    }
}
