# MaxRewards input producers: caps, choices and valuations

Date: 2026-10-27. This continuation traces **input origins and units** into previously recovered helpers. It reuses those helpers instead of re-decoding them. No target/device execution, server/HTTP request, real storage read, credential/container access, acquisition, whole-app instruction scan or repository change occurred.

Target: official MaxRewards 4.8.35/build 1792099341, separately shipped Hermes v96 `maxrewards/native/main.jsbundle`, 12,633,156 bytes, SHA-256 `efe8a8901364e9a633d0edb1810687f18932ebaf306995c235fccaef23278ba9`. Existing decoder is P1sec/hermes-dec commit `2e796663e1fedb93dca51060797ebf3327b3fedb`. MIP labels are local static finding labels, not REA Evidence IDs. Exact half-open source spans, hashes and selected instruction anchors are in `evidence.json`; `decoded-functions.json` / `reused-functions.json` separate new output from reused files. Large factory outputs are not claimed fully interpreted.

## MIP-01 — The category counter and chosen category are projected by the wallet query

**Observed request contract.** Root F0 registration maps factory F23313 to module 2002. F23313 stores dependency index 9/module 2039 in environment slot 8 (`0x140–0x14c`), and installs F23368 under operation `get-user-cards` (`0x36d–0x372`). F23368 reads that dependency's `userCardsQuery` (`0x3c–0x46`) and packages it in a POST query call. No request was performed.

Module 2039 is factory F24019. It exports `userCardsQuery` through getter F24024, which returns environment slot 10. F24019 builds that slot at `0x1528–0x153d`: `getUserCards(includeClosed: true)` containing a compiled user-card projection. Its exact constituent instructions establish the following separate records:

| Input object | Requested fields relevant here | Exact construction |
| --- | --- | --- |
| `category_rewards` row | `index`, `category`, `amount`, `active_date` | F24019 `0x1422–0x1426` |
| `category_choices` and singular `category_choice` | `reward`, `choice` | `0x1416–0x1422`, reused fragment register 21 |
| Reward definition | `spend_limit`, `spend_duration`, `start_month`, `reward_rate`, `included_categories`, `excluded_categories`, `start_date`, `end_date`, `is_spend_limit`, `limit`, `limit_reset`, `us_only`, `channel_restriction`, `removed`, `deprecated` | `0x137a–0x1390` |
| Standard and custom reward definitions | `.card.rewards` and `.custom_rewards` use that same assembled definition projection | `0x139f–0x13d9`, `0x1442–0x146c` |
| Bonus tracker | `amount`, `pending`, `last_updated`, `autotrack`, requirement/date/status fields | `0x13ff–0x1403`; inserted at `0x143e` / `0x1463` |
| Wallet-card top level | Separate `amount`, `pending`, `started`, `priority` and `type` | `0x144a` |
| Transaction record | Separate `amount`, `reward`, `posted_date`, `transaction_date`, status/type/currency | `0x147b–0x148d` |

**Observed response-to-state path.** F26674 `useCardActions` creates the `queryUserCards` callback from F26698 and returns it under that name (`0x1fb–0x206`, `0x362–0x367`). F26698 → F26699 → F26700 → F26701 closes the callback/generator binding. F26701 invokes `calls['get-user-cards']`, requires status 200 and a truthy `response.data.d.getUserCards`, then stores the returned array directly as `userCardsAll`. The `cards` field receives the same rows filtered by the current profile through module slot 142/F27005 (`0x17–0x5d`, `0x94–0xd4`). F27005/F27006 either preserve the entire array for All or filter by row type/All; these selected filters do not aggregate or rewrite reward amounts.

`setUserCards` is the Recoil setter for module slot 40's `userCards` atom: F26671 `0x41–0x4f`, returned property at `0x329`; F26559 constructs that atom at `0x10f3–0x1119` and binds F26671/74 into slots 44/45 at `0x117e–0x118c`.

**Observed selector-to-helper path.** F26559 exports `getCardByID` via getter F26632/slot 99; the selector family uses F26863 → F26864. The selected ordinary lookup reads connected-card selector slot 79, whose F26826 reads atom slot 40's `cards` and filters through F26827 (account truthy, not closed, not hidden). F26865 selects by strict wallet `id`. The selector also has a distinct hidden-aware branch and a catalog fallback; those must not be described as an always-present connected card.

