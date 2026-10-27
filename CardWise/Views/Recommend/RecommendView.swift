import SwiftUI

struct RecommendView: View {
    @ObservedObject private var preferences = RecommendationSettingsStore.shared
    @State private var includeConditionalRewards = false
    @EnvironmentObject var cardViewModel: CardViewModel
    @EnvironmentObject var spendingViewModel: SpendingViewModel
    @State private var searchText = ""
    @State private var selectedCategory: SpendingCategory = .dining
    @State private var overriddenCategory: SpendingCategory?
    @State private var amount: String = "100"
    @State private var showCategoryPicker = false
    @State private var showingSuggestions = false
    @State private var showingHistory = false
    @FocusState private var isSearchFocused: Bool
    @FocusState private var isAmountFocused: Bool

    var matchingMerchants: [Merchant] {
        MerchantDatabase.searchMerchants(query: searchText)
    }

    var detectedCategory: SpendingCategory? {
        if let overriddenCategory { return overriddenCategory }
        return MerchantDatabase.suggestCategory(for: searchText)
    }

    var effectiveCategory: SpendingCategory {
        detectedCategory ?? selectedCategory
    }

    var recommendations: [CardRecommendation] {
        let amountValue = Double(amount) ?? 100
        return RecommendationEngine.shared.getRecommendations(
            for: effectiveCategory,
            amount: amountValue,
            userCards: cardViewModel.userCards,
            allCards: cardViewModel.allCards,
            spendings: spendingViewModel.spendings,
            settings: preferences.settings,
            includeConditionalRewards: includeConditionalRewards
        )
    }

