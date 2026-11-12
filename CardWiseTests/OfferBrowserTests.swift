import Foundation
import Testing
@testable import CardWise

@Suite @MainActor struct OfferBrowserTests {
    private let now = Date(timeIntervalSince1970: 1_794_916_800)

    private func card(_ id: String) -> CreditCard {
        CreditCard(id: id, name: id, issuer: "Test", network: .visa, annualFee: 0,
                   rewardType: .cashback, baseReward: 1, baseIsPercentage: true,
                   categoryRewards: [], rotatingCategories: nil, selectableConfig: nil,
                   signUpBonus: nil, imageColor: "#112233", imageURL: nil, lastUpdated: nil)
    }

    private func offer(_ id: String = "offer") -> MerchantOffer {
        MerchantOffer(id: id, merchant: "Test Café", title: "Spend and save", minimumSpend: 100,
                      reward: 20, rewardKind: .cash, expiresAt: now.addingTimeInterval(3600), isActivated: true)
    }

    @Test func historyScopesAreDisjointAndCurrentMatchesShortcutInventory() {
        let card = card("Test")
        var wallet = UserCard(card: card)
        var used = offer("used")
        used.redeemedAt = now
        used.expiresAt = now
        var expired = offer("expired")
        expired.expiresAt = now
        var archived = used
        archived.id = "archived"
        archived.isArchived = true
        var unconfirmed = offer("unconfirmed")
        unconfirmed.isActivated = false
        var invalid = offer("invalid")
        invalid.reward = .infinity
        wallet.merchantOffers = [offer(), used, expired, archived, unconfirmed, invalid]
        let expected: [WalletOfferScope: Set<String>] = [.current: ["offer", "unconfirmed"], .used: ["used"],
                                                       .expired: ["expired"], .archived: ["archived"]]
        for scope in WalletOfferScope.allCases {
            let inventory = WalletOfferQuery.inventory(userCards: [wallet], catalog: [card], scope: scope, now: now)
            #expect(Set(inventory.map(\.offer.id)) == expected[scope])
        }
        let inventory = WalletOfferQuery.inventory(userCards: [wallet], catalog: [card], now: now)
        let matches = WalletOfferQuery.matches(userCards: [wallet], catalog: [card], now: now)
        #expect(inventory.map(\.id) == matches.map(\.id))
        #expect(WalletOfferQuery.best(in: matches)?.offer.id == "offer")
    }

    @Test func cardSelectionUsesWalletIdentityAndDoesNotFallBackToAllCards() throws {
        let card = card("Test")
        var first = UserCard(card: card)
        first.nickname = "Travel"
        first.merchantOffers = [offer()]
        var second = UserCard(card: card)
        second.nickname = "Everyday"
        second.merchantOffers = [offer()]
        let wallets = [first, second]
        let matches = WalletOfferQuery.matches(userCards: wallets, catalog: [card], merchant: "test cafe", walletID: second.id, now: now)
        #expect(matches.count == 1)
        #expect(matches.first?.walletID == second.id)
        #expect(matches.first?.cardName == "Everyday")
        #expect(WalletOfferQuery.matches(userCards: wallets, catalog: [card], walletID: "deleted", now: now).isEmpty)
        #expect(WalletOfferQuery.matches(userCards: wallets, catalog: [card], now: now).count == 2)
        let entity = SavedWalletCardEntity(wallet: second, catalog: [card])
        #expect(entity.id == second.id)
        #expect(entity.name == "Everyday")
        #expect(entity.id != card.id)
    }

    @Test func widgetOfferLinkOpensExactWalletRecordWithEscapedIdentifiers() throws {
        let card = card("Test")
        var wallet = UserCard(card: card)
        wallet.merchantOffers = [offer("shared &/?=é")]
        let payload = WidgetDataManager.makePayload(userCards: [wallet], allCards: [card], spendings: [], settings: .init(), asOf: now)
        let row = try #require(payload.walletSections?.first { $0.kind == .offers }?.rows.first)
        let url = try #require(row.url)
        let destination = try #require(WalletOfferDestination(url: url))
        #expect(destination.walletID == wallet.id)
        #expect(destination.offerID == "shared &/?=é")
    }

    @Test(arguments: ["cardwise://offers", "cardwise://offers?wallet=a", "cardwise://offers?wallet=&offer=b",
                      "cardwise://offers?wallet=a&offer=b&offer=c", "cardwise://offers?wallet=a&wallet=b&offer=c",
                      "https://offers?wallet=a&offer=b", "cardwise://cards?wallet=a&offer=b"])
    func invalidOfferDestinationsAreRejected(link: String) throws {
        let url = try #require(URL(string: link))
        #expect(WalletOfferDestination(url: url) == nil)
    }

    @Test func offerDeadlineUsesLastEligibleDayInEverySurface() throws {
        let card = card("Test")
        var wallet = UserCard(card: card)
        var offer = offer()
        offer.expiresAt = Calendar.current.startOfDay(for: now).addingTimeInterval(86400)
        wallet.merchantOffers = [offer]
        let actions = UpcomingActions.items(userCards: [wallet], catalog: [card], usages: [], spendings: [], now: now)
        let action = try #require(actions.first)
        #expect(action.displayDate == offer.expiresAt.addingTimeInterval(-1))
        let date = action.displayDate.formatted(date: .abbreviated, time: .omitted)
        #expect(WalletShortcutMessages.upcomingActions(actions).contains(date))
        let payload = WidgetDataManager.makePayload(userCards: [wallet], allCards: [card], spendings: [], settings: .init(), asOf: now)
        #expect(payload.walletSections?.first { $0.kind == .deadlines }?.rows.first?.value == date)
        let reset = UpcomingAction(id: "reset", walletID: wallet.id, cardName: card.name, title: "Credit", detail: "Resets",
                                   deadline: offer.expiresAt, kind: .credit("credit"))
        #expect(reset.displayDate == reset.deadline)
    }
}
