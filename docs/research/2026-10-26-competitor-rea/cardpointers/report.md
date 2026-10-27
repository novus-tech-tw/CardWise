# CardPointers REA analysis

Analysis date: October 26, 2026 (America/Phoenix). The evidence records were created on October 27 UTC. Scope: the publicly shipped Firefox extension and the unauthenticated legacy web app. This is not a reverse engineering report on the native iOS binary.

## Result

CardPointers competes through a combination of issuer-specific offer automation, synchronized wallet data, and recommendations embedded directly in shopping pages. The acquired extension provides substantially better evidence for those mechanisms than its marketing website alone. Its shopping recommendation function consumes merchant/category card lists, joins them to the user's wallet, filters by profile, and joins offers by IDs. The inspected function does not itself recalculate rewards from transaction history or sort competing reward rates. The upstream production of those lists remains unknown.

The extension's offer automation runs against the user's existing authenticated bank browser session. A separate, optional synchronization branch constructs an upload to the CardPointers service containing card objects and offer objects. Therefore, “no bank password sharing” should not be interpreted as “no wallet or offer data sent to CardPointers.” This report observed code paths, not bank-session execution or actual uploads.

## Targets and identity

The official [CardPointers homepage](https://cardpointers.com/) links to the [CardPointers X Mozilla listing](https://addons.mozilla.org/en-US/firefox/addon/cardpointers-x/). The Mozilla API and public download supplied:

| Field | Observed value |
|---|---|
| Name | CardPointers X: Credit Card Rewards Made Easy |
| Version | 8.0.8 |
| Release timestamp | 2026-10-07T20:38:51Z |
| Firefox extension ID | firefox@cardpointers.com |
| Public XPI URL | https://addons.mozilla.org/firefox/downloads/file/5096700/cardpointers_x-8.0.8.xpi |
| Download size | 792,134 bytes |
| XPI SHA-256 | `691c287f0c640e5c0cefd77fed49c3e9e6a4630ee0c8461a3e2fdf6022327af3` |
| Extracted REA root digest | `59d69c0a6510ef0801ab845ed4df64cb60ae01c97a67c297776c7ad98636e217` |
| content/content.js SHA-256 | `9accaf667dd92887e000021a9a53d938739ee7fcba93debbaab9e5a9612ea9b3` |
| background/background.js SHA-256 | `a361987443d6f27ff15e94aa31d8553cd06fb987fc9970b50b1deb5ce2d3fbdd` |

The downloaded XPI digest matches Mozilla's API hash. This checks acquisition integrity against that metadata; it is not an independent signature-verification claim. The extracted package has 26 ZIP entries including resources and signing-related metadata. The raw XPI and metadata are retained locally. It was never installed or executed.

## Evidence ledger

| Label | Evidence ID | Meaning |
|---|---|---|
| A | `ev_646b2b55acdcc2309c2e4d74586a4605c22ccb3fff6512deb64ec27303c225b2` | Original static JavaScript application analysis |
| S | `ev_45f3defc308517903c2d1e23fe23955f514ee59601323320e1b2c298cfa97548` | Summary projection of A |
| M | `ev_caa7c8ec83ac1fcfe0fc4fad642e50c632aa6b99b3069b4307429fd0379e8c92` | Complete module identity page: 12 module/asset roles |
| B | `ev_d71a41eecf391c3cfc43aa6b817037cbca4b625f53bba366bbeb742f34474777` | Background module identity/source range |
| C | `ev_992eb9e6c2afea37b1a0992af29b257126eea9b25ee1d43ca2fbf18093ec00dd` | Content module identity/source range |
| R | `ev_5200838f26189ed666376a78e752be39ee768ef094c700f8086a562efd2c0409` | Actual REA browser scenario on https://cardpointers.com/app/ |
| T | `ev_ca9a7e4a19c97e363a02c9cb59a44e3d007cac7e1d07ef8e57967b2771b4f243` | Literal refresh-route trace, no matched graph seed |

REA parsed six JavaScript files and nine relevant files, read 1,632,861 text bytes, visited 467,208 AST nodes, produced 35 findings, and reported zero parse failures. Application coverage is partial. Semantic coverage is partial and truncated at the default 20,000 nodes per source and 100,000 total nodes, with 94,717 semantic unknowns. The summary's complete-within-view marker describes the summary projection, not complete application analysis.

T did not match its literal seed in the retained application graph; this is explicitly not evidence of feature absence. The token refresh URL and its logic were independently read from the exact hashed input file.

Detailed business-logic observations below are manual source reading of the hashed REA inputs, anchored by A/B/C and [source-anchors.json](source-anchors.json). They must not be confused with automatically proved cross-function REA traces. The anchor file records exact character positions, line/column positions, snippet digests, and source digest. Nothing from those snippets was executed.

Exact source anchors in `extension/content/content.js` (zero-based character offsets; half-open intervals):

| Source path | Character interval | Start line:column (line is one-based; column zero-based) |
|---|---|---|
| Merchant/wallet/profile selection | 415201–416386 | 15:225632 |
| Current issuer card-array selection | 1074330–1074637 | 17:301251 |
| CardPointers wallet refresh | 1101474–1102029 | 17:328395 |
| Offer synchronization payload | 1122347–1124060 | 17:349268 |
| Amex offer fetch excerpt | 983431–985331 | 17:210352 |
| Chase v3 offer fetch excerpt | 1003395–1005195 | 17:230316 |
| Chase card decoration helper | 990634–991587 | 17:217555 |

## Findings

### 1. Extension architecture and local state — observed static declarations

The Manifest V3 package declares a background script, an action popup, and a content script injected at document_end on HTTP and HTTPS sites. Permissions include storage, unlimitedStorage, activeTab, scripting, and broad HTTP(S) host access. This is an access declaration needed for multi-merchant and issuer behavior; it does not establish misuse or transmission.

The content bundle uses Vue-style component state and Vuetify UI. chrome.storage.local is used for wallet cards, categories, merchants, offers, settings, profile_uuid, refresh timestamps, and CardPointers account state. The background includes an IndexedDB database named cp with a merchants object store keyed by domain, used by an explicit storage-workaround branch. It also brokers runtime messages for merchant lookup, API calls, badge changes and injected issuer requests. [A, B, C; extension/manifest.json]

### 2. Best-card display joins cached lists — observed code; upstream policy unknown

The inspected merchant-selection function receives merchant, categories, wallet cards, offers, category ID and profile UUID. It builds an inventory_id lookup, chooses merchant-specific card entries when available or a category fallback otherwise, filters entries by wallet/profile, and resolves merchant ci_ids into offer entries. It returns merchantName, shoppingCards and shoppingOffers. Input ordering is preserved in these paths.

The display code uses the first shopping card/offer as the leading choice and shows points, point value, total_value, and an offer brief. The exact merchant/category lists and valuation fields come from synchronized data. This supports the inference that the extension separates data preparation from in-page presentation. It does not prove where the upstream ranking is computed, that all data is server-ranked, how caps are handled upstream, or how native iOS ranks cards. [A, C; merchant-selection.txt; wallet-refresh.txt]

### 3. Bank offer adapters use the bank's session — observed code; not executed

The content bundle contains issuer-specific fetch and enrollment methods for Amex, Chase, Bank of America, Citi, Wells Fargo and US Bank. Amex and Chase requests visibly use credentials:include to bank endpoints. For example, Amex has multiple read strategies and fallback methods; Chase has v3, v2 and older offer API strategies. The source also handles issuer account discovery, activation/enrollment states and retries.

These paths are consistent with the [official extension description](https://cardpointers.com/extension/) that offer processing occurs when the user logs into the bank normally. This investigation did not supply bank credentials, attach to a user's bank page, activate any offer, or test endpoint availability. [A, C; amex-offer-fetch.txt; chase-offer-fetch.txt]

### 4. CardPointers synchronization is a separate data boundary — observed code

Inside addOffersCP, the syncOffers condition gates a request to the CardPointers base origin https://x.cardpointers.com. The route is constructed as `/api/v1/user/extension/offers/add` for an existing account, or `/api/v1/extension/offers/add` without that account token.

The body includes `bank_id`, `cards` and `offers`; single-card branches add `external_id` and `inventory_id`, and the unauthenticated branch can add `email`. Request parameters include `version`, `source`, `auto_add`, `all_cards`, `delay`, and an Amex-specific sync option. `cards` is assigned directly from currentBankCards, which selects the applicable issuer's bankProducts array. Offer objects are spread rather than reduced to a strict small metadata allowlist.

Important boundary: this static branch does not justify a claim that only public card names are synchronized. Card discovery objects can contain issuer identifiers and masked-card details; an older Chase helper also decorates bank-card objects with sourceCustomerId and securityToken fields. Whether that decorated state reaches a particular live upload is not established. No real token values or bank data were acquired. Backend behavior, retention and sanitization remain unknown. This is a data-boundary observation, not a finding of a confirmed exploit, actual leakage or malicious behavior. [A, C; offer-sync.txt; bank-card-selection.txt; chase-card-token-decoration.txt]

### 5. CardPointers account token is distinct from bank authentication — observed code

The background stores CardPointers account state under cp_token and reads JWT-style UUID/expiry fields. It implements an own-account refresh request to `/api/v1/user/token/refresh`, rotating the stored account token only when its identity/expiry checks pass. Refresh cooldowns and failure handling are present. This is not evidence that CardPointers stores the user's bank password. Bank session headers/cookies and CardPointers account authorization have different roles. [A, B; extension/background/background.js]

Wallet refresh uses `/api/v1/user/extension/wallet/`, receives cards/merchants/categories/offers, and caches them locally. Account checking also uses `/api/v1/user/me/`. These are static route observations only; no request was made directly to those services. [A, C; wallet-refresh.txt]

### 6. The interruption controls are a useful product detail — observed code

Shopping Pointers can be configured by frequency: per tab, minute, hour, day or every relevant page. Domain exclusions, a temporary hide interval, auto-dismiss duration, badge options and card/offer display modes are explicit source paths. The background cleans expired timed entries and removes per-tab history when a tab closes. This is a concrete example of controlling the annoyance cost of proactive recommendations. [A, B, C]

### 7. Monetization gates automation and richer shopping context — observed code

The shipped UI checks a pro flag or remaining trial days. It contains upgrade gates for automatic offer adding, bulk adding across cards, and showing richer shopping recommendations/details after trial expiry. It can open the public CardPointers upgrade page; a native-extension branch uses a CardPointers deep link. The Firefox artifact contains shared platform conditionals, which do not establish native iOS execution or StoreKit behavior.

The [current public pricing page](https://cardpointers.com/pro/) lists a free tier and Plus at US$99.99 per year. The package's trial-related UI is not a verified statement of current eligibility or billing terms. No checkout, trial, subscription or account creation occurred. [A, C; public pricing page]

### 8. Unauthenticated web app is gated — observed runtime

REA launched a fresh headless Chromium profile, navigated to https://cardpointers.com/app/, waited for body visibility and a 1.5-second settle window, and captured DOM/accessibility/network metadata. The final view presented Log In and Sign Up and said an account is required to start. It did not expose an anonymous demo wallet in that captured state.

Requests loaded Nuxt bundles, a Vue PayPal checkout script, PayPal scripts, HubSpot scripts/requests, Google Analytics and Facebook script resources. These observations apply only to the unauthenticated legacy web app. They do not prove native-app analytics, completed payment processing, or the extension's banking data flow. Network bodies and header values were not requested. REA confirmed termination of its owned browser process. [R; runtime-summary.json]

## Implications for CardWise

These are design judgments, not recovered competitor requirements. The baseline at CardWise commit 5f7b982 already includes manual credit usage, unused-credit aggregation, sign-up tracking, and home/lock-screen widgets.

1. **Fix and explain recommendation inputs before broadening features.** CardWise's cap-aware engine needs consistent spending input at every view/widget call site. The competitor extension demonstrates clear separation between prepared recommendation data and display. CardWise should also make a single correct ranking result available everywhere and explain remaining-cap, activation and sign-up priority decisions.
2. **Extend existing widgets and quick access with context.** A merchant/category picker or configurable widget category would improve the current fixed dining example. CardPointers' value comes partly from putting the answer at the purchase location, not merely owning more catalog entries.
3. **Make privacy precise.** CardWise can truthfully emphasize no CardWise account, no bank connection, and on-device/private iCloud data. Avoid a vague claim that all competitors require bank passwords: the CardPointers extension instead uses a bank session locally, with its own account synchronization boundary.
4. **Treat bank automation as a costly separate product decision.** Multiple issuer adapters, historical fallbacks, retry handling and card matching indicate ongoing maintenance work. Building this would expand CardWise's architecture and data boundaries. Manual benefit tracking is already implemented and can be improved independently.
5. **Offer explainable valuation and ranking.** The extension carries point value and percentage-value fields into its UI, but their upstream derivation was not recovered. CardWise can improve its common point valuation with user/program-specific assumptions and show why the recommended card won.
6. **Borrow restraint from frequency controls.** If proactive reminders or location features are pursued, use explicit frequency, exclusion and dismiss controls. These ideas can be adopted without copying code or reproducing an extension.

## Coverage checklist and remaining unknowns

| Question | Status | Boundary |
|---|---|---|
| Obtain authentic public shipped code | Answered | Mozilla-linked Firefox XPI, hash matched |
| Map extension components and local state | Answered within package | Static declarations and direct source reading |
| Trace basic merchant-to-wallet display selection | Partially answered | Consumer function recovered; upstream ranking unknown |
| Identify offer fetch/activation and sync boundaries | Partially answered | Source paths read; no bank session or upload observed |
| Observe unauthenticated public app | Answered within scenario | Login gate, resources and metadata only |
| Recover native iOS internals, SwiftUI, CloudKit or StoreKit | Unresolved | No iOS/Mac binary acquired or analyzed |
| Validate actual cap handling, point valuation or recommendation accuracy | Unresolved | No personalized wallet/runtime fixture |
| Validate paid automation, data retention and issuer reliability | Unresolved | No account, subscription or bank connection |

## Retained files

- [report.md](report.md): this report.
- [amo-metadata.json](amo-metadata.json): public listing and download identity.
- `cardpointers_x-8.0.8.xpi` (retained locally; see [archive index](../artifacts.md)) and extension/: exact acquired package and extracted contents.
- `rea-evidence.json` (retained locally; see [archive index](../artifacts.md)): portable complete REA session ledger (approximately 151 MB, seven records); the ledger preserves partial coverage.
- rea-summary.json, rea-modules.json, rea-background.json, rea-content.json: focused retained views.
- [runtime-summary.json](runtime-summary.json): concise runtime summary without request query values or body/header contents.
- [source-anchors.json](source-anchors.json): exact manually inspected source slices, identities and digests; associated .txt files are static excerpts.
- rea-trace-unmatched.json: explicit unmatched trace and its limitations.

No CardWise repository files were changed, and no tests or app builds were run. The investigation acquired public material, parsed it without installing the extension, and observed only a fresh unauthenticated browser session.
