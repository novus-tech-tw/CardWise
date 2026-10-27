# MaxRewards recommendation continuation — 2026-10-27

This new offline pass closes the Best Card state-to-screen chain that earlier selected reviews did not examine. It establishes a useful distinction: **category tiles and merchant details locally re-rank supplied card candidates, while the nearby summary starts with the first supplied candidate for each place**. Favorite-category reordering is a separate user preference, not a card-reward ranking operation.

This is a bounded supplement to the resumed investigation. It does not declare the full competitor analysis complete. The earlier “reachable selected work complete” language does not establish that remaining offline business functions were reviewed.

## Identity, provenance and selection

- Official acquired MaxRewards 4.8.35 Hermes96 carrier: `maxrewards/native/main.jsbundle`, 12,633,156 bytes; SHA-256 `efe8a8901364e9a633d0edb1810687f18932ebaf306995c235fccaef23278ba9`.
- Existing P1sec/hermes-dec checkout, commit `2e796663e1fedb93dca51060797ebf3327b3fedb`. No installation, target execution, network request, device/UI access, credential operation, whole-app producer or new all-function instruction scan occurred.
- First deduplicated the old eight recommendation + five auth + four data manifests, the old 100-function recommendation supplement, and the 19-function iPad binding supplement. Their union contains **132 unique IDs**. All seven requested seeds are absent from that union. Deduplication and manifest paths are retained in `deduplication.json`.
- New seeds: F27702 `useBestCardStore`, F27703 `useBestCardActions`, F56400 `BestCard`, F56445 `BestCardCategory`, F56651 `ReorderBestCardModal`, F64606 `BestCardCategoryScreen`, F64644 `BestCardLocationScreen`.
- Selected decoding expanded only through direct closures, the bounded neighboring function headers needed to identify enclosing modules, and root F0 registrations of those known factories. `decoded-functions.json` contains **99 newly decoded IDs**; `evidence.json` separates **92 functions with interpreted instruction regions** from seven decoded candidates that support no report claim. These counts are not a whole-app semantic audit. Five previously decoded functions are reused by path/hash and are not counted as new.
- MRC-01–MRC-06 are local static evidence labels, **not REA MCP Evidence IDs**. Primary evidence is the actual instruction listing. Pseudocode is a navigation aid; fallback and compiler environment artifacts prevent treating it as original or runnable JavaScript.
- `evidence.json` supplies exact half-open carrier spans, source/output SHA-256 and instruction anchors. Absolute instruction position = function offset + relative offset. `module-bindings.json` retains exact F0 registration contexts and dependency arrays. `validation.json` checks this linkage.

## MRC-01 — The Best Card store is a Recoil state holder with explicit location/search inputs

**Observed.** F0 registers factory F27668 as module 2301 at root relative `0x118eb`. F27668 creates a defaults selector and atom keyed `bestCard`; slot 21 stores the atom (`0x393–0x3df`), slots 22/23 store F27702/F27703 (`0x3df–0x3f1`). Getter F27673 returns slot 21; F27674/F27675 return slots 22/23. This binds the hooks to this exact store.

F27668 builds defaults with `loading: false`, `categoryColumns: 1`, then replaces `places` with an empty array (`0x360–0x378`). F27699 reads `storage.getNumber('bestCard.numOfColumns')`, defaults nullish values to 1, and adds that count to the defaults. F27700 installs `onSet`; F27701 writes a truthy column count back to that key. This proves persistence of this layout preference only; it does not establish persistence of every store field or a storage-security policy.

F27702 calls `useRecoilState` and `useResetRecoilState` on module slot 21 and returns `bestCardState`, `setBestCardState`, and `resetBestCardState`. F27703 obtains `useAPI().call` and constructs named Recoil callbacks. Direct closure chains show merge updates for `categoryColumns` (F27704–06), `loading` (F27707–09), `permissionsGranted` (F27718–20), `selectedMerchantPlace` (F27728–30), `selectedMerchantDetails` (F27731–33), and trimmed `selectedMerchantQuery` (F27741–43). The returned callback-property bindings are explicit at F27703 `0x102–0x134`.

