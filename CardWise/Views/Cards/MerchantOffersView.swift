import SwiftUI

struct MerchantOffersView: View {
    @EnvironmentObject var cardViewModel: CardViewModel
    let userCard: UserCard
    var initialOfferID: String?
    @State private var editingOffer: MerchantOffer?

    private var current: UserCard { cardViewModel.userCards.first { $0.id == userCard.id } ?? userCard }
    private var offers: [MerchantOffer] {
        (current.merchantOffers ?? []).filter { $0.isArchived != true }.sorted { $0.expiresAt < $1.expiresAt }
    }
    private var archived: [MerchantOffer] { (current.merchantOffers ?? []).filter { $0.isArchived == true } }

    var body: some View {
        List {
            Section {
                Button("Add an offer", systemImage: "plus") {
                    let expiry = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
                    editingOffer = MerchantOffer(merchant: "", title: "", minimumSpend: 0, reward: 0,
                                                 rewardKind: .cash, expiresAt: expiry)
                }
                ForEach(offers) { offer in
                    Button { editingOffer = offer } label: { MerchantOfferRow(offer: offer) }
                        .tint(Theme.textPrimary)
                        .swipeActions {
                            Button("Archive") { cardViewModel.setOfferArchived(true, offer: offer, for: current) }
                        }
                }
            } footer: {
                Text("Enter offers from your issuer. Activation and savings are confirmed by you. Archived offers keep their savings in annual history.")
            }
            if !archived.isEmpty {
                Section("Archived Offers") {
                    ForEach(archived) { offer in
                        VStack(alignment: .leading, spacing: 8) {
                            MerchantOfferRow(offer: offer)
                            Button("Restore offer") { cardViewModel.setOfferArchived(false, offer: offer, for: current) }
                        }
                    }
                }
            }
        }
        .navigationTitle("Merchant Offers")
        .onAppear {
            if let id = initialOfferID { editingOffer = (current.merchantOffers ?? []).first { $0.id == id } }
        }
        .sheet(item: $editingOffer) { offer in
            MerchantOfferEditor(userCard: current, offer: offer)
        }
    }
}

struct MerchantOfferRow: View {
    let offer: MerchantOffer
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(offer.merchant).font(.headline)
            Text(offer.title).font(.subheadline)
            Text(status).font(.caption).foregroundStyle(Theme.textSecondary)
            Text("Through \(Calendar.current.date(byAdding: .day, value: -1, to: offer.expiresAt)?.formatted(date: .abbreviated, time: .omitted) ?? "")")
                .font(.caption).foregroundStyle(Theme.textSecondary)
        }.padding(.vertical, 4)
    }

    private var status: String {
        if offer.redeemedAt != nil { return "Used · savings recorded by you" }
        if offer.expiresAt <= Date() { return "Expired" }
        return offer.isActivated ? "Activation confirmed by you" : "Activation not confirmed"
    }
}

struct MerchantOfferEditor: View {
    @EnvironmentObject var cardViewModel: CardViewModel
    @Environment(\.dismiss) private var dismiss
    let userCard: UserCard
    let offer: MerchantOffer
    @State private var merchant: String
    @State private var title: String
    @State private var minimum: String
    @State private var reward: String
    @State private var maximum: String
    @State private var kind: MerchantOffer.RewardKind
    @State private var finalDay: Date
    @State private var activated: Bool
    @State private var used: Bool
    @State private var received: String
    @State private var receivedDate: Date

    init(userCard: UserCard, offer: MerchantOffer) {
        self.userCard = userCard
        self.offer = offer
        _merchant = State(initialValue: offer.merchant)
        _title = State(initialValue: offer.title)
        _minimum = State(initialValue: String(offer.minimumSpend))
        _reward = State(initialValue: offer.reward > 0 ? String(offer.reward) : "")
        _maximum = State(initialValue: offer.maximumReward.map { String($0) } ?? "")
        _kind = State(initialValue: offer.rewardKind)
        _finalDay = State(initialValue: Calendar.current.date(byAdding: .day, value: -1, to: offer.expiresAt) ?? Date())
        _activated = State(initialValue: offer.isActivated)
        _used = State(initialValue: offer.redeemedAt != nil)
        _received = State(initialValue: offer.savingsReceived.map { String($0) } ?? "")
        _receivedDate = State(initialValue: offer.redeemedAt ?? Date())
    }

