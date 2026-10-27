# MaxRewards native recommendation and cap review

This independent supplement examines the shipped plaintext Hermes bundle already acquired by the main MaxRewards workstream. It confirms client-side reward date eligibility, saved category choices, cap-derived display status, welcome-bonus progress, and one merchant recommendation sort. It does **not** establish the full server recommendation algorithm or the bank's acceptance of activation choices.

## Artifact and evidence convention

- Carrier: `maxrewards/native/main.jsbundle`, Hermes bytecode version 96, 12,633,156 bytes, SHA-256 `efe8a8901364e9a633d0edb1810687f18932ebaf306995c235fccaef23278ba9`.
- Decoder: acquired [P1sec/hermes-dec](https://github.com/P1sec/hermes-dec), pinned commit `2e796663e1fedb93dca51060797ebf3327b3fedb`; only its static Python parser/disassembler/decompiler ran. Target bytecode and the native executable were not executed by this review.
- `HBC-F<number>` and `HBC-A<number>` are **local offline evidence labels**, not REA MCP Evidence IDs. This decoder review complements the main report's REA metadata; REA has no Hermes decoder in this environment. No claim below is labelled as REA-native decompilation or recovered original JavaScript.
- [Function evidence](function-evidence.json) records exact original function IDs, offsets, byte lengths, carrier-slice digests, disassembly digests and pseudocode fallback status. [Source anchors](source-anchors.json) records 28 exact half-open ranges and range digests. Absolute carrier offset = function offset + relative listing offset.
- Complete disassembly, parser scripts and candidate ledgers remain in the [retained local archive](../../artifacts.md), under `maxrewards/native-recommendation-review/`. The public PR includes compact provenance rather than third-party source or bytecode. Native acquisition/version identity belongs to the main MaxRewards report.

“Observed” below means explicit shipped bytecode operations or branches. “Inferred” explains their business meaning. “Unknown” identifies an input or behavior the static artifact cannot settle.

## Coverage and limits

All 68,786 function headers and 72,616 strings were inventoried. Each direct-operand search traversed all 49,418 distinct function bodies and 2,098,689 instructions with zero decode errors. Search passes used 258 selected identifiers (496 matching functions), 20 focused cap/activation/quarter identifiers (85), and 10 choice/temporal identifiers (116). A separate serialized object-key pass used 20 terms and found six functions; it read keys, not values. These counts overlap and must not be added as unique function totals. Exact terms and full matching-function inventories are retained locally; [coverage](coverage.json) preserves the bounds and counts.

One hundred additional functions were statically disassembled, including enclosing modules and related helper closures needed to identify bindings. This is a bounded exhaustive **candidate search**, followed by semantic review of the paths reported here; it is not a claim that every one of the 496 broad candidates or all app code was semantically audited. The main workstream's eight earlier decoded functions were not decoded again. Fifty-seven standalone pseudocode outputs fell back to disassembly; the conclusions below use explicit disassembly and recovered parent bindings. Digest/span/output verification passed for all 100 functions; see [validation](validation.json).

Dynamic property construction, unexecuted data-dependent paths, remote services, issuer state and current reward records remain outside this static result. `isRotating` matches included animation components; they were not treated as evidence of rotating credit-card rules.

## 1. Cap definition selection is explicit; transaction aggregation is not recovered here

**Observed — HBC-A01–A03, F61113/F61116/F61118.** `findCapReward` starts at absolute offset 10,922,981 (214 bytes). It builds a set of numeric IDs for the requested category name, concatenates custom rewards before standard card rewards, excludes removed/deprecated rows, and keeps definitions whose included categories intersect that set. It selects the first candidate whose numeric `limit` equals the requested limit; otherwise it returns the first filtered candidate. A missing card or empty category set produces no match.

**Observed — HBC-A04–A10, F27893/F27895/F27896/F27937.** `processCategoryRewards` requires a card ID and profile ID, merges standard and custom definitions, filters invalid definitions, matches a category/quarter record, and checks `isRewardActiveNow`. `filterOutInvalidRewards` requires a nonremoved, nondeprecated definition with included categories and positive `spend_limit`. The enclosing module F27821 binds F27935/F27937 into environment slots 44/45, so these helpers are identified through closure construction rather than guessed from strings.

The mapper F27896 starts at 6,733,134 (916 bytes). Its cap block at relative `0x16e–0x1c5`:

1. Retains `definition.limit` as `rewardLimit` only when `is_spend_limit === false`.
2. Starts `spent` at zero; when the captured `profile.tags` includes `deals_enabled`, derives it from supplied category-record `amount` and a reward-rate divisor.
3. Compares that derived value with `definition.spend_limit || 0` using `>=`.
4. Assigns `isActive = !deals_enabled || !capReached` at `0x2b0–0x2c5` and exposes `spent`, `spendLimit`, `rewardLimit` and `hasGold`. The `hasGold` output is backed by this `deals_enabled` boolean in this path.

**Inferred.** Cap exhaustion affects the category reward row's status, and richer tracking is conditional on the supplied profile flag. The mapper's `isActive` label must not be equated with bank activation: here it is a cap-related display result.

**Unknown.** This path does not establish how transactions were aggregated into `amount`, the authoritative units/period of that input, or how returned rows alter every recommendation surface. It does not demonstrate purchase splitting across a nearly exhausted cap. Treating a rate-derived value as a bank-verified posted spending balance would overstate the evidence.

## 2. Date eligibility and rotating-quarter labels are separate from bank activation

**Observed — HBC-A12, F23670.** `isRewardActiveNow` starts at 6,362,882 (405 bytes). It rejects a missing or deprecated reward, converts supplied start/end dates to numbers, validates them through the imported date helper, then takes these explicit branches:

| Valid bounds | Bytecode condition | Relative branch |
| --- | --- | --- |
| Start and end | now is same or after start **and** before end | `0x176–0x18f` |
| Start only | now is same or after start | `0x15c–0x167` |
| End only | now is before end | `0x169–0x174` |
| Neither, numeric `start_month` | now is same or after first day of that month in the current year | `0xf7–0x15a` |
| Neither, no numeric month | return nondeprecated/default true | `0xe0–0xf5` |

There is no quarter-end comparison in the numeric-month fallback itself. Whether another definition field supplies an end date is input-dependent.

**Observed — HBC-A11/A13/A14.** F27936 matches a category record either by `category` equality or by the definition's `ceil(start_month / 3)` matching its `index`. `getQuarterInfo` F23667 (6,361,549; 1,093 bytes) constructs quarter dates/status metadata; `getRewardQuarterIndex` F67348 (12,302,295; 59 bytes) computes the month-derived quarter.

**Inferred.** These functions implement temporal and quarter representation. They are stronger evidence than a rotating-related string, but they do not by themselves prove required issuer activation is checked.

**Unknown.** The temporal predicate does not read a bank-confirmed activation flag. Other tracker fields such as `requires_activation` cannot be promoted into a rotating-reward gate without a verified call/data path. Whether upstream definitions or services already encode such eligibility remains unknown.

## 3. Selectable-category rows retain the saved choice by ID

**Observed — HBC-A15–A20.** Selector F27939 (6,737,293; 412 bytes) retrieves a wallet card, reads saved `category_choices`, merges standard/custom reward definitions, applies `isRewardActiveNow`, maps them through F27942, then keeps rows whose `categoryItems.length > 0` using F27946. F27942 constructs category options from `choice_categories`.

F27944 (6,738,187; 108 bytes) copies each option, supplies a display name when absent, and writes `chosen` from strict equality between the option ID and the saved record's `choice` ID. The normalizer F67362 (12,303,946; 318 bytes) returns choice details and derives `selectedChoiceId` by finding a `chosen` option; F67364 is the direct chosen-field predicate.

**Inferred.** The UI has an explicit representation of selectable options and saved selection, filtered for current reward dates. A nonempty options list is sufficient for this selector to retain a choice row; it does not require a chosen option to exist.

**Unknown.** This proves the local representation of a saved choice, not that an issuer accepted a category change, when a change takes effect, or how every purchase route applies it.

## 4. One merchant recommendation path sorts by normalized percentage

**Observed — HBC-A21–A23.** `getSortedMerchantCardDetails` F27689 (6,712,757; 84 bytes) maps supplied merchant/card details through F27690 and sorts with F27698. The mapper (6,712,841; 1,024 bytes) uses supplied best/base rate, wallet customizations, currency valuation, multiplier, total spend, and matching cap definition to expose `percentage`, `spend` and `spendLimit`.

F27698 (6,714,103; 38 bytes) is small enough to bound the entire comparison: it returns `(b.percentage ?? 0) - (a.percentage ?? 0)`. It reads no signup-bonus field. The mapper also treats `total_spend == -1` and `-2` as offer/benefit flags and controls percentage display from that input; these sentinels are not ordinary spending balances.

**Inferred.** This local merchant-card order uses the produced percentage. It is not evidence that the percentage was calculated solely on-device or that signup goals never affect upstream inputs.

**Unknown.** The source and semantics of upstream `best_rate`/merchant-card results, remote candidate filtering, and signup weighting before this mapper remain unresolved. This supplement does not claim a complete reconstruction of the main workstream's separate get-best-card routes or all recommendation algorithms.

## 5. Signup completion and remaining-spend arithmetic are visible, but not a ranking weight

**Observed — HBC-A24, F28821.** `getTrackerDetails` (6,812,019; 705 bytes) requires a card ID. It calculates a due date from `start_date` plus `spend_duration` months (default 3), computes days left, and marks expiry when status is 3 or days are negative. It marks completion when status is 2 or a numeric `spend_required` is no greater than supplied `amount` (default zero). `activated` is `status !== 0` in this tracker representation.

**Observed — HBC-A25/A26.** `ActivatedTrackerProgressBar` F56846 (10,028,778; 3,297 bytes), relative `0x91–0xe0`, computes posted progress and progress including pending amounts. The clamp helper F56859 bounds percentages to `[0,100]`. Remaining values are `max(spendRequired - spent, 0)` and `max(spendRequired - spent - pending, 0)`. These are UI arithmetic on supplied totals, not demonstrated transaction ingestion or aggregation.

**Observed — HBC-A27, F38985.** `summarizeWelcomeBonuses` (8,167,627; 333 bytes) traverses `bonus_tracking`, keeps type 1 with status 0/1, obtains tracker details, excludes expired/completed items, counts them and adds nonnegative numeric bonus value multiplied by the card-currency valuation.

**Inferred.** The client distinguishes pending versus posted progress and computes a monetary view of incomplete welcome bonuses. This is a separate summary path; it does not demonstrate that bonus value changes the merchant comparator described above.

**Unknown.** The source of the tracker `amount`, posting/reversal reconciliation, exact server status semantics and a complete signup-aware ranking policy are not established by these functions.

## 6. Merchant/category overrides have visible precedence in a categorization helper

**Observed — HBC-A28, F27964.** `getCategoryAndMerchantV2` (6,743,011; 587 bytes) chooses a category column according to profile type, with standard fallback. A feedback category override of matching type takes precedence; pattern category data otherwise overrides the base category. Merchant precedence is feedback override, then pattern merchant, then standard merchant.

**Inferred.** Corrections and profile-specific categories are first-class inputs to this helper. This is evidence of transaction/record categorization behavior; the function name alone does not establish a purchase-time MCC lookup or merchant-search flow.

## CardWise opportunities grounded in these paths

1. **Carry spending state into every recommendation surface.** CardWise already has cap accounting and a cap-aware engine. Audit and fix the existing recommendation/widget call sites that omit spending input, then use one shared result model with remaining cap and fallback rate. MaxRewards' visible cap status makes silent omission harder to defend; the static review does not prove its own equivalent purchase-splitting behavior.
2. **Explain eligibility with separate reasons.** Surface date window, rotating activation, selected category and exhausted cap separately. The competitor uses multiple different meanings of active; CardWise can state exactly which known local rule changed the result.
3. **Improve existing signup tracking rather than recreating it.** Show posted and pending progress distinctly only where CardWise has trustworthy inputs, clarify deadline and completion state, and keep any optional signup-goal prioritization explicit. The competitor evidence supports progress/value summaries, not a proven universal signup weighting algorithm.
4. **Make merchant corrections inspectable.** Keep a local override's precedence and category source visible, consistent with CardWise's local-first architecture. Do not infer that backend categorization or bank connectivity is necessary to match the observed precedence behavior.

## Question status

| Question | Status for this offline review | Remaining limit |
| --- | --- | --- |
| Additional cap definition selection and exhausted-row status | Complete for identified helpers | Input aggregation and universal ranking integration unknown |
| Posted/pending remaining signup spend | Complete for UI arithmetic | Supplied totals and reconciliation unknown |
| Temporal/quarter reward eligibility | Complete for identified predicate and helpers | Issuer activation state not established |
| Selectable choice representation/filtering | Complete for identified selector | Issuer acceptance/effective date unknown |
| Signup bonus weighting | Partial: summary and one percentage comparator established | Upstream/server weighting and other routes unknown |
| Merchant/category precedence | Complete for identified record helper | Purchase-time MCC/search equivalence not established |
| Native/runtime/server verification | Outside current no-intervention static scope | No account, real bank or target execution performed |

The bounded static review is finished. Unknown server behavior and account data are scope limits, not pending requests for user intervention.
