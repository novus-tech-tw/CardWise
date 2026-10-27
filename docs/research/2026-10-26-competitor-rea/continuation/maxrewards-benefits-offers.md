# MaxRewards benefits and offers: focused offline continuation

Date: 2026-10-27. Target: official MaxRewards 4.8.35/build 1792099341, separately shipped Hermes v96 carrier. This new work answers client-feature questions left open by the earlier selected review. No app execution, device command, bank connection, activation, credential/container read, new acquisition, whole-app REA producer/import or repository edit occurred.

Carrier: `maxrewards/native/main.jsbundle`, SHA-256 `efe8a8901364e9a633d0edb1810687f18932ebaf306995c235fccaef23278ba9`, 12,633,156 bytes. Decoder: existing P1sec/hermes-dec commit `2e796663e1fedb93dca51060797ebf3327b3fedb`. Function offsets below are absolute byte offsets unless marked relative. Disassembly, source spans and output hashes are in `decoded-functions.json` / `source-anchors.json`; validation is in `validation.json`. These are supplementary local static references, not invented REA Evidence IDs. Pseudocode is reconstructed and is not treated as original source or runtime.

## BFO-01: the inspected benefit activation screen records a manual confirmation

**Observed.** F44505 reads an ID from local navigation parameters, bridges it to route/navigation props and renders `ActivateBenefitScreen`. Root registration binds the wrapper's factory F44504 to module 4156 with dependency 4157; module 4157 is factory F44507, which creates F44510. Its dependency index 9 is module 2293, imported into environment slot 9. F44510 reads `useBenefitsActions` and `getBenefitByIDState` from that slot (`0xb4–0xe0`), rather than relying only on the screen name.

F44510 at 9,057,319 reads the supplied benefit and renders activation instructions using `long_description`, falling back to `short_description` (`0x289–0x2ad`). The manual confirmation button appears only when an ID is truthy, `requires_activation === true`, `activated === false`, and `has_auto_tracker` is falsy (`0xf2–0x132`; button block `0x2d7–0x343`). The button text is "I've Activated This Benefit". The callout component F44488 itself uses the supplied variant and `onPress`; it is a presentation component, not the source of bank-confirmed activation.

F44516 retrieves the captured ID and activation callback (`0x0–0x12`). F44512/44513/44515 wrap generator F44514, which sets loading, invokes the captured `benefitAction(id, 'activate')`, awaits it, emits success haptics/logging after ordinary resolution and routes back/clears loading. Exceptions have logging and cleanup branches. No issuer endpoint is invoked directly by these screen closures.

**Concrete action binding.** Module 2293 is factory F27278. It creates F27363 `useBenefitsActions` (`0x8b0`), stores it in slot 50 (`0x8b5`), and exposes it through getter F27304, which reads slot 50. F44509 similarly returns slot 19/F44510 for the screen export. F27363 builds a Recoil callback from F27364 (`0x4a–0x61`) and returns that result under `benefitAction` (`0x14d–0x154`). F27364 → F27365 → F27366 → F27367 is the callback/generator chain.

F27367 updates the benefits atom with the already decoded F27368 callback before its request (`0x26–0x39`), then calls the captured `useAPI().call` function with operation `add-or-remove-user-benefit`, benefit ID and action (`0x3f–0x50`). The existing F27368 is **reused**, not re-decoded: it finds the matching `_id` via F27369; its `activate` branch toggles `activated` and sets `manual_activation_date` to a new ISO date when enabling or null when disabling (`0x93–0xdc`). It returns a copied state with the patched benefits list. F27367 stores the prior state through that callback for rollback on request failure, then logs the failure (`0x66–0x91`).

**Inference.** This flow is a user confirmation recorded optimistically in app state and submitted to the MaxRewards service. It is distinct from the browser extension's issuer offer-enrollment subsystem, an automatically tracked benefit, or quarterly reward activation. It is **not** proof that the bank accepted an enrollment. A server-side side effect beyond the operation boundary remains unknown.

**Limits.** The recovered callback calls an abstract API operation; HTTP method, wire contract, actual result and issuer behavior were not executed here. F27367 catches an ordinary API rejection, attempts rollback and logs it instead of rethrowing it in that branch. Consequently the outer screen's success haptic after promise resolution is not sufficient evidence of server/bank confirmation; no runtime failure was reproduced. The predicate distinguishes `false` from missing activation fields, which matters for interpreting incomplete data.

