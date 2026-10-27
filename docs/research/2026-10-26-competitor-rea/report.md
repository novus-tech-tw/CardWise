# CardPointers and MaxRewards REA competitor analysis

Requested: 2026-10-26, America/Phoenix. REA timestamps can fall on 2026-10-27 UTC. Analysis uses REA 6.5.0. This report is a bounded public-artifact investigation, not a native iOS decompilation or an authenticated banking test.

## Decision

CardPointers is the closer comparison for a card-selection utility, and its publicly distributed extension exposes substantial offer-handling logic. MaxRewards' public flow demonstrates account infrastructure and a mobile-app handoff, while its bank connectors and reward computation remain outside the acquired evidence. CardWise can use this distinction to prioritize a quick and explainable purchase decision while keeping its current local-first architecture.

These are product recommendations, not measurements of retention, revenue, recommendation accuracy, or product-market fit.

## What was actually analyzed

| Product | Acquired material and execution | Evidence boundary |
| --- | --- | --- |
| CardPointers | Officially linked Mozilla distribution of CardPointers X 8.0.8; shipped JavaScript/static resources analyzed by REA; focused source anchors retained; fresh-browser observation of the unauthenticated legacy web app | Firefox extension implementation and legacy-web login gate. No claim that the same code implements native iOS recommendation or in-app offer sync |
| MaxRewards | Public product page, a declared fresh-browser scenario through Start Earning More to signup, and downloaded public web bundles; REA static analysis of seven selected business-relevant sources | Marketing and web onboarding. No native IPA/APK, authenticated wallet, or live banking connector |
| CardWise | Focused ordinary source inspection at commit `5f7b9823e053924ee3d353e3198c88738f66af0d` | Read-only source comparison; no app execution or test-based defect reproduction |

Detailed identity, Evidence IDs, source anchors, and limitations are in [CardPointers analysis](cardpointers/report.md), [MaxRewards analysis](maxrewards/report.md), and the [CardWise baseline](cardwise-baseline.md). Public acquired artifacts and exported REA Evidence are retained beside those reports.

| Evidence | Exact retained ID |
| --- | --- |
| CardPointers static parent | `ev_646b2b55acdcc2309c2e4d74586a4605c22ccb3fff6512deb64ec27303c225b2` |
| CardPointers public web scenario | `ev_5200838f26189ed666376a78e752be39ee768ef094c700f8086a562efd2c0409` |
| MaxRewards static parent | `ev_a1ab54ca0e29ba5922c67b4c0bf00f27dcfeae2b2aa23d0407e0b47c22c27584` |
| MaxRewards public web scenario | `ev_ea10ac8fd04e2f98a2eebf6f667e47d98d7beb2f1863021bfc1edd94cb37ba01` |

## Findings

### CardPointers: a bank-offer integration layer is visible in the extension

**Observed in shipped static code:** bank-specific offer retrieval/enrollment adapters, background messaging and request handling, local wallet/merchant/offer caches, CardPointers account-token handling, entitlement state, and calls to the CardPointers service. The AMO-distributed package is version 8.0.8; acquired XPI SHA-256 is `691c287f0c640e5c0cefd77fed49c3e9e6a4630ee0c8461a3e2fdf6022327af3`, matching the distribution metadata.

The source has bank requests that use the browser's existing bank session and a distinct CardPointers-account authorization path. A conditional offer-sync branch constructs a request to `x.cardpointers.com` with bank identity, card arrays, and offer data. Some branches add card identifiers or an email field. See the detailed report and its `offer-sync.txt`, bank-fetch, and wallet-refresh anchors.

**What this establishes:** substantial integration and synchronization code is shipped to the extension. It provides a concrete engineering basis for the advertised offer feature, beyond a marketing claim.

The inspected shopping-selection function joins prepared merchant/category card lists with the user's wallet/profile and offers, preserving their order in those paths. Its display consumer does not itself establish the upstream reward-ranking algorithm or transaction-cap accounting. The prepared data includes valuation fields, but their production remains unknown. The fresh-browser legacy web app presented a login/signup gate; this does not establish native-app onboarding behavior.

**What it does not establish:** no bank account was logged in, no offer was enrolled, and no banking or sync traffic was triggered in this investigation. Static branches do not prove runtime success, exact transmitted values, complete sanitization, server retention, or the absence of other data paths. Browser-session access is distinct from sending raw banking passwords to CardPointers. Broad extension permissions alone do not establish misuse.

**Inference for CardWise:** maintaining bank-specific integrations is a substantially broader product responsibility than maintaining a card rewards catalog. Adopt the useful interaction ideas independently: clear merchant matches, visible recommendation reasons, and convenient entry points. Treat automated bank offers as a separate architectural decision.

