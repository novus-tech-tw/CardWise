import SwiftUI

struct MerchantCategoryPreferenceView: View {
    let merchant: String
    let category: SpendingCategory
    @ObservedObject private var store = MerchantPreferencesStore.shared

    var body: some View {
        if !merchant.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            HStack {
                if store.savedCategory(for: merchant) == category {
                    Label("Using your saved category", systemImage: "checkmark.circle")
                    Spacer()
                    Button("Forget") { store.remove(merchant) }
                        .foregroundStyle(Theme.accent).frame(minHeight: 44)
                        .accessibilityLabel("Forget saved category for \(merchant)")
                } else {
                    Text("Use this category next time")
                    Spacer()
                    Button("Remember") { store.save(category, for: merchant) }
                        .foregroundStyle(Theme.accent).frame(minHeight: 44)
                        .accessibilityLabel("Remember \(category.displayName) for \(merchant)")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .buttonStyle(.borderless)
        }
    }
}

struct SavedMerchantCategoriesView: View {
    @ObservedObject private var store = MerchantPreferencesStore.shared

    var body: some View {
        List {
            Section {
                if store.categories.isEmpty {
                    Text("Change a merchant's category on Recommend, then tap Remember to use it next time.")
                }
                ForEach(store.categories.keys.sorted(), id: \.self) { merchant in
                    if let category = store.categories[merchant] {
                        LabeledContent(merchant, value: category.displayName)
                            .swipeActions {
                                Button("Forget", role: .destructive) { store.remove(merchant) }
                            }
                            .accessibilityAction(named: "Forget saved category") { store.remove(merchant) }
                    }
                }
            } footer: {
                Text("Saved categories apply to the exact merchant name on this device, including Shortcuts and widgets. They are your preferences; issuer coding can differ.")
            }
        }
        .navigationTitle("Saved Merchant Categories")
    }
}
