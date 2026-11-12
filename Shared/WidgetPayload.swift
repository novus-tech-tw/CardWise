import Foundation

/// Shared contract between the app and its widget. Optional context fields decode older saved payloads.
struct WidgetPayload: Codable, Equatable {
    let topCategory: String
    let topCategoryIcon: String
    let bestCard: String
    let bestCardColor: String
    let rewardRate: String
    let rotatingCategories: [String]
    let rotatingCard: String?
    let spendingThisMonth: Double
    let rewardsThisMonth: Double
    var purchaseContext: String?
    var explanation: String?
    var generatedAt: Date?
    var validUntil: Date?

    var purchaseMerchant: String?
    var purchaseCategory: String?
    var purchaseAmount: Double?
    var walletSections: [WalletWidgetSection]?

    var recommendationURL: URL? {
        guard let purchaseCategory, let purchaseAmount, purchaseAmount.isFinite, purchaseAmount > 0 else { return nil }
        var components = URLComponents()
        components.scheme = "cardwise"
        components.host = "recommend"
        components.queryItems = [URLQueryItem(name: "merchant", value: purchaseMerchant ?? ""),
                                 URLQueryItem(name: "category", value: purchaseCategory),
                                 URLQueryItem(name: "amount", value: String(purchaseAmount))]
        return components.url
    }

    func isStale(at date: Date) -> Bool {
        guard let validUntil else { return true }
        return date >= validUntil
    }
}

enum WalletWidgetSectionKind: String, Codable, CaseIterable, Sendable {
    case categories, offers, deadlines, credits, summary
}

struct WalletWidgetRow: Codable, Equatable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let value: String
    var url: URL?
}

struct WalletWidgetSection: Codable, Equatable {
    let kind: WalletWidgetSectionKind
    let title: String
    let emptyMessage: String
    let rows: [WalletWidgetRow]

    var singleRowDestinationURL: URL? {
        kind == .offers ? rows.first?.url ?? destinationURL : destinationURL
    }

    var destinationURL: URL? {
        switch kind {
        case .categories: return rows.first?.url ?? URL(string: "cardwise://cards")
        case .offers: return URL(string: "cardwise://offers")
        case .deadlines: return URL(string: "cardwise://deadlines")
        case .credits: return URL(string: "cardwise://credits")
        case .summary: return URL(string: "cardwise://cards")
        }
    }
}