Reused module F27821 imports module 2277 into slot 7 and binds `processCategoryRewards` F27893 to slot 35. Its selector `categories/getCategoryRewardsData` is F27905 → newly decoded F27906. F27906 reads `getCardByID({id})`, `getUser`, categories atom slot 16 and `userCurrencies`, then calls slot 35 with those inputs (`0xb–0x5e`). This closes the actual source of the card, user/tag, currency and category arguments; it is not merely a guessed helper signature.

Reused F27893 then reads the selected wallet card's `category_rewards` and maps them through F27895/F27896. Reused F27939 independently reads the same selected wallet card's `category_choices`, then F27940/F27944 maps saved `reward`/`choice` IDs into selected options. Therefore those values have an explicit service projection → wallet atom → selected card → row representation path.

**Inference and limit.** In this selected path, the category counter is supplied by the MaxRewards service, not derived from a demonstrated local transaction sum. The client receives a category counter separately from wallet-level pending totals and bonus-tracker pending totals. The name `amount` alone cannot assign them the same units or posting semantics. This does not prove that no other local counter update exists elsewhere.

## MIP-02 — What is and is not established about category amount, caps and dates

The previous helper findings are reused at their original identity. The new upstream projection narrows their interpretation:

- `category_rewards.amount` is used by F27896 as a **reward-rate-derived spending estimate**: when the user-tag gate is enabled, the row's falsy amount defaults to zero and is divided by a normalized definition `reward_rate`. Rates at least 0.5 are divided by 100 before this division; smaller rates are used directly (`F27896 0x18b–0x1a9`). This establishes the arithmetic conversion, not the backend's actual aggregation unit or accuracy.
- The resulting `spent` is compared with supplied `spend_limit || 0` (`0x1ad–0x1c1`). `limit` is exposed separately as `rewardLimit` only for `is_spend_limit === false` (`0x16e–0x185`). These are separate source fields, not interchangeable caps.
- The wire projection requests `active_date`, `category_active_dates`, `limit_reset`, explicit reward start/end dates and `start_month`. The already inspected F27895/F23670 date/quarter path is still a bounded predicate, not an issuer-confirmed activation check. Requesting an activation-date field does not prove it gates every recommendation.
- Category records request no separate `pending` field in this projection. The same request explicitly includes `pending` at bonus-tracker and wallet-card levels. Consequently neither posted-only aggregation nor pending inclusion can be inferred for category counters. The transaction projection's `posted_date` is not a demonstrated input to this category counter consumer.

**Answered:** exact service/client field boundary, separate counter families, rate-normalization/division arithmetic, cap source fields and the selected date-field availability.

**Still unresolved:** whether category `amount` represents dollars of rewards, points, total versus bonus-only earnings, mixed posting states, refunds/reversals or an issuer-specific counter; the authoritative period/time zone/year and `limit_reset` execution; server transaction aggregation; exact remaining-spend/purchase-splitting behavior. No synthetic numeric cap example is presented as a factual accounting result while these input units remain unresolved.

**Reachable next edge:** inspect a newly selected client counter updater or an actual documented response contract if one is found. Hidden aggregation code and real issuer acceptance are server/runtime boundaries. Repeating F27896 does not answer them.

## MIP-03 — `deals_enabled` is read from the current user, not from a bank activation response

**Observed.** F27906 obtains `getUser` from module 2260's imported slot 9 and passes the resulting user to F27893. Module 2260 is F26004. Export getter F26023 returns slot 66; that selector uses F26209, which returns `get(userAtom61).user`. F27893 requires the supplied user's ID and checks `user.tags.includes('deals_enabled')`, storing that boolean for F27896's amount/status gate (`0xfd–0x12c`). The earlier shorthand “profile flag” should not obscure that the actual selected input is the current user object.

The shipped get-user projection includes `valuations { currency value }` and `tags` in F24019 at `0x15d1`. Existing F26116 (reused, not regenerated) calls the abstract `get-user` operation (`0x94–0xa4`), obtains `response.data.d.getUser` (`0x17d–0x193`), and ordinarily writes `{user: returnedUser}` into atom61 (`0x20b–0x239`). Its profile-type correction does not manufacture the `deals_enabled` tag. This is a service-returned account attribute used by client presentation.

