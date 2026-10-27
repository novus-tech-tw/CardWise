# MaxRewards BFO-03: benefit progress, summary populations and period boundaries

Date: 2026-10-27. Scope: retained MaxRewards Hermes 96 carrier only. This closes the selected numeric helper/binding and payment-failed summary questions; it does not establish live issuer data, server calculations or every benefits screen.

## Results

| Question | Result | Evidence |
| --- | --- | --- |
| What does progress mean? | Two explicit paths: milestone threshold progress, or allowance usage. Neither returns a remaining-value field. | F27576, module 2297/F27524 |
| Are annual credits remaining usable money? | No. Annual value is a catalog/scope amount annualized by a recognized period, without subtracting usage. | Reused F38979–81; new F29310 |
| Are expiring credits the remainder of every current credit? | No. The selected caller first selects unused allowance candidates or unmet milestones; the summary adds gross target/reward. Partially used allowances are excluded by that selector. | F38994 → F27332–35 → reused F38982 |
| Does “activated offers” prove an activation filter? | No filter in this selected caller: it supplies `get(offersStore).offers` directly. The helper applies expiry/card/value heuristics, not an activated flag. Upstream store population invariant remains open. | F38994; F28846/F28837; reused F38974 |
| How are duplicates merged? | Benefit ID plus card identity; later defined values replace earlier values, with completeness preference for card objects. Usage is not summed. | F27308/F27314/F27305–07 |
| Are recurring credits reset here? | No state reset in these selected read helpers. They classify periods and select supplied trackers by dates. Tracker creation, reset, matching and server authority remain external to this path. | F27517–21, F27568–70, F29310 |

All addresses below are function-relative bytecode offsets. `evidence.json` supplies half-open carrier spans, raw hashes, exact instruction anchors, reused file hashes and root registration evidence.

## Exact binding and caller population

Reused root registration identifies module 3506 as F38947, module 2293 as F27278, module 2297 as F27524, module 2296 as F27499, module 2492 as F28837, module 2506 as F29293, and module 2298 as F27578. Empty dependency arrays for module 2298/2299 are explicit; no adjacent module dependency is substituted.

The selected caller is **`payment-failed/gold-value-stats`**, not an assertion about a universal dashboard. Reused F38947 binds its selector family to new F38993/F38994. F38994 returns null when its captured enabling parameter is falsy (`0x0b–0x14`). Otherwise it:

- Obtains the live-card-ID selector, wraps its IDs in a Set, and independently reads `userCardsAllV2({includeConnected:true})` (`0x21–0x58`). F38992 calls the same card selector and F38969; F38969/F38970/F38971 map `.id`, remove falsy IDs and deduplicate with Set. These helpers do not themselves prove a separate issuer-active-card rule.
- Uses `Date.now()` as offer-summary reference time (`0x5d–0x68`).
- Calls F38974 with `get(offersStore).offers`, the card Set and that reference time (`0x6c–0x85`). **No activated-state filtering occurs at this edge.** Module 2492 export getter F28846 returns slot 14, the persisted Recoil atom constructed in F28837 `0x6d2–0x745` with default `{offers:[],offersMeta:null}`. This is static atom construction evidence, not a read of any persisted data.
- Calls F38981 with `get(benefitsStore).benefits || []` and the Set (`0x8c–0xac`).
- Calls F38982 with `get(getExpiringCreditBenefits)` and the Set (`0xb2–0xc5`). The export getter F27292 returns module 2293 slot 35; reused F27278 constructs that slot with selector key `expiring-credit-benefits` and getter F27332.

Reused F38974 excludes parsed expiry timestamps strictly less than the reference time, retains equality, requires at least one qualifying `userCards` member, and uses its earlier documented bounded monetary estimates. The selected caller does not supply a list named or filtered “activated”. This does not prove the store includes unactivated rows either: **the store's all-writer population invariant is unresolved**. Its `activatedOffers` output label cannot settle that invariant or establish bank enrollment.

