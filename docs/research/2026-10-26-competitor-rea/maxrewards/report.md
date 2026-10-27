# MaxRewards: offline competitor investigation

## Outcome

This investigation now has genuine shipped product evidence: the official Firefox extension **0.1.7**, its public provider configuration catalog, and the official iOS/iPadOS application **4.8.35, build 1792099341**, obtained by the parent session from the Mac App Store. REA inspected the website, JavaScript, native package, property lists, signature, Mach-O and a signed-out native window. A pinned supplementary Hermes parser disassembled selected functions from the app's unencrypted business-bytecode resource.

The most useful findings for CardWise are:

1. The extension's online merchant recommendation is an authenticated server query, followed by session-owner checks, per-domain caching and presentation. This is directly supported by shipped extension code, rather than marketing claims.
2. The native client contains explicit cash/points conversion and a custom-valuation fallback chain. The observed functions do not establish the complete recommendation algorithm, but they explain a concrete part of the displayed return.
3. Bank connection is a substantial subsystem: a generic extension interpreter consumes remotely served provider descriptors, coordinates authentication/scraping state, and sends captured session material to MaxRewards' backend. None of these bank operations was executed.
4. MaxRewards has several native distribution surfaces—category widget, lock widget and Live Activity—alongside a React Native/Expo/Hermes main app. A dependency's presence is kept separate from proof of its runtime use.
5. A public, signed-out two-year card-value calculator was actually exercised with synthetic inputs. Personalized wallet/account routes were login-gated, but it would be wrong to say all useful MaxRewards functionality requires an account.

At the user's direction, the final pass is **fully offline and unattended**. No further launch, login, bank connection, account changes or UI intervention is needed to complete this artifact-based scope. Authenticated server and runtime questions are stated limits, not pending requests for the user.

## Evidence and target identity

| Target | Identity | Evidence basis |
|---|---|---|
| Public web corpus | 38 saved JS files, 2,987,794 bytes; corpus SHA-256 `e22363f5777192a31f64604afa9bbc18f15b4fcf251be43ca819aa07a4e1f217` | URL/file/digest manifest; 17 business/inline files REA-parsed in selected passes, 21 SDK/shared files separately inventoried. |
| Firefox extension | Official AMO distribution 0.1.7; XPI 578,507 bytes; SHA-256 `5a8866b7c1760bddf125564249bc174548db4264e3a28c62ff0f6be856bd0c4b` | Digest matches Mozilla's published file hash. Extracted corpus has 26 files; nine JS files were parsed by REA. |
| Provider descriptors | Public Connect catalog plus all 74 listed provider JSON descriptors; descriptor bodies total 170,203 bytes | Exact URLs, HTTP 200 statuses and individual digests retained. No provider instructions were executed. |
| Native executable | `com.max.MaxRewards`, 4.8.35 / 1792099341, arm64; SHA-256 `c709cbcb5dc95907dac5de166014ca8149b5ab697deb8d421092301b1aac1122` | REA plist/signature/Mach-O. Apple application-signing chain and team identifier recorded. |
| Native business carrier | `main.jsbundle`, Hermes bytecode version 96, 12,633,156 bytes; SHA-256 `efe8a8901364e9a633d0edb1810687f18932ebaf306995c235fccaef23278ba9` | Native artifact inventory plus a pinned, source-only offline Hermes parser. |