**Inference.** The selected gate enables richer category cap tracking/presentation. It is not a rotating-category issuer enrollment status. The visible `hasGold` row property in the old mapper derives from this tag, but the tag alone does not establish a full paid-entitlement or subscription enforcement policy.

**Partial:** current-user selector and service origin are bound. How the server grants/revokes the tag, all promo/subscription paths and whether other features use different capability checks remain unresolved; no entitlement change or API call was made.

## MIP-04 — The F61110 valuation matcher and formatter are now bound

**Observed enclosing module.** Existing F61061 is root-registered module 7637. It creates `roundPercent` F61082 into slot 11 (`0x373–0x378`) and F61110 `bestCardPercentage` into slot 32 (`0x50b–0x510`); newly decoded export getter F61074 returns slot 32. The previously unknown callable at F61110 `0xdf` / `0x112` is therefore F61082, whose complete 34-byte body returns **`Math.round(x * 100) / 100`**. It rounds a number to two decimal places; it is not a string/localization formatter.

F61110's currency-name precedence is nullish `wallet.custom_currency`, `wallet.currency`, `wallet.card.currency`. Newly decoded F61111 matches that name with strict `currency.name` equality. Newly decoded F61112 then matches `userValuation.currency === matchedCurrency.id`. For a noncash branch, the selected valuation is nullish user-override `.value`, result `.value`, then 0. The result is `roundPercent(rate * valuation * 100)`. For cash it is `roundPercent(rate * 100 * (wallet.multiplier ?? 1))`. Explicit rate override is nullish; the result's best/base rate fallback is truthy. Those distinctions preserve zero in different places.

**Observed valuation read producer.** Module F26004 exports `userValuations` through F26042/slot85. Its F26230 selector returns `get(userAtom61).user?.valuations || []`. Module2308/F27951 exports `userCurrencies` via F27973/slot33; that selector F28039 reads user valuations and `transactionsAtom30.currencies`. With no valuations, it returns those currency rows. Otherwise F28040/F28041 maps currencies, matches override currency ID to row ID and copies matching `value` into the currency row. It changes value, not name/ID/type metadata. Base currency records remain an atom input here; their complete fetch producer is not recovered in this pass.

**Observed write contract and units, without executing it.** F26102 returns `updateValuation` from F26135 → F26136 → F26137 → F26138 (`0x21b–0x220`, `0x37d`). F26138 requires a currency ID, calls module slot64/F26101 `matchesDefaultValuation`, then invokes either a set callback in hook slot18 or removal callback slot17 and refreshes the user through hook slot16/queryUser.

The set chain F26126/F26127/F26128/F26129 looks up the currency, reads current user valuations, inserts or updates a matching ID, and writes the resulting list back via F26133. Both the insert at F26129 `0xe2–0xe9` and update F26132 `0x33–0x42` store **input valuation / 100**. The abstract service operation `set-valuation` receives the original input valuation and currency ID (`F26129 0x12b–0x147`). The remove chain F26119/F26120/F26121/F26122 filters out that ID with F26123/F26124 and calls the same operation with valuation null. F26101 compares both proposed/default inputs after `Math.round(value * 100)`; F26138 chooses removal when they match.

**Inference.** The action input/service argument uses a cent-scaled value relative to the stored decimal valuation. This corroborates the peer's actual reward breakdown consumer, which displays `value * 100` with a cent sign. It supports the interpretation of stored value as dollars per reward unit for the displayed US-dollar calculation. It does not prove a universal backend currency schema, conversion across currencies, or the state actually persisted by a live request.

A reconstructed arithmetic illustration grounded in these instructions is: input valuation 1.5 becomes stored 0.015; a noncash rate 3 then yields `roundPercent(3 * 0.015 * 100) = 4.5`. This illustrates units only, not a target execution, a real card rule or a recommendation. No new implementation-mirroring test suite was added.

**Surface distinction.** Reused category/cap helpers F27893/F27939 use a truthy currency-value fallback of 0.01 and truthy multiplier fallback of 1, while F61110 uses its separate nullish override/result/0 path. These are different helpers and supplied-input contracts. A zero or missing value can take different branches; no runtime mismatch was asserted. The peer's `maxrewards-recommendation/report.md` binds the category/merchant/nearby display routes; it must not be replaced with a claim that F61110 is the universal ranking function.

## MIP-05 — A plausible route was explicitly rejected as the category producer

