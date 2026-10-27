# CardPointers deeper REA findings

This addendum extends report.md with a complete bounded pass over the publicly shipped Firefox extension source families and a focused Safari extension account bridge. It does not claim complete dynamic resolution, banking execution or recovery of server-side ranking. Updated October 27, 2026 UTC.

## Resource limitations resolved for the selected public code

The first whole-extension semantic graph hit node ceilings. A later combined 344-factory attempt, Evidence `ev_4f92b8e21ad26cbe3088544f5848bc19be45f481e3ddeaebefe487dacf2f93eb`, removed those ceilings but exhausted the parent result-admission budget. It remains partial and is not used to claim complete semantic retention.

To resolve avoidable omissions, all 344 top-level factories from content/content.js were extracted as exact original source slices enclosed in a parenthesized expression. The one large application factory was analyzed with its surrounding business helper factories; the remaining 343 factories were assigned to seven independent CLI processes in balanced batches. The popup and vendor factory containers were separately partitioned, while the three small original JS files were analyzed byte-identically.

The final bounded passes cover all six Firefox JS source families. Every final pass reports zero parse failures, `semantic.truncated:false`, zero omitted semantic nodes/relations, and no resource limits. **Their semantic status remains unknown/partial where dynamic JavaScript, external bindings and this-based dispatch prevent proof. Zero resource truncation is not complete behavioral understanding.** Whole-application cross-file graph coverage is also distinct from partition coverage.

| Final scope | Files parsed | Evidence ID |
|---|---:|---|
| Full content app factory plus eight business helpers; includes content module 342 | 9 | `ev_7d26b4f6a33f1f6e9ec9201c84440c0b2df3d15101e4b62c2e6705bf0ced6b21` |
| Remaining content factories, batch 02 | 36 | `ev_1a2867498d79adf883fd3f336c3331325545c680318ac95073c78a957296b264` |
| Remaining content factories, batch 03 | 39 | `ev_82907745d7da1e6f76869eb660ef709f08e72964b71f5b24f8642da86903954a` |
| Remaining content factories, batch 04 | 53 | `ev_67dee14b8ac03e8e12fa874aa492bedfe9ea69066fa75b7edba778c7ac6e4108` |
| Remaining content factories, batch 05 | 53 | `ev_8002f29a88016d655b63ece02207f6b5f2a34bcdf0e8fb7612fbf8c9490823e2` |
| Remaining content factories, batch 06 | 54 | `ev_a56e58a1db5a114e64b680a006366239b8481edcad722a72b40138b934ff2008` |
| Remaining content factories, batch 07 | 53 | `ev_188af236296b439de4378164197615478fc4684c85714208765d321b514138b5` |
| Remaining content factories, batch 08 | 55 | `ev_e5b3a66a0db525c0fbfb092bce9ebcb02968ef46be8b79ef50cc3bc5699d675b` |
| Popup factories | 15 | `ev_c067bc07a1c167175f885b1bb02550f377826e6270a773100368565eb88402a0` |
| Vendor popup factories | 132 | `ev_6335dec046d2175d3d3a5e479260bb44e9b0440e18334a98fb4fd826027d5bc6` |
| Original background/background.js, popup/popup.js, products.js | 3 | `ev_f2e9c35fe224dec97f49b32160f5e9cd17ff52eea7633900031d3c0b9ee50b11` |
| Additional fine-grained content method partitions | 239 | `ev_74e7cddd87e84766891b4d17a9fe8dc48da11eeed97398d72787849f4ec7e0ec` |

Counts overlap in helper/method verification and must not be added as unique original files. Factory wrappers preserve exact original parameters and bodies but do not reconstruct the webpack runtime, other modules, browser APIs or receiver instances. Method-only wrappers additionally lose outer bindings and are corroborated against the complete app factory. The files are derived artifacts, despite the generic REA tool authority label; their provenance is explicit in `deep/partition-provenance.json`, `deep/all-content-factories-provenance.json`, and `deep/full-content-app-provenance.json`. A verification script checked exact slices and SHA-256 values before this report was updated.

## New finding: Amex enrollment has a local category-aware card ranking

This is **Amex offer enrollment allocation**, not the general best-card-shopping ranking. The initial merchant consumer finding still stands: shopping card order is consumed from merchant/category data.

Popup module 216 exports rankAmexOfferCards, getAmexOfferCategoryBonusMatch, getAmexOfferMethodOrder, reconcileAmexPriority, mergeAmexPriorityIntoCardOrder and cardsInInventoryOrder. The same helper is imported by the content application's Amex flow.

Observed algorithm in the exact shipped source:

