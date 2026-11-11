import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

struct ShoppingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ShoppingActivityAttributes.self) { context in
            ShoppingLockScreenView(attributes: context.attributes, state: context.state, isStale: context.isStale)
                .activityBackgroundTint(Color(.systemBackground).opacity(0.9))
                .widgetURL(context.attributes.recommendURL)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.attributes.title, systemImage: context.attributes.categoryIcon)
                        .font(.caption)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.rewardRate)
                        .font(.title3.bold())
                        .foregroundStyle(Color(hex: context.state.cardColor) ?? .accentColor)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.state.cardName).font(.headline).lineLimit(1)
                        if let note = context.state.note {
                            Text(note).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                        }
                        Button(intent: EndShoppingModeIntent()) {
                            Label("Done", systemImage: "xmark.circle")
                                .font(.caption)
                        }
                        .tint(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } compactLeading: {
                Image(systemName: "creditcard.fill")
                    .foregroundStyle(Color(hex: context.state.cardColor) ?? .accentColor)
            } compactTrailing: {
                Text(context.state.rewardRate).font(.caption.bold())
            } minimal: {
                Image(systemName: "creditcard.fill")
                    .foregroundStyle(Color(hex: context.state.cardColor) ?? .accentColor)
            }
            .widgetURL(context.attributes.recommendURL)
        }
    }
}

struct ShoppingLockScreenView: View {
    let attributes: ShoppingActivityAttributes
    let state: ShoppingActivityAttributes.ContentState
    let isStale: Bool

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(hex: state.cardColor) ?? .gray)
                .frame(width: 44, height: 28)
                .overlay(Image(systemName: attributes.categoryIcon).font(.caption).foregroundStyle(.white))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(attributes.title).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                Text(state.cardName).font(.headline).lineLimit(1)
                if isStale {
                    Text("Open CardWise to refresh").font(.caption2).foregroundStyle(.secondary)
                } else if let note = state.note {
                    Text(note).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                }
            }
            Spacer(minLength: 4)
            VStack(alignment: .trailing, spacing: 2) {
                Text(state.rewardRate).font(.title2.bold())
                Text("≈ \(state.estimatedReward)").font(.caption2).foregroundStyle(.secondary)
            }
            Button(intent: EndShoppingModeIntent()) {
                Image(systemName: "xmark.circle.fill").font(.title3)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .accessibilityLabel("End shopping mode")
        }
        .padding()
        .accessibilityElement(children: .combine)
    }
}