    var recentSearches: [SearchHistoryManager.SearchItem] {
        SearchHistoryManager.shared.recentSearches(limit: 5)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Input Section
                VStack(spacing: 12) {
                    // Merchant search with autocomplete
                    VStack(alignment: .leading, spacing: 0) {
                        AppSearchField(
                            placeholder: "Search merchant (e.g., Costco, Starbucks)",
                            text: $searchText,
                            focused: $isSearchFocused
                        )
                        .onChange(of: searchText) { _, newValue in
                            overriddenCategory = nil
                            showingSuggestions = !newValue.isEmpty && isSearchFocused
                            showingHistory = newValue.isEmpty && isSearchFocused
                        }
                        .onChange(of: isSearchFocused) { _, focused in
                            showingHistory = focused && searchText.isEmpty
                            showingSuggestions = focused && !searchText.isEmpty
                        }
                        .onSubmit {
                            // Save search to history when user submits
                            if !searchText.isEmpty {
                                SearchHistoryManager.shared.addSearch(searchText, category: detectedCategory)
                            }
                        }

                        // Search history (when empty)
                        if showingHistory && !recentSearches.isEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Text("Recent")
                                        .font(.app(.caption, weight: .medium))
                                        .foregroundStyle(Theme.textSecondary)
                                    Spacer()
                                    Button {
                                        SearchHistoryManager.shared.clearHistory()
                                        showingHistory = false
                                    } label: {
                                        Text("Clear")
                                            .font(.app(.caption))
                                            .foregroundStyle(Theme.accent)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)

                                ForEach(recentSearches) { item in
                                    Button {
                                        searchText = item.query
                                        showingHistory = false
                                        showingSuggestions = false
                                        isSearchFocused = false
                                    } label: {
                                        HStack {
                                            Image(systemName: "clock.arrow.circlepath")
                                                .foregroundStyle(Theme.textSecondary)
                                                .frame(width: 24)
                                            Text(item.query)
                                                .foregroundStyle(Theme.textPrimary)
                                            if let category = item.spendingCategory {
                                                Text("(\(category.displayName))")
                                                    .font(.app(.caption))
                                                    .foregroundStyle(Theme.textSecondary)
                                            }
                                            Spacer()
                                        }
                                        .font(.app(.body))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .background(Theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .softShadow()
                        }

                        // Autocomplete suggestions
                        if showingSuggestions && (!matchingMerchants.isEmpty || detectedCategory != nil) {
                            VStack(alignment: .leading, spacing: 0) {
                                if let detected = detectedCategory {
                                    Button {
                                        selectedCategory = detected
                                        overriddenCategory = detected
                                        showingSuggestions = false
                                        isSearchFocused = false
                                        SearchHistoryManager.shared.addSearch(searchText, category: detected)
                                    } label: {
                                        HStack(spacing: 12) {
                                            Image(systemName: detected.icon)
                                                .foregroundStyle(Theme.accent)
                                                .frame(width: 24)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Category: \(detected.displayName)")
                                                    .font(.app(.body, weight: .semibold))
                                                    .foregroundStyle(Theme.accent)
                                                    .lineLimit(1)
                                                Text("Select category for recommendations")
                                                    .font(.app(.caption2))
                                                    .foregroundStyle(Theme.textSecondary)
                                                    .lineLimit(1)
                                            }
                                            Spacer()
                                            Image(systemName: "arrow.up.left")
                                                .font(.app(.caption))
                                                .foregroundStyle(Theme.accent)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                    }
                                    .buttonStyle(.plain)

                                    if !matchingMerchants.isEmpty {
                                        Divider()
                                            .overlay(Theme.separator)
                                            .padding(.leading, 48)
                                    }
                                }

                                ForEach(matchingMerchants.prefix(5)) { merchant in
                                    Button {
                                        searchText = merchant.name
                                        overriddenCategory = merchant.category
                                        showingSuggestions = false
                                        isSearchFocused = false
                                        SearchHistoryManager.shared.addSearch(merchant.name, category: merchant.category)
                                    } label: {
                                        HStack {
                                            Image(systemName: merchant.category.icon)
                                                .foregroundStyle(Theme.textSecondary)
                                                .frame(width: 24)
                                            Text(merchant.name)
                                                .foregroundStyle(Theme.textPrimary)
                                                .lineLimit(1)
                                            Spacer()
                                            Text(merchant.category.displayName)
                                                .font(.app(.caption))
                                                .foregroundStyle(Theme.textSecondary)
                                                .lineLimit(1)
                                        }
                                        .font(.app(.body))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                    }
                                    .buttonStyle(.plain)

                                    if merchant.id != matchingMerchants.prefix(5).last?.id {
                                        Divider()
                                            .overlay(Theme.separator)
                                            .padding(.leading, 48)
                                    }
                                }
                            }
                            .background(Theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .softShadow()
                        }
                    }

                    // Category Selection & Detection Banner
                    Button {
                        showCategoryPicker = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: effectiveCategory.icon)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Theme.accent)
                                .frame(width: 36, height: 36)
                                .background(Theme.accentSoft())
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(effectiveCategory.displayName)
                                        .font(.app(.subheadline, weight: .semibold))
                                        .foregroundStyle(Theme.textPrimary)
                                        .lineLimit(1)

                                    if detectedCategory != nil {
                                        Image(systemName: "sparkles")
                                            .font(.caption2)
                                            .foregroundStyle(Theme.accent)
                                    }
                                }

                                Text(detectedCategory != nil ? "Auto-detected category" : "Tap to change category")
                                    .font(.app(.caption2))
                                    .foregroundStyle(Theme.textSecondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            Text("Change")
                                .font(.app(.caption, weight: .medium))
                                .foregroundStyle(Theme.accent)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Theme.textSecondary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Theme.separator, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)

                    // Amount input
                    HStack {
                        Text("Amount")
                            .font(.app(.body))
                            .foregroundStyle(Theme.textPrimary)
                        Spacer()
                        Text("$")
                            .foregroundStyle(Theme.textPrimary)
                        TextField("100", text: $amount)
                            .keyboardType(.decimalPad)
                            .focused($isAmountFocused)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .padding(8)
                            .background(Theme.surfaceAlt)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
                .padding()
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            isAmountFocused = false
                            isSearchFocused = false
                        }
                    }
                }

                Divider()
                    .overlay(Theme.separator)

                // Recommendations
                if cardViewModel.userCards.isEmpty {
                    AppEmptyState(
                        icon: "creditcard",
                        title: "No Cards",
                        message: "Add cards to your wallet to get recommendations"
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if recommendations.isEmpty {
                    AppEmptyState(
                        icon: "questionmark.circle",
                        title: "No Recommendations",
                        message: "No cards match this category"
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        PurchaseConditionsToggle(isOn: $includeConditionalRewards)
                        Text(preferences.settings.ranking.explanation)
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                        Text("Estimates use recorded spending and local merchant categories. Issuer coding and redemption values can differ.")
                            .font(.caption2)
                            .foregroundStyle(Theme.textSecondary)
                        ForEach(Array(recommendations.enumerated()), id: \.element.id) { index, rec in
                            RecommendationDetailRow(
                                recommendation: rec,
                                rank: index + 1,
                                isTop: index == 0
                            )
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .screenBackground()
            .navigationTitle("Recommend")
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPickerView(selectedCategory: Binding(
                    get: { effectiveCategory },
                    set: { newCategory in
                        selectedCategory = newCategory
                        overriddenCategory = newCategory
                    }
                ))
            }
            .onTapGesture {
                // Dismiss keyboard and suggestions when tapping outside
                isSearchFocused = false
                showingSuggestions = false
            }
        }
    }
}

struct RecommendationDetailRow: View {
    @EnvironmentObject var cardViewModel: CardViewModel
    let recommendation: CardRecommendation
    let rank: Int
    let isTop: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 16) {
                // Rank
                RankBadge(rank: rank)

                // Card info
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        CardImageView(
                            imageURL: recommendation.card.imageURL,
                            fallbackColor: recommendation.card.imageColor,
                            width: 40,
                            height: 26,
                            cornerRadius: 4
                        )

                        VStack(alignment: .leading) {
                            Text(recommendation.userCard.nickname ?? recommendation.card.name)
                                .font(.app(.headline))
                                .foregroundStyle(Theme.textPrimary)
                            Text(recommendation.card.issuer)
                                .font(.app(.caption))
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }

                    Text(recommendation.reason)
                        .font(.app(.caption))
                        .foregroundStyle(Theme.textSecondary)

                    if recommendation.needsActivation {
                        Button {
                            cardViewModel.setRotatingActivated(for: recommendation.userCard, activated: true)
                        } label: {
                            Label("Confirm issuer activation", systemImage: "exclamationmark.triangle.fill")
                                .font(.app(.caption))
                                .foregroundStyle(Theme.warning)
                        }
                        .buttonStyle(.borderless)
                    }
                }

                Spacer()

                // Reward info
                VStack(alignment: .trailing, spacing: 4) {
                    RewardBadge(text: recommendation.displayReward, emphasized: isTop)

                    Text(recommendation.formattedEstimatedReward)
                        .font(.app(.subheadline))
                        .foregroundStyle(Theme.textSecondary)

                    Text("estimated")
                        .font(.app(.caption2))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            RecommendationContextView(recommendation: recommendation)
        }
        .padding(.vertical, 8)
        .listRowBackground(isTop ? Theme.accentSoft() : Color.clear)
        .listRowSeparatorTint(Theme.separator)
    }
}

struct CategoryPickerCard: View {
    let category: SpendingCategory
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(isSelected ? Theme.accent : Theme.textPrimary)
                .frame(width: 36, height: 36)
                .background(isSelected ? Theme.accent.opacity(0.15) : Theme.surfaceAlt)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(category.displayName)
                .font(.app(.subheadline, weight: isSelected ? .semibold : .medium))
                .foregroundStyle(isSelected ? Theme.accent : Theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 0)

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Theme.accent)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? Theme.accentSoft() : Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isSelected ? Theme.accent : Theme.separator, lineWidth: isSelected ? 1.5 : 1)
        )
    }
}