## Expiring population: unused candidates, not partial balances

F27332 reads `benefits` and `allUserTrackers` from the benefits store. It computes `endOf('month').diff(now,'day')`, then maps F27333, filters Boolean via F27335 and sorts F27336. Its date library's environment is imported via module 2015; no separate calendar engine was invented.

F27333 rejects truthy `is_ignored`, any category other than exact `'Credits'`, `days_left_to_expiration <= 0`, or that value greater than daysRemainingThisMonth (`0x09–0x49`). For ordinary numeric inputs this means `0 < days_left_to_expiration <= daysRemainingThisMonth`. These comparisons do not themselves validate finite numbers; missing/NaN values can pass both numeric rejection tests. The supplied `days_left_to_expiration` is not recomputed from the tracker here. A window of zero days can select no positive-day rows.

It finds the first all-user tracker matching benefit `_id`, matching `userCard` when the benefit's `userCard.id` is truthy, and whose numeric `end_date` is in the same month as current time (F27334). Otherwise it uses `benefit.last_tracker` (`0x49–0x87`). Missing tracker excludes the row. When `end_date` is truthy, `dateLibrary(Number(end_date)).utc().isBefore(dateLibrary())` excludes expired rows (`0x87–0xd4`). No new tracker is created or reset.

After calculating progress through F27576 (`0xda–0x104`), F27333 retains:

- **Allowance:** no truthy `date_used`; effective `actual <= 0`; `actual_claims` (nullish fallback 0) `<= 0`; and no linked credit transactions, matched qualifying transactions, or positive captured value (`0x104–0x182`). An allowance with positive partial usage is excluded, even when target minus usage remains positive.
- **Milestone:** `thresholdMet` is false (`0x184–0x18d`). Partial qualifying spend can remain in this population.

Retained rows are `{benefit,tracker,isExpired}` (`0x192–0x1a3`). Reused F38982 then applies its card-ID gate, increments count, and adds monetary allowance **target**, or milestone **reward** (`0x64–0xb6`). It does not subtract allowance actual or milestone spent. For an unused allowance this gross target can coincide with an arithmetic remainder; that is not a general remainder algorithm. An unmet milestone reward is still conditional value, not money already usable.

## Dedupe identity and value preservation

F27308 keys each row as benefit `_id` plus a card identity chosen in order: truthy `userCard.id`, `userCard.reference`, `card.id`, otherwise `card.name` and `card.issuer` joined with a hyphen (empty-string fallbacks). It does not group solely by a catalog title or by the benefit `key`. F27314 groups with Map, merges rows within each group, and returns one row per group. F27305 copies the earlier object and overwrites only later properties that are neither null nor undefined; false and zero remain meaningful replacements. F27306 prefers card objects with more truthy id/name/issuer/image fields; F27307 scores user-card id/reference/card_name/custom_name/card_image. F27314 separately merges last_tracker objects using mergeDefined. It does not add actual_value, target_value or claims across duplicate rows, and it does not establish chronological precedence or issuer authority for conflicting tracker values.

## Progress and monetary semantics