### MaxRewards: public account onboarding is concrete; banking internals remain unknown

**Observed at runtime:** a fresh-browser scenario opened the product page and clicked Start Earning More, arriving at signup with Google, Apple, and email choices. No user data was entered or submitted. Public session probes returned unauthenticated results; public navigation/card-list requests also appeared in the captured network records.

**Observed in acquired static code:** the public marketing page uses Webflow assets, while signup uses React/Next.js bundles. Focused first-party code shows an Ory registration stage, MaxRewards user provisioning, session-resume handling, and a mobile-download handoff. Firebase references in inspected code concern web-push functionality; they do not establish Firebase Auth or the native app's backend architecture.

**Inference for CardWise:** the inspected public flow introduces an account/setup step before the mobile handoff. CardWise can make its immediate, account-free experience visible. This does not establish that every MaxRewards feature or native-app entry route requires the same flow.

**Unknown:** native app implementation, banking-connector internals, how reward caps influence actual ranking, merchant classification accuracy, authenticated transaction handling, and the operational reliability of offer activation. The Webflow marketing stack is not evidence of a Webflow mobile app.

### Paid feature positioning comes from vendor documentation

CardPointers' current product page advertises CardPointers+ at **US$99.99/year**, with location-aware AutoPilot, offer synchronization, Apple platform integrations, and AI features. These are vendor descriptions, not capabilities all exercised here. [Official product/plan page](https://cardpointers.com/pro/).

MaxRewards' current public documentation lists a free Bronze tier with best-card recommendations and account information; Gold starts at **US$108/year**, adding offer/benefit and bonus tracking; Platinum starts at **US$240/year**, adding business-spend and receipt workflows. These are documented plans, not tested purchase entitlements. [Official app page](https://maxrewards.com/app), [official subscription tiers](https://help.maxrewards.com/en/articles/12747576-what-are-the-maxrewards-subscription-tiers).

**Inference:** free best-card recommendations already exist among competitors. CardWise's differentiation should combine price with fewer setup steps, private local data, useful explanations, and dependable handling of the user's recorded context.

## Priorities for CardWise

| Priority | Concrete work to evaluate | Why it follows from the evidence |
| --- | --- | --- |
| P0 | Verify that every recommendation entry point passes recorded spending to the cap-aware engine | The engine accepts spending, but the inspected recommendation view, quick recommendation view, and widget call sites omit it and use the empty default. Static observation warrants a focused cap/bonus scenario before implementation |
| P1 | Make existing widgets contextual: selected category or merchant, concise reason, and relevant cap/activation state | CardWise already has widgets; the current payload computes a fixed Dining/$100 example. Improve the existing fast path rather than building a duplicate widget feature |
| P1 | Explain ranking and value assumptions | CardWise prioritizes an unfinished sign-up bonus before estimated purchase reward and uses a common $0.01 value per point/mile. Users should understand why a card wins; configurable valuations are a possible follow-up |
| P2 | Improve the existing manual benefit workflow and reminders based on observed user need | Manual statement-credit usage, unused-credit totals, and cadence are already implemented. Competitors emphasize automation and convenience, so presence of a tracker alone is not differentiation |
| Separate product decision | Bank-linked offer activation or account aggregation | The extension shows bank-specific integration work; MaxRewards documents a connected-account product. Adding these would expand CardWise's current architecture and maintenance scope |

The P0 observation is not a repaired or runtime-reproduced defect. No implementation changes were requested or made.

## Coverage checklist

| Original investigation question | Status |
| --- | --- |
| Resolve official public target/artifact identity | Answered for CardPointers extension and MaxRewards public web surfaces |
| Run actual REA analysis | Answered: shipped JavaScript and browser-scenario Evidence retained |
| Trace public offer/account data boundaries | Partially answered: static extension branches and web account flow; no authenticated banking execution |
| Explain mobile recommendation internals | Unresolved: no native mobile artifacts or authenticated flow acquired |
| Verify paid-feature operation | Unresolved: official plan descriptions only |
| Identify grounded CardWise priorities | Answered as analyst recommendations, with source-based verification candidates |

## Reuse and verification

- Use the exact package/hash and Evidence IDs in each detailed report when comparing a later version. A future website build or extension update is a different target.
- Both static analyses explicitly preserve incomplete semantic coverage. A successful parse and a complete summary view do not mean a complete application graph.
- Source text, symbols, strings, and route names are observations of public shipped material; they do not prove execution, backend behavior, vulnerabilities, or authorization weaknesses.
- The CardWise Git checkout remains unchanged. No app tests were needed for this analysis-only task; no claims are made about build/test pass status.