**Inference.** This is state and orchestration around recommendation inputs/results, not the reward scoring algorithm itself. Store presence does not imply a server-side account model for every field.

## MRC-02 — A concrete location → query → response-state handoff

**Observed.** F27703 binds `getLocation` through F27710/F27711 to generator F27712. F27712 asks `getLastKnownPositionAsync`, falls back to `getCurrentPositionAsync`, obtains coordinates, reverse-geocodes them, merges coordinates/address into the atom, and also contains an `updateUser` call with location-derived custom attributes. Those are shipped calls; this investigation executed none of them. Direct `setLocation` uses F27721–26; combined `setMerchantSelectionAndLocation` uses F27734–38. F27738 converts `location.lat/lng` to `coordinates.latitude/longitude`, trims the optional query and retains the previous selected place when the new `place` is nullish (`0xf–0x88`).

`queryPlaces` binds F27714/F27715 to F27716. It reads a snapshot of atom slot 21. Both latitude and longitude must be truthy to reach the API call (`0x76–0xab`); zero values fail those specific guards. With `selectedMerchantPlace`, it adds numeric argument 500 and base64-encodes the JSON serialization of that place (`0xb1–0x113`). It invokes the captured API call with operation name `get-places`, latitude, longitude, the conditional number and encoded-place argument (`0x113–0x142`). The number's units and server interpretation are not established here.

If `response.data.d.mapper` is truthy, F27716 invokes F27717 (`0x150–0x18b`). F27717 merges that exact mapper into `places` and clears `selectedMerchantPlace` to undefined (`0xc–0x37`). The optional loading argument defaults to true and is cleared through success/error/finally paths. The plain-text query is stored by the input setters; this selected `get-places` call does not pass it as a separate argument.

**Inference.** Nearby results are API-supplied data entering a local presentation/normalization pipeline. This does not recover the endpoint implementation, merchant matching, candidate generation, ranking policy, or the automatic trigger/debounce schedule for every input change. The endpoint was not contacted.

## MRC-03 — Category tiles re-rank supplied card candidates, then follow saved favorite order

**Observed.** F27668 creates the category selector with F27757 in slot 29 (`0x496–0x4b7`). F27757 reads `categoriesStore.categories`, returns an empty array when it is empty, and captures `userCardsAll`, `userCurrencies`, `userValuations`, and categories for F27758 (`0x32–0x9a`).

F27758 passes category `bestCards` (empty-array fallback), wallet cards, currencies, categories and valuations to module slot 20 (`0x0–0x58`). F27668 explicitly binds slot 20 to the already analyzed F27689 `getSortedMerchantCardDetails` (`0x38a–0x393`). F27758 then reads element zero of the sorted result (`0x58–0x5e`) and merges its `cardImage`, `percentage` (as category `rate`, nullish fallback 0), and `paymentService` into the category row (`0x5e–0xb8`). The existing F27689/F27698 listings establish descending normalized percentage sorting; they were reused, not decoded again.

Favorite-category selector F27760 reads `getUserFavoriteCategories` and slot 29's normalized category list, filters with F27761, then sorts with F27762 (`0xd–0x4a`). The filter checks whether saved favorite IDs include `category.id`; the comparator subtracts saved `indexOf` positions. Separate selector F27766/F27767 only prioritizes favorite membership across the full category list; it does not impose the full saved favorite order. Do not conflate these selectors.