1. Restrict wallet candidates to Amex bank_id 26 with an inventory_id.
2. Reconcile a manually supplied inventory priority against current Amex cards; append newly available cards in original order.
3. Normalize the offer's category and applicableCategories text. Aliases connect names such as dining/restaurants to restaurant, groceries to supermarket, gas to gas station, and broader shopping/travel groups to supported categories.
4. For candidate offer-card inventories, find the maximum category card total_value among matching category names.
5. In category_bonus mode, consider that category value a bonus only when it exceeds that card's base value. Sort candidates by descending qualifying bonus.
6. Break ties by reconciled manual inventory order, then by original offer candidate order.

Modes are category_bonus (default), manual_priority, and all_cards. getAmexOfferMethodOrder supplies fallback modes. The content method enrollGroupedAmexOffer iterates those strategies: all_cards attempts a parallel map; other strategies attempt ranked candidates until enrollment succeeds. The caller limits eligible grouped candidates to ten. These are static branches; no issuer enrollment was performed.

**Evidence and provenance:** popup source interval `[7909,11858)` contains the exact factory; its derived module_216.js SHA-256 is `fbd594b7694a6758a605eb1acf109f31c3c1a84cf461cbb57ddfd567453876e6`. REA's property discovery returned actual semantic function node `jsrg_node_c7ff22f82334a73ecba092c59969076c9cc26bf75d330e511192ec4fae73f636` for the category-score helper. A follow-up callers trace, Evidence `ev_22856d876ccb452e795d5c5bd402bc34da9b30dbdcb46032366b8be65da672ee`, resolved the call at derived module_216.js line 1 columns 3116–3128 to that helper. It reports two traversed nodes, one resolved calls relation, and eleven relevant unknowns. This confirms one static call relationship; it does not prove runtime invocation or all cross-module edges.

## Activation/enrollment filtering and sync orchestration

The recovered content methods distinguish issuer offer state from quarterly category activation:

- Amex processing filters merchant offers. With enrolled-offer synchronization enabled and a CardPointers account, it excludes IDs already synchronized; otherwise it keeps eligible/not-enrolled offers. There are distinct old/new issuer response paths.
- Chase processing can synchronize activated offers that are not yet represented in the saved enrolled IDs, using offer ID plus expiry and a legacy ID fallback; otherwise it keeps unactivated offers.
- The common addOffer dispatcher checks each issuer's state representation: US Bank activationState, Wells Fargo status, Bank of America is_activated, Citi offerStatus, Chase status/date, and Amex status/enrollmentDetails. Already enrolled objects can be added to the synchronization collection without a new activation request.
- The addOffers orchestrator matches selected IDs, handles card-mapping dialogs, obtains sync preferences, collects successfully added/existing newOffers, then invokes addOffersCP only when that collection is nonempty. Citi and Bank of America use sequential loops; another path uses Promise.all. Amex adds queue/rate-limit controls and grouped prioritization.
- The CardPointers upload boundary identified in the first report remains unchanged: addOffersCP has a syncOffers gate and constructs the bank_id/cards/offers body, with optional external_id/inventory_id/email branches. Objects are not reduced to a strict small public-metadata allowlist at that assignment site.

**Evidence:** full content context `ev_7d26b4f6a33f1f6e9ec9201c84440c0b2df3d15101e4b62c2e6705bf0ced6b21`; fine-grained method context `ev_74e7cddd87e84766891b4d17a9fe8dc48da11eeed97398d72787849f4ec7e0ec`; exact method provenance in deep/partition-provenance.json for 015_enrollGroupedAmexOffer.js, 041_processFetchedOffersAmex2026.js, 042_processFetchedOffersAmex.js, 057_filterChaseOffersForSync.js, 191_addOffers.js, 192_addOffer.js and 193_addOffersCP.js.

REA application-node traces on module identities did not automatically map into semantic-node seeds; these zero-match traces are retained, not hidden. A later trace seeded from the actual returned addOffersCP application node found only the module itself, Evidence `ev_3d0a101ba031b2d06396806fa2456a8d1d8b47a4e51c4916a6acf5fc8bafd770`. This cannot be presented as a proved cross-function sync dataflow. The orchestration above is direct source reading with exact provenance, supported by successful untruncated syntax analysis.

## What remains upstream about value, caps and recommendation order

The popup wallet refresh receives cards, merchants, categories and offers from the own-account wallet endpoint. The recommendation consumer preserves incoming ordering and uses provided points/value/total_value fields. The Amex category helper consumes total_value; it does not itself derive that field from all reward rules and spending history.

A bounded case-insensitive field search across all six original JS files found no occurrences of spending_cap, spend_cap, remaining_cap, remainingCap, points_value or pointsValue. This is only a negative text search for those spellings. It does not prove lack of cap handling, lack of personalized valuations, or absence of equivalent logic under different names or on the server/native side. Offer activation was recovered; quarterly rotating-category activation policy was not established. Further proof requires legitimate account data/runtime or analysis of the relevant native/server component.