## BFO-02: activated-offer summary is an estimate over supplied rows

**Observed.** Factory F38947 is module 3506. It stores F38968 `isLiveCard` in slot 22, F38973 `offerDollarValue` in slot 25, F38974 `summarizeActivatedOffers` in slot 26 (`0x43c–0x465`). This closes the previously unknown call targets in F38974; names alone are not used to infer the formula.

F38974 (8,166,249, 240 bytes) takes supplied offers, a supplied set of card IDs and a supplied reference time. It parses `expire_date` through the imported `parseServerDate` and skips a row only when the resulting non-undefined timestamp is **less than** the reference time (`0x39–0x6e`). Equality is retained. An absent parsed timestamp is retained by this helper. It then requires some `userCards` entry to pass F38975 → slot 22/F38968 (`0x72–0x98`). F38968 requires a truthy card ID, then accepts either an empty set or membership in the supplied set. The helper itself does **not** inspect an offer `activated` flag: its caller must supply the intended population.

For each retained row it increments count, adds F38973's value, and also adds that value to `shoppedBeforeValue` when supplied `shopped_before` is truthy (`0x9d–0xc9`). It returns `{count, value, shoppedBeforeValue}`.

F38973 (8,166,115, 134 bytes) implements the following numeric policy:

| Supplied offer | Selected summary value |
| --- | --- |
| Numeric `max_redeemable` in `(0,5000]`, percentage offer | `min(max_redeemable,100)` |
| Numeric `max_redeemable` in `(0,5000]`, nonpercentage offer | That `max_redeemable` |
| Invalid/out-of-range maximum, nonpercentage offer, numeric `value` in `(0,2000]` | That `value` |
| Invalid/out-of-range maximum, percentage offer | 0 |
| No accepted maximum/value in remaining branches | 0 |

**Inference.** This summary applies bounded dollar-value heuristics to available offers. It is not a purchase-specific savings calculation: it does not use basket spend, minimum purchase, remaining redemption count or actual redemption in this helper. `shoppedBeforeValue` means a subtotal gated by a supplied history flag, not confirmed savings. The `activated` function name is not proof that it validates bank enrollment.

**Limits.** The caller population, card-set construction, `parseServerDate` implementation, actual offer records and server authority remain separate questions. This finding is not a complete dashboard-value or offer-ranking reconstruction.

## BFO-03: benefit totals and expiring-credit totals have separate input contracts

The same module binds F38978/F38979/F38980/F38981/F38982 into slots 29/30/31/32/33 (`F38947 0x480–0x4a9`). It supplies annual frequency multipliers MONTHLY=12, QUARTERLY=4, SEMI_ANNUAL=2, ANNUAL=1 in slot 28 (`0x472–0x47c`).

**Observed — F38981** (8,167,006, 187 bytes). It first invokes imported `dedupeBenefits`, skips `is_ignored` rows, and requires the benefit's `userCard.id` to pass the same supplied live-card-set rule. It counts retained benefits. When F38979 identifies a statement credit, it increments credit count and adds F38980's annual value. There is no direct `activated` test in this helper.

F38979 uses legacy imported `isActualCreditBenefit` when `scope.execution_mode` is falsy; otherwise it calls F38978. F38978 requires both imported `isRealizedMonetaryScope(scope)` and `isCurrencyScopeValue(scope.value)`. F38980 returns zero unless those predicates pass, currency code is absent or USD, and a period kind exists. A positive numeric `max_annual_value` is returned directly; otherwise it resolves scope amount and multiplies a positive result by the period lookup. These branches calculate a catalog/annualized value; they do not subtract actual usage.

**Observed — F38982** (8,167,193, 211 bytes). For supplied `{benefit, tracker}` rows passing the card-set filter, it increments count, invokes imported `getBenefitProgressInfo(benefit, tracker)`, and adds `reward` when `isProgressBased` is truthy; otherwise it adds `target` only when `valueIsMonetary` is truthy. This helper itself performs no expiry-date filtering and does not subtract usage/progress from those amounts.

**Inference.** An annual credit estimate, an expiring-credit list subtotal and actual remaining usable value are different concepts. A function named `summarizeExpiringCredits` can summarize caller-filtered rows without independently proving expiry or remaining value. This is a concrete reason to keep input provenance and displayed labels separate in CardWise.