    private var draft: MerchantOffer? {
        guard let minSpend = Double(minimum), let value = Double(reward),
              maximum.isEmpty || Double(maximum) != nil,
              !used || Double(received) != nil else { return nil }
        var result = offer
        result.merchant = merchant.trimmingCharacters(in: .whitespacesAndNewlines)
        result.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        result.minimumSpend = minSpend
        result.reward = value
        result.rewardKind = kind
        result.maximumReward = maximum.isEmpty ? nil : Double(maximum)
        result.expiresAt = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: finalDay)) ?? finalDay
        result.isActivated = activated
        result.redeemedAt = used ? receivedDate : nil
        result.savingsReceived = used ? Double(received) : nil
        return result.isValid ? result : nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Offer Details") {
                    TextField("Merchant", text: $merchant)
                        .textInputAutocapitalization(.words)
                    TextField("Offer description", text: $title)
                    Picker("Reward Type", selection: $kind) {
                        ForEach(MerchantOffer.RewardKind.allCases, id: \.self) { Text($0.title).tag($0) }
                    }
                    numberField("Minimum Purchase ($)", text: $minimum)
                    numberField(kind == .cash ? "Cash Back ($)" : "Percent Back", text: $reward)
                    numberField("Maximum Reward ($, Optional)", text: $maximum)
                    DatePicker("Last Eligible Day", selection: $finalDay, displayedComponents: .date)
                }
                Section {
                    Toggle("I activated this offer with my issuer", isOn: $activated)
                    Toggle("I received the offer savings", isOn: $used)
                    if used {
                        numberField("Savings Received ($)", text: $received)
                        DatePicker("Savings Received On", selection: $receivedDate, in: ...Date(), displayedComponents: .date)
                    }
                } footer: {
                    Text("Enter posted offer savings only, excluding base rewards and statement credits tracked elsewhere. Offer estimates assume a single eligible purchase; issuer exclusions still apply.")
                }
                if draft == nil {
                    Text("Enter a merchant, description and positive reward. Amounts must be zero or greater; percent back must be 100 or less. Used offers need a received savings amount.")
                        .font(.caption).foregroundStyle(Theme.danger)
                }
                if (userCard.merchantOffers ?? []).contains(where: { $0.id == offer.id }) {
                    Section {
                        Button("Archive offer") {
                            cardViewModel.setOfferArchived(true, offer: offer, for: userCard)
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Edit Offer")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let draft { cardViewModel.saveOffer(draft, for: userCard); dismiss() }
                    }.disabled(draft == nil)
                }
            }
        }
    }

    private func numberField(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.subheadline)
            TextField("0", text: text).keyboardType(.decimalPad)
                .accessibilityLabel(title)
        }
    }
}

struct MatchingMerchantOffers: View {
    @EnvironmentObject var cardViewModel: CardViewModel
    let merchant: String
    let amount: Double

    var body: some View {
        let matches = cardViewModel.userCards.flatMap { wallet in
            (wallet.merchantOffers ?? []).filter { $0.isArchived != true && $0.matches(merchant) && $0.redeemedAt == nil && $0.expiresAt > Date() }
                .map { (wallet, $0) }
        }
        if !matches.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Merchant Offers").font(.headline)
                ForEach(matches, id: \.1.id) { wallet, offer in
                    NavigationLink {
                        MerchantOffersView(userCard: wallet)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(offer.title)
                            Text(wallet.nickname ?? cardViewModel.getCard(for: wallet)?.name ?? "Card")
                                .font(.caption)
                            if let savings = offer.estimatedSavings(for: amount) {
                                Text("Estimated offer savings: \(savings.formatted(.currency(code: "USD")))")
                                    .font(.caption).foregroundStyle(Theme.success)
                            } else {
                                Text(offer.isActivated ? "Minimum purchase: \(offer.minimumSpend.formatted(.currency(code: "USD")))" : "Confirm activation with your issuer")
                                    .font(.caption)
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                Text("Offer savings are separate from the reward ranking. Confirm purchase eligibility with your issuer.")
                    .font(.caption).foregroundStyle(Theme.textSecondary)
            }.padding().sectionCard()
        }
    }
}
