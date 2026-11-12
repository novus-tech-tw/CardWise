import SwiftUI
import WidgetKit

struct WalletOverviewEntry: TimelineEntry {
    let date: Date
    let section: WalletWidgetSection?
    let isStale: Bool
}

struct WalletOverviewProvider: TimelineProvider {
    let content: WalletWidgetSectionKind
    func placeholder(in context: Context) -> WalletOverviewEntry {
        WalletOverviewEntry(date: Date(), section: WalletWidgetSection(
            kind: .categories, title: "Best Cards by Category", emptyMessage: "",
            rows: [WalletWidgetRow(id: "dining", title: "Dining", subtitle: "Rewards Card", value: "$4.00 est. on $100.00")]
        ), isStale: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (WalletOverviewEntry) -> Void) {
        completion(entry(payload: WidgetStorageHelper.loadPayload(), date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WalletOverviewEntry>) -> Void) {
        let now = Date()
        let payload = WidgetStorageHelper.loadPayload()
        var entries = [entry(payload: payload, date: now)]
        if let expiry = payload?.validUntil, expiry > now {
            entries.append(entry(payload: payload, date: expiry))
        }
        completion(Timeline(entries: entries, policy: .after(now.addingTimeInterval(3600))))
    }

    private func entry(payload: WidgetPayload?, date: Date) -> WalletOverviewEntry {
        WalletOverviewEntry(date: date, section: payload?.walletSections?.first { $0.kind == content },
                            isStale: payload?.isStale(at: date) ?? true)
    }
}

struct WalletOverviewWidget: Widget {
    let content: WalletWidgetSectionKind
    var kind: String { "WalletOverviewWidget.\(content.rawValue)" }

    init() { content = .categories }
    init(content: WalletWidgetSectionKind) { self.content = content }

    private var title: String {
        switch content {
        case .categories: return "Best Cards by Category"
        case .offers: return "Saved Offers"
        case .deadlines: return "Upcoming Deadlines"
        case .credits: return "Unused Statement Credits"
        case .summary: return "Wallet Summary"
        }
    }

    private var detail: String {
        switch content {
        case .categories: return "Compare estimated rewards using your saved spending and point values. Favorite categories appear first."
        case .offers: return "See current offers you entered from your issuers, ordered by expiry."
        case .deadlines: return "See credit resets, offer expirations, quarterly activation checks and sign-up deadlines."
        case .credits: return "See statement credits left this period using your recorded usage."
        case .summary: return "See your saved card count and annual fees from the current catalog."
        }
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WalletOverviewProvider(content: content)) { entry in
            WalletOverviewView(entry: entry)
        }
        .configurationDisplayName(title)
        .description(detail)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular])
    }
}

struct WalletOverviewView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WalletOverviewEntry

    private var rowLimit: Int {
        switch family {
        case .systemLarge: return 5
        case .systemMedium: return 2
        default: return 1
        }
    }

    private var widgetURL: URL? {
        guard !entry.isStale, family == .systemSmall || family == .accessoryRectangular else {
            return entry.section?.destinationURL ?? URL(string: "cardwise://cards")
        }
        return entry.section?.singleRowDestinationURL ?? URL(string: "cardwise://cards")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.section?.title ?? "Wallet Overview").font(.caption.weight(.semibold)).lineLimit(1)
            if entry.isStale || entry.section == nil {
                Text("Open CardWise to refresh").font(.subheadline).widgetAccentable()
            } else if let section = entry.section {
                if section.rows.isEmpty {
                    Text(section.emptyMessage).font(.caption).foregroundStyle(.secondary)
                } else {
                    ForEach(section.rows.prefix(rowLimit)) { row in
                        Link(destination: row.url ?? URL(string: "cardwise://cards")!) {
                            HStack(alignment: .top, spacing: 8) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(row.title).font(.subheadline.weight(.semibold)).lineLimit(1)
                                    Text(family == .accessoryRectangular ? row.value : row.subtitle)
                                        .font(.caption).foregroundStyle(.secondary).lineLimit(1)
                                    if family == .systemSmall {
                                        Text(row.value).font(.caption).lineLimit(1)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                if family == .systemMedium || family == .systemLarge {
                                    Text(row.value).font(.caption).multilineTextAlignment(.trailing).lineLimit(2)
                                }
                            }
                        }.buttonStyle(.plain)
                    }
                    if section.rows.count > rowLimit, family != .accessoryRectangular {
                        Text("+\(section.rows.count - rowLimit) more in CardWise").font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }
            if family != .accessoryRectangular { Spacer(minLength: 0) }
        }
        .privacySensitive()
        .containerBackground(for: .widget) { Color(.systemBackground) }
        .widgetURL(widgetURL)
    }
}