F26674's `getCardSpecificDataQuery` binds F26679 → F26680 → F26681 → F26682. It extracts `response.data.d.getCardSpecificData.userCard` and merges returned fields through F26683/84/85. But the request's actual builder is module2039 export getter F24083/slot80/F24192. Its complete body requests `getCardSpecificDataV2(cardId)` aliased as `getCardSpecificData`, with **only** userCard `id`, `card_image`, `next_annual_fee_charge` plus redeemed totals. It requests neither `category_rewards` nor `category_choices`.

Therefore that route cannot be presented as the producer of the category/choice fields based merely on its generic name or broad merge operation. The correct demonstrated source is the separate `get-user-cards` path in MIP-01. This negative result is bounded to the selected shipped query, not all server capabilities or versions.

## MIP-06 — Upstream category candidates now have a concrete response handoff

To complement the peer's category selector work without decoding it again: F27849 creates `queryCategories` from F27852; F27852/F27853/F27854 wrap F27855. That generator invokes `useAPI().call('get-best-cards-all-categories-lite')` (`0x60–0x70`) and, when its returned `data.d.getBestCardsAllCategories` is truthy, updates categories atom16 through F27856 (`0x7e–0x9e`). F27856 copies the existing state and assigns the exact returned array to `categories`. Reused F23390 selects `bestCardsAllCategoriesLiteQuery`; F24019 exports it through F24028/slot15, whose projection is assigned at `0x1563–0x1567`. That projection includes candidate `bestCards` with ID, base/best rate, currency, value, reason, total_spend and offerId.

This closes the source edge left upstream by the peer's F27757/F27758 category tile chain. It proves service-returned candidate rows enter the client store and local mapper; it does not recover server ranking, completeness or units of `total_spend`. Category-earnings counters and recommendation `total_spend` are distinct response inputs.

## Question ledger

| Required question | Status after this pass | Exact remaining edge |
| --- | --- | --- |
| Category counter producer | Answered to service query → response → atom → getCardByID → F27893 | Hidden server aggregation/issuer source |
| Category amount units | Partial: normalized-rate division and distinct counter projection recovered | Earned cash/points/bonus-only interpretation and exact period not documented by client wire fields |
| Posted versus pending | Partial: category rows have one amount; wallet and tracker pending fields are separate | Posting, reversal/refund and pending inclusion in server category aggregation |
| `spend_limit` / reward limits / dates | Answered for incoming definition fields and consumer binding | Backend units/reset enforcement, all eligibility routes and purchase splitting |
| `deals_enabled` selector | Answered: getUser/current user tags and service-returned user atom | Server entitlement policy and other capability checks |
| `category_choices` read path | Answered: query reward/choice → wallet atom → selected card → saved-choice mapper | Issuer acceptance/effective date; other mutation paths |
| F61110 currency/valuation/format | Answered: module slots, strict matchers, stored values, numeric rounding | Actual runtime values and all callers |
| Valuation input scale | Answered for set/remove action contract and decimal storage | Live persistence/backend validation; full base-currency cache producer |
| Category bestCards input | Answered: lite category query → categories atom; peer mapper reused | Server selection/order correctness and `total_spend` accounting |

## Selection, deduplication and continuation

`decode.py` checks all prior native/auth/data, recommendation-review, iPad-followup, benefits-offers and new recommendation output directories before any finite decode. It records reused paths/hashes. The new 98-ID selection contains candidate factories and rejected route/helper candidates as well as interpreted chains; it is not 98 fully audited semantic functions. `evidence.json` marks interpreted regions and candidate-only IDs explicitly. Related generic wrappers can share source spans, so IDs are not unique-code coverage.

The retained F0 registration index is reused from the earlier benefits continuation and narrowed into `module-bindings.json`; no new root or whole-function candidate producer was run. Validation passed for 98 new IDs / 94 unique source spans, 86 new functions with interpreted regions, 13 reused functions with interpreted regions, 12 candidate-only IDs, 143 instruction-region anchors and zero old-output collisions. Source/output hash checks and exact selected anchors are in `validation.json`. The earlier selected helpers and peer's recommendation screens are reused, not generated again.

Useful offline work remains on the complete base currency/critical-data writer, any additional category-counter updater and exact period/reset handling. Bank activation results, live account correctness and hidden server aggregation remain external evidence boundaries. This pass does not declare the broader competitor investigation complete.
