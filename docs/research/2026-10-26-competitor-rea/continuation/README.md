# Active REA continuation — 2026-10-27

Rich explicitly required CardWise and Closer analysis to continue. The preceding reachable-only closeout was premature: selected tool completion and provider failures did not answer all remaining product questions. **Only Orbit is paused.** This supplement records newly traced client behavior while preserving earlier evidence and both completed app logins. It does not restart whole-app acquisition or import.

## New evidence delivered

- [MaxRewards recommendation paths](maxrewards-recommendation.md): category and merchant-detail candidate sorting, nearby first-candidate summary, favorite-category order, and rate/cap/payment-condition rendering. [Source/anchor ledger](maxrewards-recommendation-evidence.json).
- [MaxRewards benefits and offers](maxrewards-benefits-offers.md): manual activation confirmation with optimistic update/rollback and service request; bounded offer-value estimates; annual versus expiring totals; separate limited-time acquisition offers. [Function identities](maxrewards-benefits-functions.json), [validation](maxrewards-benefits-validation.json).
- [CardPointers wallet field provenance](cardpointers-wallet.md): selected NewDataResponse/Wallet/Pointer/PointerCard reflection chain, copy-to-materializer map, and Core Data scheduling handoff. [Selected metadata and span identities](cardpointers-wallet-evidence.json). Upstream producer/decoder remains partial.
- [Fresh provider observation](fresh-provider-result.json): a new standalone Frida process and DeviceManager still received connection refusal. Manager cleanup and lease release completed; this is a controller result, not a product-feature conclusion.

## Remaining question ledger

| Question | Evidence state | Next bounded work |
| --- | --- | --- |
| MaxRewards store → category/merchant/nearby recommendation surfaces | Answered for selected client paths; account-specific output unobserved | Keep server candidate generation and runtime result separate |
| MaxRewards manual benefit activation and supplied-value summaries | Answered for selected screen/action/helper paths | Trace summary populations, tracker/reset inputs and imported scope predicates |
| MaxRewards cap/category/valuation inputs and units | Partial; dedicated continuation active | Bind input producers, saved choices and posted/pending versus reward/spend totals |
| MaxRewards Apple integration payload and refresh | Dedicated continuation active | Bind selected App Group writer, native bridge, update/dedup and result routing |
| CardPointers incoming values and order | Partial; concrete type/capture/persistence path recovered | Resolve producer/decoder before the capture; do not assume server-only computation |
| CardPointers native offer sync | Dedicated continuation active | Trace concrete queue/scheduler/status/result paths beyond class names |
| Authenticated read-only feature flows | Pending observation; both logins already verified | Restore a verified controller without repeating unchanged failed input; observe existing data only |
| Signed controller provisioning | Repairable prerequisite under coordinating Closer session | Normal selected-device registration/profile correction; clean signed artifact only |
| Closer analysis | Continues in its existing session/evidence set | Coordinate physical iPad; its work is not silently paused or counted as CardWise evidence |

No additional app login or installation is presently identified as necessary. Do not create account fixtures, enroll offers, sync banks, alter valuations/categories, redeem benefits or change security settings merely to obtain evidence. Ordinary read navigation is authorized once an exclusive controller window is established. Runtime access failure, untried static paths and hidden server implementation remain different classifications.

## Method and delivery

The two new MaxRewards passes selected 99 and 44 function IDs after checking their prior manifests; seven of the 99 are retained candidates without interpreted regions. Counts are not whole-app coverage or proof that all IDs have distinct bodies. The recommendation validator checked 119 source spans, 2,841 instruction anchors and eight module registrations. The benefits pass checked 53 selected anchors and the empty-dependency module registration that a nearest-nonempty heuristic would misattribute. CardPointers used selected raw metadata and small disassembly ranges rather than repeating the 461-second Ghidra import.

Full raw outputs, local scripts and validation details remain in the existing archive; [retained-output digests](retained-output-manifest.json) identify this checkpoint. Public descriptions exclude account contents, private screenshots, device/session identifiers and credentials. PR #81 remains the delivery branch, intentionally unmerged because main triggers an app release. CI proves repository checks, not semantic completion.