F27576 resolves `getBenefitProgressRule` and `trackerCountsBaseAllowance` first. Rule selection F27557 prefers a usable top-level `scope.progress_rule`, otherwise selects a usable `scope_parts` rule. F27554–56 prefer a part whose threshold equals the top-level threshold, otherwise the first usable part. A usable rule has a finite positive threshold and either an empty period or one of `monthly`, `quarterly`, `semi_annual`, `annual`, `cardmember_year`, `lifetime` (F27552/53 plus F27524's set). Numeric helpers convert with Number and guard finite values; absent/invalid numeric input falls back to zero in `toNumber`.

**Milestone path** (`F27576 0x1e–0x202`): when a rule exists and the tracker does not count the discrete base allowance, threshold comes from the rule, subject to the Hilton free-night minimum of 60,000 (F27575/F27572–74: canonical name or title contains both case-insensitive `hilton` and `free night reward`). `spent` uses finite `tracker.link.progress_status.current` first, otherwise numeric `tracker.actual_value`. `thresholdMet` accepts explicit `progress_status.threshold_met === true` or positive threshold with spent at least threshold. The displayed fraction is clamped to [0,1]. Reward value uses the selected progress part's value, falling back to top-level scope value (F27558). The returned milestone fields include threshold, spent, reward, thresholdMet and metric. No pending/posted transaction split is performed here.

**Allowance path** (`F27576 0x204–0x3ad`): a positive resolved non-percent scope amount takes precedence over finite `tracker.target_value`; returned `persistedTarget` is therefore a selected/normalized base target, despite its name. Add the special monthly period bonus, then derive actual via F27590 unless this is a discrete base allowance, in which case use numeric `tracker.actual_value` directly. Actual is capped above by target when target is positive; the usage fraction is clamped to [0,1]. The return has `persistedTarget`, `periodBonus`, `target`, `actual`, `pctOfTarget` and monetary classification, **not remaining**. Formatting closures used for labels were not expanded or treated as numeric producers.

F27565–67 distinguish a positive non-percent allowance with normalized unit `visits`, `nights` or `credits`, excluding a scope explicitly typed `progress_based`. They can choose an appropriate non-progress scope part. With a progress rule, a missing/nonpositive tracker target or one different from the milestone threshold indicates the tracker counts the base allowance; a target equal to that threshold uses milestone progress instead.

F27544 accepts non-percent scope values whose normalized unit is `currency` or `other_currency`. F27545 classifies execution modes `statement_credit`, `cash_back`, `discount`, `voucher_certificate` as realized monetary modes. F27546 additionally treats tracker type `CELL_PHONE_PROTECTION` as a realized claim tracker. These are client classification rules; the word “realized” is not independent proof of issuer confirmation. F27515 additionally accepts legacy manual monthly/biannual credit types.

F27547 resolves amount for ordinary intervals from finite `amount_per_interval`, then finite `max_annual_value`, then 0. For `per_trip`, `per_item`, `per_stay`, `per_rental`, priority is reversed. It does not multiply `interval_count` or exchange currencies here. F27576 monetary flags use the currency-value predicate and either a realized monetary scope or realized claim tracker. The progress reward is zero when that gate fails. This predicate admits `other_currency`; unlike the annual helper, this expiring path has no USD-only gate or currency conversion, so a sum alone does not establish comparable dollar units.

F27577 `getBenefitSavingsValue` is a **used/earned** scalar, not a remaining scalar: realized claim trackers return numeric actual_value; monetary allowance returns normalized actual; a monetary milestone returns reward only after thresholdMet, otherwise zero. This is local interpretation of supplied state.

## Effective actual can infer full use from supplied matching evidence

The imported helper is now bound precisely: F29294/module 2506 forwards to module 2298; module 2297 itself imports module 2298 in slot 0. F27578 exports `getTrackerEffectiveActualValue` → F27590 and related predicates.

F27587 requires `link.status === 'matched'` plus a nonempty `qualifying_transaction_ids` collection. F27588 checks nonempty `credit_transaction_ids`. F27589 only proceeds when the matched-qualifying predicate passes; it then accepts any of explicit threshold_met, captured_value at least a positive target, progress_status.current at least a positive target, or positive target_claims with actual_claims at least that count.

F27590 takes explicit target when supplied, otherwise tracker.target_value. If positive target exceeds numeric actual_value and F27589 passes, it returns **target** (`0x6d–0x94`). Otherwise a captured_value greater than actual and no greater than positive target can replace actual (`0x84–0x92`); otherwise actual_value survives. Thus effective actual can exceed stored actual_value based on link metadata. The function does not read a statement, independently match transaction amounts, or confirm a credit with an issuer. The IDs/status/current/captured/claims are input contracts.

## Annual value and recurring dates

Reused F38980 annualizes only an accepted realized monetary scope with absent or exact `USD` currency_code and a recognized period. It prefers positive `scope.value.max_annual_value`; otherwise positive F27547 amount times period frequency (monthly 12, quarterly 4, semiannual 2, annual 1). It does not deduct actual, inspect remaining claims, or prorate to today's date. F38981 deduplicates before counting and applies ignored/card gates; neither annual helper directly checks activated.

New F29310 first checks hasBenefitProgressRule, but then reads **top-level** scope.progress_rule.period rather than the selected scope part. If that period is falsy, it tries scope.value.interval, then legacy monthly/biannual type or usage_type_label prefixes. A usable rule existing only in scope_parts therefore does not automatically supply its period to this annualization path. It normalizes monthly/quarterly/half-year/year aliases, including cardmember year as ANNUAL. That annualization does not recover the actual cardmember anniversary date. Unknown periods return null; `lifetime` can be a usable progress-rule period yet lacks a recognized annual frequency here.

F27517/18 select a monthly tracker by benefit ID and user-card ID whose `Number(end_date)` is in the current calendar month. F27519/20 select a biannual tracker by those identities, tracker type, and inclusive `start_date <= Date.now() <= end_date`. F27521 dispatches only those legacy types. These are **selection rules over existing trackers**, not a timer that zeroes actual_value.

F27568 accepts a positive finite numeric period timestamp without seconds-to-milliseconds scaling; otherwise a parseable positive `new Date(String(value)).getTime()`. F27569 prefers tracker.start_date, then end_date, and reads its UTC year/month, retaining source metadata. F27570 adds 20 only for exact benefit title `$200 Uber Cash`, exact tracker_type `MONTHLY_CREDIT`, and period month index 11 (December). This bonus uses the supplied tracker's period, not the computer's current month. Missing/invalid dates produce no bonus. This exact-title exception is shipped behavior, not a general catalog rule.

## Field/authority boundary and remaining evidence

Reused module 2039/F24019 explicitly projects the public schema contract (`0x1ba1–0x1c23`): scope execution/lifecycle/value/progress_rule/scope_parts; benefit ignored/activation flags and days_left_to_expiration; tracker type, start/end dates, target/actual values and claims, date_used; and link status, qualifying/credit transaction IDs, captured_value and progress_status. It does not supply live values in this artifact. The selected read helpers do not establish how the server derives these fields, whether linked transactions are posted or pending, how bank corrections are reconciled, or whether an actual value originated in manual tracking versus synchronization.

Answered: finite bindings, dedup identity/merge, numeric interpretation, selected summary input populations, special December date source, and the distinction between gross annual/expiring values and usage/conditional reward. Partial: the selected caller's raw offer list is known, but its all-writer enrollment invariant is not. Unresolved external behavior: recurring tracker creation/reset and authority, server expiry calculation, transaction matching/posting rules, issuer-confirmed credit state and live UI presentation. These are specific unanswered edges; they are not a claim of format or server impossibility.

Acceptance evidence still needed for those external edges: an authorized read-only record with redacted benefit/tracker/offer provenance and timestamps, before/after a real statement/period change already present in the account, plus the corresponding UI summary. Do not mutate activation, spending or tracker state to manufacture it. No such runtime collection was performed here.

## Checks

`checks.json` records carrier and selected source hashes, exact instruction ranges and new/reused ID deduplication including input-producers and Apple integration artifacts. This work decoded only explicitly followed functions/closures. Candidate-only F27591, F28959 and F38995 were retained without product-semantic claims. The 66 new function IDs cover 65 unique bytecode spans because F27540/F27585 alias the same numeric conversion instructions; aliases are reported explicitly rather than counted as independent behavior. No whole-app producer/import, device operation, real storage read, credential access, network request or repository edit occurred. Arithmetic statements above are direct readings of instructions; no mirror implementation tests or app execution were used.