F64604 is registered as module 8106. Its dependency 16 is module 2301 and is stored in slot 16 (`0x151–0x161`); dependency 10/module 7024 is stored in slot 10 (`0xe1–0xf1`). F64606 reads `getBestCardsFavoriteCategories` and column count (`0x0–0x2f`) and supplies that list directly to the view (`data` at `0x299`). F64609/10/11 pass category `rate` into `BestCard.percentage` for one/two/three-column layouts. F64607/F64608 bind a press to `CATEGORY_DETAILS` with `categoryId: String(id)`; this is the category handoff, not proof of all content in the destination modal.

**Inference.** There are two distinct orders: local reward ordering inside a category's supplied card candidates, and the user's saved ordering of category tiles. The complete source of `categoriesStore.categories.bestCards` remains upstream of this selected chain.

## MRC-04 — Nearby summary preserves first-candidate semantics; merchant details locally re-rank

**Observed.** Module 2301's nearby selector is F27744/slot 24 (`F27668 0x3f1–0x412`; export F27676). Reused F27744 reads `places`, wallet cards, currencies, valuations and categories and maps places through F27745. Reused F27745 reads `place.bestCards[0]` at `0x5–0x1e` before percentage conversion; it does not call F27689 to sort those alternatives. It copies the original place into its result (`0x2c1–0x2cd`), preserving the original candidate list while adding display values.

F64641 is module 8109. Its dependency 21/module 2301 goes to slot 23 (`0x1c0–0x1d0`), and dependency 17/module 7024 to slot 19 (`0x17b–0x190`). F64644 reads `getBestCardNearbyList`, address, permissions, loading and network status. Its list receives the selector result directly (`data` at `0x431`); F64645 passes each row's name, percentage, card image, payment service, spend, spend limit, category, offer/benefit status and reason into `BestCard`. No inter-place sort appears in this selected screen/mapper path.

F64645 creates onPress F64646 after capturing the row. F64646 calls the captured `setSelectedMerchantDetails(row)` and pushes `MERCHANT_DETAILS` (`0x0–0x49`). F56496 `MerchantDetailsWrapper` reads that store field (`0x32–0x57`); an optional URL merchant parameter is decoded/JSON-parsed and takes precedence, with parse failure falling back to the store value. It places the merchant in bridged route props and renders `MerchantDetailsScreen` (`0xc4–0x1dd`). Root module 7038/F56495 imports module 2301 at dependency 4 and module 7039 at dependency 1, binding those imports to the wrapper's slots 4/1.

F56504 `MerchantDetailsScreen` reads `route.params.merchant`, invokes `getMerchantCardsDetails(merchant)` and subscribes with `useRecoilValue` (`0x42–0x8e`). Module 2301 exports that selector family through F27685/slot 33, whose getter is F27764. F27765 passes merchant `bestCards`, wallet cards, currencies, categories and valuations to slot 20/F27689 (`0x1c–0x9a`). This closes the previously missing screen-to-local-sort caller path. F56504 initially limits more-than-three results with `slice(0,3)` (`0x91–0x141`), and F56510 maps those results through F56511 (`0x36d–0x37d`). F56511 invokes `BestCardCategory`, forwarding normalized percentage/rate/value/spend/spendLimit/isCash/multiplier and offer/benefit fields. Module 7039/F56498 imports dependency 9/module 7029 into slot 9 (`0x107–0x117`); module 7029/F56440 exports F56445 via F56444/slot 17.

**Inference.** The nearby headline and expanded merchant card list use different local paths: the former starts with the supplied first candidate, while the latter locally sorts the supplied alternatives using current wallet/valuation data. That permits a static explanation of potential surface differences, but it is **not an observed runtime mismatch**. Server-side ordering and completeness of candidates remain unknown.

## MRC-05 — “Reorder Best Card” reorders favorite categories

**Observed.** F56651 reads `getBestCardsFavoriteCategories`, initializes local React state from it, and obtains `useUserActions().reorderFavoriteCategories` (`0x24–0x85`). Its drag callback F56652 obtains `from`/`to`, calls imported `reorderItems(currentCategories, from, to)`, updates local state, maps the reordered objects through module slot 17, then calls that user action (`0x0–0x4b`). F56644 binds slot 17 to F56646 (`0x10–0x19`); F56646 returns `item.id`. F56654 passes the local category array and this callback to a reorderable list (`0x35–0x63`).