**Limits.** Dedupe identity, scope predicate implementations, period-kind/amount resolution, tracker progress computation, expiry filtering at the caller and runtime labels are not recovered by these selected helper functions. Unknown frequency lookups and malformed supplied data are not claimed to be fully validated. No whole benefit/reset mechanism is claimed complete.

## BFO-04: limited-time card-acquisition offers are separate from bank merchant offers

Root registration binds factory F58935 to module **7365 with an empty dependency array**. F58935 constructs all the selected helper closures in one environment: slot 0 F58940 number formatter; 1 F58941 variant; 2 F58942 part lookup; 3 F58944 end-date formatter; 4 F58945 active predicate; 5 F58946 bonus label; 6 F58947 description; 7 F58948 reward-rate note; 8 F58949 compact mapper; 9 F58950 detailed mapper. This explicit slot binding proves the cross-helper calls in the mappers. A nearest preceding nonempty-dependency factory would incorrectly assign these functions to module 7364; the root empty-array registration is retained in `registration-seeds.json`.

**Observed — activation/date rule.** F58945 (10,537,011, 120 bytes) requires a `limited_time_offer` object. Missing/falsy `end_date` is accepted. A provided end date is converted with Date/getTime; invalid dates are rejected, and `endTime <= Date.now()` is rejected. Thus exact expiry is **exclusive**, unlike the equality retained by F38974's separate summary filter. This function checks no start date or issuer activation flag.

**Observed — presentation.** F58941 normalizes a supplied descriptor to lowercase and replaces runs of whitespace/underscore with hyphens; it recognizes ending-soon before last-chance, otherwise default. F58944 requires both date and supplied time zone, rejects an invalid date, uses `Intl.DateTimeFormat('en-US', ...)` with that zone and assembles time, zone and full numeric date. Missing parts or formatting exceptions return undefined. F58942/F58943 recover the named format part; this is display formatting, not a server timing rule.

F58949/F58950 return null unless the bound active predicate and offer object both pass. Both produce a derived ID, variant, bonus label, card-worth label, optional custom highlight and end-date label. Compact presentation adjusts the bonus currency presentation based on highlight mode. The detailed mapper uses a supplied `welcome` description when truthy, otherwise F58947; it additionally includes F58948's reward-rate note.

F58946 displays `sign_up_bonus.value` (default zero), with Cash rendered as a dollar amount and noncash using currency title/currency/Points fallback. F58947 builds the acquisition-spend explanation from `sign_up_bonus.spend_required` and `spend_duration`, with a separate approval-only branch when either is falsy. F58948 adds an explanatory cents value for noncash cards with supplied `currency_value`: `Number((currency_value * 100).toFixed(2)).toString()`. This is a visible valuation explanation, not proof the user selected that valuation.

**Inference.** This group presents limited-time **card-acquisition/welcome** promotions, not bank card-linked merchant-offer enrollment. The worth label consumes supplied `card_worth`; it does not compute the worth or rank cards. Calling all of these surfaces simply “offers” would obscure their distinct dates, values and activation meanings.

**Limits.** The source/authority of `limited_time_offer`, `card_worth`, `currency_value` and welcome text, current API results, screen callers and paid entitlements remain unverified. No test fixture was saved and no offer was applied or activated.

## Coverage and continuation boundaries

- New selected disassembly comprises 44 function IDs: the ten requested seeds plus module, helper, predicate, callback and export closures selected for these feature questions. F58928 was an initial neighboring module candidate; its identity was superseded by the explicit empty-array registration of F58935. It is not used as the limited-offer helper owner. Some generic wrappers share identical bytecode bodies; ID count is not unique-code or whole-app coverage.
- Candidate existence was checked against the retained native/recommendation-review/followup output directories before decoding. F27368 was reused from its prior disassembly and hash, not regenerated. Existing recommendation producers and F59545 were not decoded again.
- Root module registration parsing reads only the retained root bytecode and selected factories; it does not run the target or repeat the earlier whole-body identifier search. The parser now includes empty dependency-array registrations, needed for module 7365.
- Main MaxRewards encrypted Mach-O status does not block these unencrypted Hermes paths. No decryption or protection bypass was attempted.
- Remaining reachable work: bind actual summary callers/populations and imported benefit progress/reset helpers, then compare with read-only authenticated detail views when a verified controller window exists. Actual issuer acceptance and hidden server calculation remain unavailable from this client-only evidence.
- The parent owns report integration, PR checks and continued investigation. This focused pass supplies new bounded findings; it does not declare the broader competitor task complete.