## Focused Safari extension corroboration

The native acquisition worker obtained the installed CardPointers Mac app. This worker read only its public packaged resources and plist identity, copied them into deep/safari, and analyzed background.js and products.js byte-identically. It did not execute the app or native bridge.

Host app and extension bundle plists declare version 8.1.4 build 20261019. The Safari web extension manifest separately declares version 8.1.3. These are different identifiers and should both be retained. This is a cross-platform/cross-version corroboration, not a clean same-platform version comparison.

| Resource | SHA-256 |
|---|---|
| Safari manifest.json | `d5de12579a274f536e5501f76577e4f872a77554d0591296620b73323bf836f8` |
| Safari background.js | `7935e61af1865dd84a4e0c277e80f6e0ff9d686fc48cc85272decd43878ff822` |
| Safari products.js | `4a8292dde004464f1c292868c71c749786aa0707a3f45c2769166c5bd9067730` |

The manifest declares nativeMessaging, tabs, storage, scripting and broad HTTP(S) access. The background has a native-message call to application.id with message getWallet. Its response handling recognizes token, pro and signedOut; it tags a received account as native, tracks the native account UUID and signed-out state, and has a validateWebAccountToken branch that compares native/web UUIDs before allowing a switch unless the explicit web-switch preference is set. This is source evidence for account identity coordination; the native handler and actual host response are a separate investigation.

REA parent Evidence `ev_822ac3d70ae63bad2c8e3449d52ebcf03b3f29409ceb8572c647882705e9101b` parsed both files with no failures, no semantic truncation, and 935 remaining semantic unknowns. Exact source paths, hashes and sizes are in deep/safari-acquisition.json. Ordinary account-token handling here is not evidence of bank-password storage. Actual native iOS behavior is still outside this worker's evidence.

## Updated completion matrix

| Question | Status | Evidence boundary / next step |
|---|---|---|
| Acquire authentic Firefox shipped extension | Complete | Official link, Mozilla download, matched digest |
| Parse all six JS source families without avoidable resource omission | Complete within partitioned static scope | Original parse plus exact factories and independent batches; dynamic semantics remain unknown |
| Explain merchant/category-to-wallet shopping selection | Partial | Consumer recovered; supplied upstream order/values remain external |
| Explain local Amex enrollment card priority | Complete as a static algorithm description | Category aliases, total_value comparison, manual tie-break and fallback modes recovered |
| Explain enrollment-state and sync control branches | Complete as a static branch description | Issuer-specific state filters and common sync boundary; cross-this runtime flow not proved |
| Prove live bank activation or payload sent | Outside completed offline scope | No bank request was performed; no further user login or demonstration requested |
| Prove server cap/valuation/ranking policy | Outside completed offline scope | Hidden server implementation is not established by the acquired client artifacts |
| Explain Safari own-account native bridge request | Complete for JS request/response handling | Native host implementation/runtime handled by separate worker |
| Recover native iOS UI/recommendation internals | Outside this extension workstream | Mac native analysis is [documented separately](../native/report.md); no additional iOS runtime requested |
| Build/modify CardWise | Outside task scope | Root owns report PR; no product code was edited |

## Retained deeper deliverables

- deep/rea-deep-evidence.json: portable complete MCP session export; preserves the earlier partial attempts and all follow-ups.
- deep/content-batch-02-evidence.json through deep/content-batch-08-evidence.json: complete independent CLI Evidence records, with resource settings and provider identities.
- deep/cli-batches-compact.json: small reusable batch ledger.
- deep/deep_full-content-app.json, deep/deep_popup-modules.json, deep/deep_vendor-modules.json, deep/deep_small-originals.json: retained compact summary projections.
- deep/partition-provenance.json, deep/all-content-factories-provenance.json, deep/full-content-app-provenance.json: exact-source and wrapper provenance.
- [Named trace records retained locally](../artifacts.md): actual node-seeded follow-ups, including their limitations.
- deep/bounded-field-search.json: exact bounded negative-search counts.
- progress.md: durable status and remaining external dependencies.

Raw third-party code and large Evidence files remain outside the CardWise repository; root can publish the written findings and compact provenance ledger through the requested PR.

Full third-party code, exact source excerpts and large canonical Evidence are [retained locally](../artifacts.md). The committed [analysis summary ledger](deep/analysis-summary-ledger.json), [CLI batch ledger](deep/cli-batches-compact.json) and [selected exact-source anchors](deep/partition-provenance.json) provide compact provenance without reproducing those artifacts.