Public identity links: [product](https://maxrewards.com/app), [Firefox extension](https://addons.mozilla.org/en-US/firefox/addon/maxrewards/), [iOS app](https://apps.apple.com/us/app/maxrewards-rewards-cashback/id1435710443), [Android listing](https://play.google.com/store/apps/details?id=com.maxrewards). The Android link is identity evidence only; this worker did not acquire or inspect an APK.

The compact `evidence-index.json`, `native/provenance.json`, `corpus-classification.json` and `extension-source-anchors.json` preserve reproducible anchors. Raw packages, vendor source, full pseudocode/disassembly, private runtime material and large Evidence bundles stay outside the repository.

## Web application boundaries

The public product page uses Webflow metadata/assets and dynamically loads MaxRewards' component bundle. Signup/login use first-party Next.js/Turbopack resources with React component code. This establishes the **web** layering only; the native stack is established separately by its own package and bytecode. [W1, W2, W3]

The account client distinguishes identity creation, product-user provisioning, existing-user recovery, and a mobile download handoff. Native auth disassembly also exposes a shared authentication hook and a login screen consuming it; it reads an access-token key through the application's storage wrapper and invokes user/initial-data actions. These are static call/field observations, not verification of token security or a successful login. [W2; native functions 20054 and 34977]

A business-related web chunk contains 71 callable API-wrapper definitions spanning cards, categories, valuations, offers, benefits, transactions, account sync and membership. The exact wrappers and offsets are in `route-and-api-inventory.json`. They use a credentialed `/max-api` client and GraphQL-shaped request bodies. This is a client contract inventory—not a server schema or evidence that every method is currently available to every account. [W3, `1-239ln8xig0a.js`, approximately offsets 39,500–58,500]

Relevant static seams include user valuation changes; category reward queries; selectable-category updates; paginated offers; offer saving; manual benefit-tracker changes; monthly credit trackers; subscription setup/finalization; and AI card-story feedback. No mutation was sent by the investigator. A wrapper or operation name alone does not establish correctness, entitlement or server-side enforcement.

The 21 remaining SDK/shared files were deliberately not turned into claims about product functionality. Their bounded inventory identifies React/Next.js, query-cache, Zod, animation, floating-UI, analytics and experimentation candidates, plus unresolved shared helpers. An animation property named amplitude is explicitly not treated as an analytics SDK. Exact package versions remain unknown unless independently established.

## Genuine extension architecture

The Firefox manifest declares background, popup and content-script components; cookies, storage, scripting and alarms permissions; broad HTTP(S) host matching; and narrower MaxRewards-page bridges. These are manifest facts, not evidence of actual access to every site. [E1, package `manifest.json`]

### Merchant recommendation path

Shipped background code implements this static path:

1. A popup request uses the active tab's hostname; an in-page request supplies the current hostname.
2. The background resolves a MaxRewards session and checks that its owner has not changed.
3. It requests `getBestCardsOnline` for that domain from MaxRewards' backend.
4. It rechecks session identity before updating per-domain results and relevant user state.
5. The popup renders returned cards; the in-page component uses the first returned card.

The response query includes rate, valuation, multiplier, reason, spend-to-date, spend limit and offer fields. The client **does not thereby reveal how the server chose the best rate or mapped the merchant**. No authenticated recommendation request was replayed. [E2; `background.js`, approximately offsets 13,495–14,650 and 67,700–68,500]

The popup has separate card/offer/cap presentation paths. Its cap presentation computes a clamped progress percentage from returned spend and limit values. The in-page effective-rate display multiplies returned rate by valuation; the native client has a related but more explicit cash/points distinction described below. These are source observations, not an end-to-end cap-accounting test. [E1/E2; popup approximately offsets 213,200–215,600; content script approximately 209,550–210,600]

### Connection and synchronization are remotely configured

The background retrieves provider descriptors from the official Connect distribution service and registers bank content scripts for the descriptor's matching sites. Its generic bank script interprets declarative authentication/progress/scraping configuration. The background contains queued connection/resync work, timeouts, cancellation, account-owner checks, user-attention states and periodic resync eligibility checks. [E2; `background.js`, approximately offsets 28,200–65,900]

The acquired catalog lists 74 providers, including retail-card variants. Every acquired descriptor declares session-token capture; two include client-side scraping configuration: American Express and Navy Federal Credit Union. The Bilt descriptor requires extension 0.1.8, newer than the acquired 0.1.7. **The catalog count is not a count of working, compatible connectors.** [P1; `connect-descriptor-summary.json`]

The American Express descriptor defines offer discovery, subscription/preference gating, batching, a primary enrollment request, fallback enrollment and result normalization. Matching parsers/interpreter branches occur in the shipped generic bank script. This supports a static implementation finding for offer automation. No issuer page, discovery request, enrollment or fallback was executed, and no claim is made that it currently succeeds for a real account. [E2 + P1]

The background also contains account-scoped encrypted local credential storage using a generated AES-GCM key and an IndexedDB key store, with a fresh IV and owner/provider-associated data. Separate source branches package captured bank session material for a MaxRewards backend login/sync endpoint. These are implementation observations. They are not a security audit, a statement that secrets cannot be recovered, or proof of backend retention policy. No real credentials, cookies or stored account containers were read. [E2; background approximately offsets 14,950–17,700 and 31,800–38,100]

### Trace quality

REA source-node selection was based on returned module IDs, not invented names. Property-based semantic tracing found retained nodes, but the `bestCards` receiver remained unresolved in a narrow forward trace. That trace is explicitly ambiguous. The pipeline above is supported by the digest-bound source reading and REA-parsed modules; it is not misrepresented as a complete recovered interprocedural graph. [T1]

## Official native package and Hermes analysis

REA inventoried 1,078 files and 456 directories in the native app, with no integrity contradictions reported. The plist identifies React Native new architecture and Expo routing. Framework/package evidence includes React and Hermes. App extensions include category recommendations, a lock widget, a Live Activity and a notification service. Capabilities and packaged SDK resources establish integrations available to the build, not that a particular feature ran or transmitted data. [N1–N4]

The native executable's `LC_ENCRYPTION_INFO_64` reports `cryptid=1`, with a 4,096-byte encrypted region. No FairPlay decryption, patching or bypass was attempted. Its separate `main.jsbundle` is a readable Hermes-format bytecode carrier, so offline analysis of that resource does not require decrypting the executable. [N4]

The supplementary parser is **P1sec/hermes-dec 0.1.8 source at commit `2e796663e1fedb93dca51060797ebf3327b3fedb`**, acquired from its [upstream repository](https://github.com/P1sec/hermes-dec). It parsed HBC version 96, 68,786 function headers and 72,616 string entries. This worker produced targeted disassembly and pseudocode for 17 entry functions across reward presentation, auth and data initialization; nested closures are included where emitted by the tool. Per-function byte offsets, lengths and output digests are retained. This is a **supplementary offline analyzer**, not a claim that REA has a native Hermes decompiler.

Pseudocode is a fallible reconstruction. Several emitted expressions retain unresolved lexical environments or register expressions; no fallback marker in the output does not prove semantic equivalence. Conclusions below are intentionally narrow and anchored to matching disassembly/property/arithmetic operations.

### Concrete return-conversion functions

| Function | Carrier byte offset / size | Bounded finding |
|---|---|---|
| 27688, `getBestCardPercentage` | 6,712,695 / 62 bytes | Points branch multiplies best rate, point value and 100. Cash branch multiplies best rate, 100 and an optional multiplier defaulting to 1. |
| 61110, `bestCardPercentage` | 10,922,625 / 318 bytes | Resolves a custom currency before ordinary card currency; uses a matching user valuation with a result-value fallback; accepts a rate override before returned best/base rates. Cash uses a card multiplier defaulting to 1. A captured formatting callable remains unresolved. |
| 67344, `sortBestCardRewardsRows` | 12,301,834 / 116 bytes | Compares displayed percentage descending; on equal percentages, progress rows are preferred, then type-name comparison is used. The [focused followup](../followup/maxrewards-report.md) binds this to within-card reward-row sorting from `BestCardRewardsScreen`; not wallet-card or merchant ranking. |
| 28785, `getBestCardLiveActivitySpendLabel` | 6,808,617 / 85 bytes | Formats a spend-limit-related label for the Live Activity payload; not an accounting ledger. |
| 30443, `buildBestCardMerchantWidgetDeepLink` | 6,958,902 / 138 bytes | Constructs merchant-widget navigation data; not evidence of a location search being run. |

These functions explain parts of conversion/presentation. They do not independently prove complete cap accounting, quarter activation, signup-bonus weighting, server ranking or merchant categorization. An independently assigned additional audit of those native decision paths is under `native-recommendation-review/` and should be read separately.

### Data initialization and storage

The auth hook statically consumes user-query, token-clearing and initial-data callbacks. The initial-data hook requires a critical-data synchronization callable, then dispatches secondary category, benefit, next-card, redemption and offer requests using a settled-promise aggregation pattern. This is evidence of layered client data orchestration and partial-failure handling. It is not proof of an offline-first product or a complete synchronization contract. [native functions 20054, 33406 and 33472]

The typed storage wrappers call an environment-provided `getString`/`set` interface and log failures. The [focused followup](../followup/maxrewards-report.md) resolves their shared slot 23 to a constructed shipped MMKV class through modules 1485, 1486 and 1487. The app call supplies no configuration argument; the constructor defaults to `id: 'mmkv.default'` and has ordinary native and separate mock branches. This establishes a static provider binding, not device-file contents, native at-rest protection, Keychain usage elsewhere or a complete token lifecycle. No application data container, stored token or user database was opened. [native functions 16155 and 16158; followup MRF-02]

The app-level privacy manifest declares tracking false and lists required-reason API categories. Individual packaged SDKs have their own manifests and the application requests tracking/location-related permissions in its plist. These declarations are kept as declarations; this investigation does not infer observed collection or compliance from them. [N2, N5]

## Earlier controlled runtime evidence

The following runs were completed before the user's final offline-only steering. They are preserved evidence, not a request for more interaction.

- Product CTA to signup: Google, Apple and email registration choices were visible; no form was submitted. Session-check responses were 401 while signed out, while public component/card-list seams returned 200. [W1]
- Login, recovery, download, extension login, terms/privacy and Platinum were observed. Recovery navigated to the separate access-domain UI. `/my/accounts` redirected to login while preserving the intended destination. [R2]
- The card directory rendered 780 cards at observation time. Membership and website-best-card routes redirected to login. This is a UI observation, not verification that all 780 cards are accurate or available. [R3]
- A public card-value planner was tested with **synthetic** annual everyday spend of $10,000 and a selected $300 annual travel credit. It displayed $290 annual spend rewards and a $4,690 two-year estimate, reconciling to $4,300 welcome value + $580 spend rewards + $600 selected credits − $790 fees. No account, application or purchase was submitted. All declared actions completed and the owned browser was terminated. The numbers are an observed planner fixture, not current card advice or the user's finances. [R4]
- The exact native welcome window was passively captured after binding its true translocated executable. It was signed out. The native click provider rejected the planned action before execution because window geometry was ambiguous. A later passive attempt timed out and a process check found no live target. Neither event supports any claim about a logged-in wallet. These provider limits do not prevent the completed offline analysis. [U1/U2]

An initial calculator selector wrongly assumed a DOM button; the rendered control was an anchor with button semantics. Its failed result was retained. Two broad capture attempts timed out during cleanup, retaining partial observations. The calculator verification used a corrected direct route, exact input roles and reduced capture scope; only its successful canonical Evidence is used for the numerical finding. No repeated setup or OS-permission changes were made.

## Implications for CardWise

These recommendations are analyst judgments using the CardWise source baseline at commit `5f7b9823e053924ee3d353e3198c88738f66af0d`:

1. **Prioritize recommendation consistency across views and widgets.** CardWise's cap-aware engine already exists, but inspected callers omit spending records. Verify the near-cap scenario across all entry points before adding more features.
2. **Make valuation explicit and configurable.** MaxRewards' native conversion functions use currency/user valuation and cash multipliers. CardWise's baseline uses a common points value; program/user valuation and an explanation could improve trust without introducing bank sync.
3. **Extend existing widgets with context.** CardWise already has home/lock widgets. A configurable merchant/category is a smaller, relevant extension than treating widgets as absent. Live Activity/location behavior would be an additional product decision.
4. **Polish the benefit tracking that already exists.** CardWise already tracks manual statement-credit usage and unused credits. Clear reset dates and remaining usable value are useful improvements. Do not propose adding this category from scratch.
5. **Keep the data-model distinction concrete.** MaxRewards' server recommendations, accounts, provider descriptors and credential/session orchestration form an ongoing service subsystem. CardWise's account-free local/CloudKit architecture can support a simpler first result, while adding automatic bank connection would be a major architectural change.
6. **Consider an optional transparent value planner.** The verified public calculator shows one way to explain fees, selected usable benefits and welcome assumptions. It should be presented as an estimate with visible inputs, and should account for CardWise's current signup-priority policy rather than silently mixing immediate rewards with long-term value.

## Offline completion matrix

| Scope | Completed coverage | Explicit limit |
|---|---|---|
| Web | All 38 acquired files classified; 17 business/inline sources REA-parsed; 21 shared/SDK files separately inventoried | Shared/SDK implementations were not exhaustively semantically audited. Updated business and supplementary passes have no semantic truncation, but dynamic and unselected relationships remain partial. |
| Firefox extension | All nine shipped JS files parsed with zero syntax failures; six core JS files plus manifest/popup received a focused pass without semantic truncation | Broad graph reached resource ceilings; three UI-heavy JS files are outside the focused core pass. No extension installation/execution. |
| Provider configuration | All 74 listed descriptors acquired, parsed and hash-verified | Declarative behavior only. No bank page/request executed; one provider requires a newer extension version. |
| Native package | 1,078 files / 456 directories inventoried; app identity, signature, plist, privacy manifest, Mach-O commands and integration resources inspected | Native executable cryptid=1; no native decryption. Imported/exported symbol inventories are not exhaustive. |
| Hermes resource | Entire 12,633,156-byte carrier parsed: 68,786 function headers and 72,616 strings; 17 focused entry functions disassembled/decompiled, with output hashes | Targeted static decoding, not whole-program decompilation or execution. Unresolved environments remain explicit. Independent recommendation-path audit is documented separately. |
| Earlier runtime | Public auth/product/account gates, one synthetic calculator fixture and a signed-out native welcome captured | No authenticated wallet claim. Historical provider failures are preserved; no further runtime work or user intervention remains in scope. |

## Completion and limits

The authorized offline evidence acquisition, module classification, extension-core review, provider-config review, native package inspection, targeted bytecode analysis and sanitized documentation are complete. The remaining native recommendation audit is independently scoped and documented in its own subtree.

The broad extension pass encountered worker/result budgets. A selected core pass and the updated web-business pass have `semantic.truncated=false`, but still report dynamic-resolution and unselected-scope unknowns. The SDK/shared inventory is not a complete semantic audit. Turbopack wrappers were not reconstructed into original source modules.

No available artifact reveals the live server implementation, account-specific entitlements, issuer uptime, backend retention behavior or the current results of actual bank offer activation. No authenticated financial transaction or account mutation was performed. These are explicit boundaries of an unattended offline competitor analysis; they do not require another login, device or permissions request.

## Selected Evidence IDs

| Label | Evidence ID |
|---|---|
| W1, product-to-signup runtime | `ev_ea10ac8fd04e2f98a2eebf6f667e47d98d7beb2f1863021bfc1edd94cb37ba01` |
| W2, updated seven-source web business parent | `ev_60c99d921a4b12ae853443674e1fb310eb14582fc2c27cc3b34356f479fcd078` |
| W3, ten-source supplementary web parent | `ev_d1878e7ea9adf13bb4dc11ad80696b4d96b3401219201f39c40e948eadc45f60` |
| E1, complete extension source parse, resource-limited graph | `ev_2044e4d5646a96a4e4f43c5137a7a24546b7a04be6b68e45ff4f9c0ea3cda514` |
| E2, selected extension core parent | `ev_4489deb9a5d9177945f4a467e17bc8ccb83e8c9f9c47cebdabfe5923194a8728` |
| T1, narrow ambiguous property trace | `ev_70012eb67bc4206fea0c64606519c77bcc0ff2111818b8b50c2d801e2368ef8f` |
| R2, public login/recovery/account/legal routes | `ev_9360824fda9ef57527f484d62c441d240d96cb8f61f78ea7aa6c2d367105ee58` |
| R3, public directory and account gates | `ev_25e47440418eda73e6fa80912bb4458be0c912645519e9b49bf4716997a438c4` |
| R4, synthetic public planner verification | `ev_763929fb25bfe1dc8dc51cc391659cf9502b9907164253a993bba1e80790824f` |
| N1, native artifact inspection parent | `ev_5f183e69c10e069f64ed18f69c51596ebf11f77a4320517f0856751ecc96e4e2` |
| N2, native Info.plist | `ev_4ea36514a943545cea3ce55258237f688aafafacc0e1307018111f11cc9c352f` |
| N3, native signature | `ev_1c5d330492a0fe39861798461c5f6d05184f75dc1e835fd9d4bdb6ff60d4555c` |
| N4, native Mach-O inspection parent | `ev_d4c4152c3e50fb513c3b63114a9ad2147331c9c3d4abe2f154476757f3db7667` |
| N5, native app privacy manifest | `ev_5706c35aced340639718af47051bbc10d22acfe090514c0b8c347ff68b579fff` |
| U1, native AX observation | `ev_e94889b514afaeeeb74988a059bfeb04a1b08161872817986ea476de4c102f14` |
| U2, native signed-out window screenshot | `ev_a3e02bebf8b845afe5fd96983ffe093acf0704c59e9efcdd3eb33fa7ca639a4d` |

P1 is separate digest-bound HTTP acquisition, and the Hermes outputs are separate tool-derived evidence; neither is assigned a fabricated REA Evidence ID.
