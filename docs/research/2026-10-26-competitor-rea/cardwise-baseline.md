# CardWise source baseline

Inspected repository: `/Users/rich/Desktop/CardWise` at commit `5f7b9823e053924ee3d353e3198c88738f66af0d`. These are ordinary source observations, not REA evidence about a competitor. No source files were changed and no app was executed.

## Existing capabilities

- `CardWise/Services/RecommendationEngine.swift:67`: category recommendations calculate estimated reward, remaining caps, activation status, and sign-up bonus progress. Purchases exceeding the remaining cap are split between bonus and base rates. Sorting prioritizes an unfinished sign-up bonus before estimated reward.
- `CardWise/Models/CreditCard.swift:59`: statement credits already have a value and monthly/quarterly/semiannual/annual cadence. `CreditCard` already exposes annualized credit totals and nominal net annual fees.
- `CardWise/ViewModels/CardViewModel.swift:123`: manual statement-credit usage is saved by card, benefit, and period; unused credits are aggregated and sorted.
- `CardWise/Views/Cards/CardListView.swift:505`: statement-credit usage can already be edited in the card detail UI. A recommendation to add benefit tracking from scratch would be incorrect.
- `CardWise/Models/Merchant.swift:439`: merchant/category matching and autocomplete operate over a bundled local list.
- `CardWise/Services/NotificationService.swift:43`: local spending-cap notifications; the same file also schedules rotating-quarter reminders.
- `CardWise/Services/WidgetDataManager.swift:37` and `CardWiseWidget/CardWiseWidget.swift:283`: home-screen and lock-screen widgets already exist. This is not a missing feature category.
- `AGENTS.md` describes no CardWise-operated backend, on-device SwiftData with private CloudKit sync, a bundled catalog with remote refresh, and no banking-account connection.

## Concrete follow-up candidates found in inspected source

1. **Recommendation input consistency:** `RecommendView.swift:31`, the quick recommendation view in `HomeView.swift:509`, and `WidgetDataManager.swift:42` call the recommendation engine without passing spending records, although its API defaults to an empty spending list and uses that input for cap and sign-up calculations. This is a static integration observation, not a reproduced runtime defect; verify with a wallet with recorded spending near a cap before changing anything.
2. **Context at the widget:** `WidgetDataManager.swift:42` computes dining recommendations using a fixed $100 example and labels the payload Dining. A configurable category or merchant would be an extension of existing widgets, rather than a new widget project.
3. **Point valuation:** `RewardConstants.defaultPointsValueCPP` is `0.01`, and `calculateEstimatedReward` uses this common dollar-per-point value for non-cashback rewards. User/program-specific valuations and a clear explanation are potential improvements; competitor valuation behavior remains unknown until separately observed.
4. **Explain the ranking policy:** sign-up bonus priority can outrank immediate purchase reward. The engine behavior is visible in source; whether the UI explains this adequately requires a focused UX check.

## Search boundary

Focused reads covered the recommendation engine, credit-card models, merchant mapping, widget payload, recommendation views, manual credit-usage view/model, and notification service. A bounded search over `CardWise` and `CardWiseWidget` found no AppIntent/AppShortcut/ActivityKit/CoreLocation/MKLocalSearch matches. This is not a comprehensive architecture audit or proof that integrations cannot exist elsewhere. No tests were run because this task made no implementation changes.