**Inference.** The control changes the displayed category preference sequence. It does not establish manual overriding of reward percentages, card ranking, card eligibility or server financial rules. The destination persistence/network contract of `reorderFavoriteCategories` was not expanded in this pass.

## MRC-06 — Valuation and cap UI are explicit presentation, with limits

**Observed.** The now-bound merchant renderer F56511 passes `spend` into `spendAmount` (`0x7d–0x93`) and forwards rate/value/percentage separately. For an ordinary nonoffer/nonbenefit row, F56445 renders a noncash breakdown: `Rate` as formatted rate plus `x`; optional non-unit `Multiplier`; `Value` as `(value ?? 0) * 100` with a cent sign; and `Percent` from the supplied percentage (`0x537–0x9fb`). Cash rows have a `Cash Back` percentage display; this view formats its supplied percentage rather than recomputing the complete reward formula.

F56445's cap presentation uses the supplied spend amount and limit. When the spend amount is truthy and a limit is present, the progress prop is `(spendAmount ?? 0) / (spendLimit ?? 0) * 100` (`0xf92–0xfd6`). The caption formats the same spend amount and limit and appends `Spend Remaining` (`0xfe4–0x104a`). No subtraction is performed in that caption block. The bound mapper's `spend` origin is retained in prior evidence; the wording alone must not be promoted into proof of a distinct remaining-spend calculation or a reproduced bug.

Compact `BestCard` F56400 behaves differently: it forwards percentage/paymentService to `PillBadge` for ordinary rows (`0x323–0x350`), displays an offer/benefit reason instead for flagged rows, and only supplies a tracker bar when the row is ordinary and both spend amount and limit are nonzero (`0x454–0x4fc`). That bar also receives `spendAmount / spendLimit * 100`. Its spend caption is suppressed for `Everyday Purchases`, requires positive spend, and uses the suffix `spent` (`0x568–0x62c`). The selected caller F64645 does not forward the mapper's `showPercentage` field into this component; this is a bounded property observation, not an assertion about every screen.

F56445 conditionally renders a payment-service warning when `paymentService` is supplied (`0x1235–0x1300`), naming the method needed for the displayed rate. It does not verify that a purchase used that method. F64644 uses the stored permission boolean to show its location enable prompt/settings action and uses network state for its offline view; those are access/display gates, not issuer activation checks.

**Inference.** These views explain reward value, rate and payment conditions and visualize cap status. They do not independently establish cap exhaustion reranking, bank-confirmed rotating-category activation, transaction reconciliation, entitlement enforcement, actual issuer eligibility, or a purchase-splitting optimizer. Progress rendering/clamping inside the shared `ProgressBar` was not expanded here.

## Question status and remaining bounds

| Question | Result of this new pass | Still unknown |
| --- | --- | --- |
| Store inputs and state | Answered for selected atom/hooks/setters | Every lifecycle trigger, every persistence layer |
| Category handoff | Favorite list → column renderer → string category ID route established | Destination category-detail implementation and upstream candidate generation |
| Location and merchant handoff | Location/query response → places → selected merchant → details → normalized rows established | Live permission/location outcomes and endpoint behavior |
| Local ordering versus server ranking | Local category/merchant sort and favorite ordering bound; nearby first-candidate path distinguished | Server ranking/merchant classification; account-specific runtime result |
| Valuation/cap/eligibility presentation | Bound rate/value/percent/payment-condition and cap-display operations | Issuer enforcement, full accounting, component clamping, all recommendation surfaces |

The new selected chains are now supported by static instruction evidence. Remaining offline entry points elsewhere in the app may still yield useful findings. Runtime/server limits do not imply that the entire offline investigation is exhausted.
