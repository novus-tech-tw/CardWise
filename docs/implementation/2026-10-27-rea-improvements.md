# REA follow-through: recommendation consistency and context

This implements every P0–P2 follow-up in the [completed competitor investigation](https://github.com/novus-tech-tw/CardWise/pull/81) that fits CardWise's existing local-first product. Competitor observations informed the requirements; CardWise's rules are an independent implementation, not a claim to reproduce hidden competitor ranking formulas.

| Investigation follow-up | Delivered behavior |
| --- | --- |
| P0: pass recorded spending at every recommendation entry | Recommend, Quick Recommend, manual spending, receipt scanning, widgets, and saved purchase rewards use the same cap-aware engine and recorded spending. Backdated purchases use the selected transaction date. |
| P1: explicit point values and ranking | Settings → Ranking, Point Values & Widgets offers sign-up-first or highest-purchase-reward ordering and per-card cents-per-point estimates. The existing sign-up-first default is preserved. Cash percentages ignore point valuations. |
| P1: distinguish eligibility states | Recommendation explanations separately describe missing activation, unpublished current-quarter schedules, saved or unselected categories, shared cap balances, reset dates, partial purchase splits, point values, and sign-up priority. |
| P1: context in existing widgets | Home and Lock Screen widgets use a selected category or recognized merchant and purchase amount, the same recorded spending and valuation policy, and display the purchase context and estimated reward. |
| P2: benefit/reset/progress polish | Statement credits show fractional usage, remaining value, progress, and reset dates. Home benefits are ordered by actual reset date and link to their editor. Card details accept a user-entered sign-up offer when the catalog has none and provide sign-up start dates, deadlines, recorded progress, remaining spend, and manual award confirmation. |

## Calculation rules and compatibility

- A single cap ledger is shared by the recommendation engine and spending-cap dashboard/alerts. Rotating categories share their published cap; selected categories share their configuration's cap. Broad-category caps include locally mapped subcategories without counting one transaction twice.
- Period spending includes records from the period start through the evaluation instant. Future records do not use today's cap. Sign-up spending is bounded by the inclusive start and exclusive deadline and by the evaluation instant. A goal with less than a day left remains eligible; a future goal does not receive priority.
- Only the published current year/quarter schedule is eligible. A previous year's schedule is not silently reused. If fixed and eligible rotating or selected bonuses overlap, compare their actual estimated purchase values after caps.
- Catalog rate notes are preserved, and duplicate category rows have distinct identities. Restricted travel/hotel/airline/dining/wholesale notes require an explicit per-purchase special-rate assumption; ordinary category-description notes do not. The same assumption is used when recording a purchase, and widget assumptions are separately configurable. Issuer conditions not represented by catalog notes remain unknown.
- Unactivated rotating bonuses do not earn their advertised bonus. Users confirm activation with the issuer before recording it in CardWise. Category changes also remain manual issuer actions; clearing a saved choice now persists.
- Spending records use the same reward calculation as recommendations. Missed rewards always compare immediate purchase rewards, independently of sign-up priority, and cannot be negative. Saved historical rewards are not rewritten when preferences change.
- Point values default to 1 cent and must be finite, greater than zero, and no more than 100 cents. Preferences are stored on the current device and are included in Clear All Data. An optional custom sign-up offer extends the wallet JSON payload and decodes old wallets with no migration. SwiftData entities and CloudKit schema are unchanged.
- The app and widget compile the same `Shared/WidgetPayload.swift` contract. Context fields are optional for legacy decoding. Saved recommendations expire at the next day or an earlier sign-up deadline; the widget schedules an expiry entry and asks the user to open CardWise to refresh. Wallet, spending, preferences, catalog reload, and foreground/background transitions refresh the payload. Widget refresh timing remains controlled by iOS.
- Local merchant categories, manually recorded purchases, selected categories, and published catalog offers are estimates/input assumptions. The UI does not infer pending transactions or assert that a spending threshold guarantees an issuer award.

## Scope boundaries

Automatic bank connections, bank-session adapters, offer enrollment, account services, server-side merchant ranking, geolocation, Live Activities, and the competitor's complete Shortcuts catalog are not part of the investigation's P0–P2 implementation recommendations. They remain separate product/platform decisions. This change adds no network endpoint, account, banking integration, dependency, entitlement, or CloudKit schema change. Release versions and publication settings are unchanged.

## Verification

- Full `CardWise` simulator test suite, including `RecommendationIntegrationTests` and `RewardPolicyTests`.
- Regression fixtures cover exhausted/partial/shared caps, broad-category usage, future records, expired schedules, activation, overlapping bonuses, point/cash comparison, ranking policy, exclusive sign-up deadlines, invalid inputs, settings persistence/reset, manual sign-up offers and legacy wallet decoding, conditional rate opt-in, benefit reset boundaries, legacy widget decoding, and widget/engine consistency.
- SwiftLint: no new warnings; existing unrelated warnings remain.
- Release build for generic iOS, unsigned.
- Simulator UI inspection of settings and benefit/recommendation workflows using synthetic data only.

The branch is delivered through a PR. Merging to `main` triggers the repository's automatic app release, so merge and App Store review remain separate actions.