struct CategoryPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCategory: SpendingCategory
    @State private var search = ""
    @FocusState private var isSearchFocused: Bool

    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var filteredCategories: [SpendingCategory] {
        let trimmed = search.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return SpendingCategory.allCases
        }
        return SpendingCategory.allCases.filter { cat in
            cat.displayName.localizedCaseInsensitiveContains(trimmed) ||
            cat.rawValue.localizedCaseInsensitiveContains(trimmed)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppSearchField(
                    placeholder: "Search categories (e.g. Dining, Travel)",
                    text: $search,
                    focused: $isSearchFocused
                )
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 12)

                ScrollView {
                    if filteredCategories.isEmpty {
                        AppEmptyState(
                            icon: "magnifyingglass",
                            title: "No Categories Found",
                            message: "Try searching with a different term"
                        )
                        .padding(.top, 40)
                    } else {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(filteredCategories) { category in
                                Button {
                                    selectedCategory = category
                                    dismiss()
                                } label: {
                                    CategoryPickerCard(
                                        category: category,
                                        isSelected: selectedCategory == category
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                    }
                }
            }
            .screenBackground()
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    let store = CloudStore.preview()
    return RecommendView()
        .environmentObject(CardViewModel(store: store))
        .environmentObject(SpendingViewModel(store: store))
}
