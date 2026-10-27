# CardPointers and MaxRewards offline REA

Status: **completed reachable investigation and iPad followup**, delivered through [PR #81](https://github.com/novus-tech-tw/CardWise/pull/81). Selected static work is finished, both iPad app logins were confirmed, and owned device windows/controllers are released. The [progress ledger](progress.md) and [completion checklist](followup/completion-checklist.md) distinguish completed evidence from unavailable runtime paths explicitly skipped under the user's instruction. No further user setup is requested.

## Main findings

The [2026-10-27 followup](followup/README.md) resolves three previously open static bindings using existing artifacts. Both target apps are installed on the iPad and authenticated landing views were observed after the user completed login. Final exact-bundle inventory requests timed out, and Frida process discovery on 27.2 returned a connection-refused provider error; no attachment was attempted without a current PID. Deeper runtime behavior and reliable input remain unverified and are explicitly skipped. Mac artifacts are not substituted for the iPad packages.

CardPointers combines prepared shopping-card recommendations with bank-specific offer enrollment and native Apple integrations. MaxRewards combines server-returned merchant recommendations with client valuation/eligibility logic and remotely configured bank connection. Both expose substantially more integration work than a card-rate catalog alone.

For CardWise, the strongest near-term opportunities are consistent cap-aware inputs, configurable point valuations, explicit eligibility/ranking explanations and context in the existing widgets. Automatically connecting banks would be a separate product and architecture decision. These are analyst judgments grounded in the evidence below, not measured revenue, retention or recommendation accuracy.

## Exact acquired targets

| Target | Selected distribution | Actual analysis |
| --- | --- | --- |
| CardPointers X | Official Firefox 8.0.8; XPI SHA-256 `691c287f0c640e5c0cefd77fed49c3e9e6a4630ee0c8461a3e2fdf6022327af3` | Six original JS source families, all 344 content factories through source-bound partitions, popup/vendor/helper scopes; resource omissions resolved in final bounded passes |
| CardPointers Mac | Official Mac App Store 8.1.4/build 20261019; main universal Mach-O SHA-256 `e5e4947e7c6dd288b50f3b84a26efd7f7df8f20e1b2a0c8f573063ea80c09afa` | Package/signature/plist/dispatch, three extensions, Core Data model, compiled App Intents and selected main/Safari native function paths completed |
| MaxRewards Firefox | Official 0.1.7; XPI SHA-256 `5a8866b7c1760bddf125564249bc174548db4264e3a28c62ff0f6be856bd0c4b` | All nine shipped JS files parsed, focused six-source core reanalysis without resource truncation, plus all 74 acquired public provider descriptors |
| MaxRewards native | Official iPhone/iPad-compatible 4.8.35/build 1792099341; bundle `com.max.MaxRewards` | REA inventory of 1,078 files/456 directories, metadata and encrypted-Mach-O boundary; separate Hermes v96 business resource parsed offline |
| MaxRewards web | 38 acquired files, exact URL/digest manifest | 17 business/inline files REA-parsed; 21 SDK/shared files inventoried, not claimed as fully semantically audited |

The MaxRewards Hermes resource contains 68,786 function headers and 72,616 strings. Its main workstream reviewed 17 focused entry functions; an independent review disassembled 100 additional selected functions after exhaustive bounded instruction/identifier searches. Root checked the manifests and found no overlapping function IDs: 117 selected entries in total. This is not a semantic audit of every app function. Pseudocode is reconstructed output, not original source.

The selected CardPointers Mac build is distinct from the iOS version advertised by the storefront. Its Safari web manifest is 8.1.3 while the host/extension plists are 8.1.4. No silent same-version comparison is made.

## CardPointers: shopping order and offer-enrollment priority are different

The Firefox shopping consumer joins prepared merchant/category lists with the wallet/profile and offers, preserving incoming order in those paths. Its use of provided values does not reveal the entire upstream ranking or transaction-cap calculation.

A different helper implements **Amex offer-enrollment allocation**: normalize category aliases, compare applicable category value with base value, prefer the higher category bonus, then break ties with manual inventory priority and original candidate order. Enrollment strategies include fallback modes and issuer-specific state checks. This local algorithm must not be presented as the general shopping recommendation algorithm.

Bank requests use the browser's bank session; own-account synchronization is a separate boundary. A conditional sync branch constructs card/offer objects for the CardPointers service. No bank session, real credential, enrollment or upload was executed, and neither broad permissions nor object-field names establish a confirmed leak.

The native Mac package adds concrete domain evidence: 24 Core Data entities, all 637 archived model objects decoded, including pointer values/order, selected bonus plans/categories, profiles, credit offers and offer-sync accounts/cards/history. Tier fields such as `boaTier` establish a model concept, not a proved rewards formula. Seventy compiled App Intents declarations cover several action families; not all are necessarily public, discoverable or usable.

Four actual native Safari function dossiers corroborate the JavaScript bridge. The `getWallet` handler retrieves own-account authorization and entitlement state and constructs its reply; despite its name, this path does not return a complete card-row wallet. Static Keychain retrieval code was analyzed without reading any actual stored token.

Main native code establishes a 400 ms model-change debounce followed by filtered Core Data publication, plus incoming `points`, `total_value` and order materialization with two parent reconciliation call sites. A selected consumer formats estimated cents per dollar and welcome value. The followup resolves the selected fetch's sort keypaths to `is_favorite` descending, then `name` ascending; the full upstream value producer remains unresolved. Packaged ranking help is labeled as vendor explanation rather than a verified formula. All selected native questions and limits are in the [native report](native/report.md).

Detailed evidence: [initial extension report](cardpointers/report.md), [deep static findings](cardpointers/deep-findings.md), [native Mac report](native/report.md).

## MaxRewards: server recommendation data with visible client rules

The official extension maps tab/merchant hostname to an authenticated server best-card query, checks session ownership, caches per domain and returns presentation data. The response fields include rates, valuation, reason, spending/limit and offers. The server's candidate selection and ranking formula remain unknown.

The extension's bank subsystem interprets remotely served provider configuration, manages connection/resync state and handles captured session material. All 74 catalog descriptors were acquired and hashed without running their bank instructions. The Bilt descriptor requires a newer extension than the acquired build: catalog size is not a count of working connectors. Encryption/account-owner branches are code observations, not a security certification or proof of backend retention.

The official native package establishes React Native/Hermes/Expo components and category/lock/Live Activity/notification extensions. Its main executable declares an encrypted region; no FairPlay bypass was attempted. Its separately shipped plaintext-format Hermes bytecode supports an unattended analysis path.

Recovered client functions establish these bounded rules:

- Points percentage uses reward rate, point valuation and a percentage conversion; cash percentage also handles a multiplier. Another helper resolves custom currency, user valuation, returned value and rate fallbacks.
- One merchant-card comparator orders normalized percentage descending. This says nothing definitive about signup weighting before the supplied results reach that helper.
- Date eligibility uses inclusive start and exclusive end comparisons. A numeric-month fallback differs from a complete quarter activation policy.
- Selectable-category rows preserve a saved choice by ID. This does not prove issuer acceptance or its effective date.
- Cap-row status uses supplied category totals/rates and a profile flag; transaction aggregation and near-cap purchase splitting are not thereby recovered.
- Welcome-bonus helpers calculate deadlines, posted/pending progress, remaining spend and a value summary. These are separate from the inspected merchant comparator.
- A record-categorization helper gives feedback overrides precedence over pattern/default data. It is not proof of a purchase-time MCC lookup.

Detailed evidence: [MaxRewards dossier](maxrewards/report.md), [independent native recommendation review](maxrewards/native-recommendation-review/report.md).

## What is already present in CardWise

The [source baseline](cardwise-baseline.md) is commit `5f7b9823e053924ee3d353e3198c88738f66af0d`. CardWise already has manual statement-credit usage and unused-credit totals, signup tracking, rotating/selectable rewards, cap accounting, merchant search, and home/lock widgets. Recommending these as wholly new features would misstate the current app.

The engine uses a common $0.01-per-point/mile valuation and prioritizes an unfinished signup bonus before immediate purchase reward. Some inspected view/widget callers omit recorded spending even though the engine accepts it. These are source observations; no implementation change or runtime bug reproduction was performed in this task.

| Priority | Concrete follow-up | Evidence and limit |
| --- | --- | --- |
| P0 | Verify spending input across every recommendation entry point | Existing cap-aware engine versus inspected callers using its empty default; test a recorded-spending-near-cap fixture before changing code |
| P1 | Make point valuations and ranking policy explicit | MaxRewards client has user/currency value fallbacks; CardWise uses a common constant and explicit signup-first sorting |
| P1 | Explain date, activation, chosen category and exhausted cap separately | Native review shows these are distinct predicates/status concepts; one ambiguous active label would obscure why a card wins |
| P1 | Add context to the existing widget payload | Current source computes a fixed Dining/$100 example; configurable category/merchant extends existing functionality |
| P2 | Polish existing benefit/reset/progress workflows | Manual credit usage already exists; pending/posted distinctions require trustworthy inputs rather than inferred balances |
| Separate decision | Automatic bank connection and offer activation | Bank adapters, remote descriptors, retries, credentials/session handling and account synchronization are an ongoing service subsystem |

## Earlier runtime evidence is supplementary

Before the user switched to the unattended method, controlled public browser scenarios observed login/account gates, and a signed-out card-value planner was exercised with synthetic inputs. Therefore, the evidence does not support a blanket claim that MaxRewards requires an account for every useful result. The planner's exact fixture and arithmetic are in its dossier; these are historical observations, not the user's finances or current card advice.

Some native UI observations were also made, but provider window/AX limitations and lack of a controlled authenticated fixture prevent strong end-to-end claims. No additional login, launch or demonstration is needed under the current scope. Account identifiers, raw screenshots, credentials, receipts and live transaction data are excluded from this public PR.

## Delivery and limits

- Completed: official artifact identities, extension/source partitions, public configuration snapshots, CardPointers main/Safari native questions, MaxRewards package/bytecode review, source-bound comparison and compact provenance.
- Evidence and cleanup: CardPointers main 24 and Safari 4 canonical records exported; all owned native jobs closed. Exact former jobs/logs/checkpoints are recorded in [native progress](native/progress.md) and [jobs](native/jobs.json).
- Static-scope limits: hidden server implementation, real bank acceptance/uptime, account-specific paid entitlements and universal recommendation accuracy. These are not tasks awaiting user participation.

All conclusions distinguish observations, inferences and unknowns. Successful parsing, an untruncated graph partition, a complete summary view or a stored field never proves complete behavior. Full third-party artifacts and large raw Evidence are [retained locally](artifacts.md); public files contain digests, source/byte offsets, schema and compact ledgers.

No CardWise application code or release setting was modified. Validation checks artifact identity, provenance, JSON, report links, intended Git paths and the current PR CI. The PR remains unmerged because pushes to main trigger an app release.
