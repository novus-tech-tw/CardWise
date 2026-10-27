# MaxRewards: widget and Live Activity production paths

The subsequent [native extension addendum](maxrewards-native-widgets.md) now resolves selected category-reader/timeline and Live Activity cache/content/default paths. References below to untraced native readers describe this initial JavaScript pass, not the current combined evidence.

This selected offline pass establishes a category-widget payload writer through two concrete native bridges, a nearby Live Activity payload path with cache/throttle/deduplication behavior, and category/merchant deep-link destinations. It also corrects a tempting scope error: **F68616 is part of a nonproduction debug bridge, not the normal app's payload producer.** No widget rendering, Live Activity execution or deep-link navigation was observed on a device.

## Provenance and scope

- Carrier: acquired MaxRewards **4.8.35** iPhoneOS-compatible `maxrewards/native/main.jsbundle`; Hermes v96, 12,633,156 bytes, SHA-256 `efe8a8901364e9a633d0edb1810687f18932ebaf306995c235fccaef23278ba9`.
- Decoder: existing `hermes-dec` commit `2e796663e1fedb93dca51060797ebf3327b3fedb`. Disassembly is primary evidence. Pseudocode is an aid and is neither original JavaScript nor proof of execution. Local labels **MAI-01–MAI-06** below are not REA MCP Evidence IDs.
- All prior three native manifests, recommendation-review manifest, iPad followup manifest, and the new recommendation/benefits manifests were reconciled before interpretation; retained contextual disassemblies were also excluded from new decoding. `deduplication.json` retains these boundaries. No prior decoded ID was decoded again, including F28785/F30443, F68582–F68584 and F68599.
- New decoding follows six seeds and their finite direct closures/import bindings. Only known factory registrations in root F0 were inspected; there was no whole-bundle body search, producer, import or new acquisition. `coverage.json` records **124 new IDs / 116 distinct bytecode spans / 15,149 distinct bytes**, 17 reused functions, 150 retained anchor regions and 4,046 instruction anchors. Seven decoded contextual candidates support no independent report claim; 66 pseudocode outputs fall back to disassembly. These counts do not imply complete integration coverage.
- `evidence.json` holds function offsets, bytecode/output/span hashes, exact relative and absolute instruction anchors, reused paths and coverage labels. `module-bindings.json` holds selected F0 registration contexts. `hashes.json` identifies all local deliverables.
- No app/server/HTTP/device operation, actual authentication or storage read, bank/card mutation, installation, permission change, or repository edit was performed. The writer/reader descriptions below concern **static calls in the shipped client**, not data accessed by this worker.

## MAI-01 — Favorite-category state → App Group payload → WidgetToolkit refresh

**Observed static path:**

`getBestCardsFavoriteCategories` → F30444 hook → 1,000 ms debounced F30447 → JSON `categoryList` → shared-preferences bridge callback → `reloadAllTimelines` → WidgetToolkit native method.

F30429 is registered as module **2651**. Dependency 7/module **2301** is stored in slot 7, dependency 6/module **2652** in slot 6, dependency 14/module **2490** in slot 14, and dependency 18/module **2659** in slot 19. These are the actual imports used by F30444/F30447, not a name-only attribution. F28777/module 2490 supplies literal App Group **`group.com.MaxRewards`**.

F30444 reads the favorite-category selector and `getUserId` (`0x5–0x3b`), installs a busy ref, and wraps the generated writer with dependency 9/module **2252** at **1,000 ms** (`0x4f–0x7c`). Module 2252/F25947 exports F25948 `debounce`; its default leading flag is false and trailing flag true (`F25948 0x4e–0x64`). F30452 invokes the writer only when both category-list value and user ID are truthy, and its cleanup F30453 calls `.cancel()`.

The reused selector binding closes the source of that list: F27668 export F27683 → environment slot 31 → F27760. Reused F27760/F27761 filter category rows by saved favorite IDs, and F27762 orders them by saved `indexOf` order. This is **the favorites-only ordered list**, not F27766's different favorites-first ordering of all categories. Reused F27757/F27758 derive category `rate` and `cardImage` from the existing category/merchant recommendation transformation using wallet cards, currencies and valuations; this pass does not duplicate that recommendation analysis.

F30447 (`0x18–0x69`) skips an invocation while the busy ref is true, otherwise filters/maps then JSON-stringifies the list. F30448 accepts a row only when its ID is an integer, name is a string, `bestCards` is an array, `cardImage` is a string and `rate` has type number. It does not independently verify issuer eligibility or finite numeric values. Mapping preserves the incoming favorites order and does not sort the candidate card arrays.

| Stored category field | Source/default in F30449/F30450 |
| --- | --- |
| `id`, `name` | Category ID; empty/falsy name becomes `Unknown Category` |
| `bestCards[]` | Each supplied candidate's `id, base_rate, currency, image, name, value, reason, best_rate, total_spend` |
| Candidate defaults | Falsy numeric values → 0; currency → `USD`; image/reason → empty string; name → `Unknown Card` |
| `cardImage`, `rate` | Supplied category display image/rate, with falsy empty-string/0 fallback |

These are **serialization defaults**, not proof that the native widget recomputes ranking or uses the same winning candidate as the in-app category tile. The normalized tile rate can reflect current valuation while the candidate array retains supplied candidate fields/order. The native reader's choice among those fields remains untraced.

F30447 reads existing `categoryList` from the same App Group (`0x6d–0x9d`). A read exception is caught and treated as null. When the previous value is null or differs by strict equality from the newly serialized string **and** user ID is truthy, it awaits `setItem('categoryList', serializedString, group)` (`0xb5–0xfd`) and then awaits `reloadAllTimelines` (`0xfd–0x115`). Equal strings skip both write and reload. An empty array is truthy in JavaScript, so an authenticated empty list can serialize/write `[]`; the hook does not require nonzero list length. Missing user ID does not clear a previous payload in this selected path. Errors are logged; the busy flag is released in the shown normal/error/finally paths. No automatic retry or refresh-age deadline is established by this writer.

**Concrete bridge/result boundary:** module 2652/F30502 obtains `NativeModules.RNReactNativeSharedGroupPreferences` (`0x95–0xad`); F30505 constructs `getItem` and `setItem` through F30513/F30519. The set chain F30519 → F30521/F30522 → Promise executor **F30523** calls native `setItem(key, value, group, callback, options)`. F30523 (`0x1c–0x4e`) uses `String(value)` unless the input's type is object, in which case it JSON-stringifies it; the category writer's already serialized **string is not JSON-stringified again**. Callback **F30524** resolves on nullish error and rejects on a nonnull error. This closes the selected payload writer through native-call arguments and callback result.

Module 2659/F30637 resolves **`WidgetToolkit`** via dependency 2660/F30645 `requireNativeModule('WidgetToolkit')`, with a `NativeModulesProxy.WidgetToolkit` fallback if its imported default is nullish (`F30637 0x8a–0xbe`). F30640/F30641 bind the generated F30642 body. F30642 checks native `isWidgetSupported`, calls native `reloadAllTimelines`, and catches failures—including unsupported-device failure—to `console.warn('ReloadAllTimelines Error: ', error)`, returning undefined. Thus an outer resolved Promise can follow a failed or unsupported refresh. **Neither the callback nor this Promise proves that iOS has rendered a new timeline.**

## MAI-02 — Nearby payload fields and two distinct input paths

F28777/module 2490 binds the named builders to F28788/F28790 and their helpers. F28788 (`0x2a–0x77`) creates:

- `title: 'Best Card Nearby'`;
- `updatedAtLabel`, defaulting to **`Updated now`** only when its optional argument is undefined;
- `timestamp: Date.now()`;
- `rows`: **first three input rows**, mapped by F28789. It does not sort those rows.

F28789 produces `id, kind, merchantName, cardName, badgeLabel, offerTitle, spendLabel, progress, paymentService, cardImage, cardArt`. ID uses truthy row URL or `name + '-' + index`; art cycles `gold, green, blue, dark`. F28784 selects kind: offer/benefit first; then tracker when both spend-limit and spend are positive; then payment method when present; otherwise standard. F28782 formats a percentage badge with missing percentage → 0, or derives Offer/Benefit/count labels from `total_spend` sentinels -1/-2. These sentinels are category labels, not negative balances.

Reused F28785 returns no spend label unless both arguments are truthy; otherwise it formats the supplied amounts into a `Spend Remaining` label. F28789 computes tracker progress as `min(1, max(0, spend / spendLimit))` when the limit is positive. This is the supplied numeric ratio; the helper does not establish transaction accounting or that the supplied amount has been reconciled with an issuer.

There are two materially different payload inputs:

| Path | Actual input and transformation | Valuation/ranking boundary |
| --- | --- | --- |
| In-app nearby selector | New F27753 reads existing module-2301 nearby list/slot 24 and calls `buildBestCardNearbyLiveActivityPayload`. Reused F27744/F27745 provide that normalized nearby list | Shares wallet/custom-currency/user-valuation inputs with the existing nearby screen path; that selector starts from supplied `bestCards[0]`, rather than sorting alternatives here |
| Coordinate refresh | F68595 calls declared `calls['get-places'](latitude, longitude)`, reads `response.data.d.mapper ?? []`, and sends it through F28790/F28791 | F28791 selects each place's supplied first candidate; F28787 uses `best_rate ?? base_rate ?? 0`, multiplied by 1 for `Cash`, otherwise candidate `value ?? 0.01`, then ×100. It does **not** read the in-app user-valuation selector in this path |

F28791 adds card image, percentage, payment-service reason matching Apple Pay/Google/PayPal, `spend`, offer/benefit sentinel flags and reason. Unlike the reused in-app nearby normalization, this mapper does not derive `spendLimit` from wallet/category definitions. A limit can still survive the copied original place if supplied there; absence must not be relabeled as proof there are no tracker rows. Static divergence of these paths is established; a visible runtime mismatch is not.

## MAI-03 — Cache fallback, location throttle and unchanged-row suppression

F68573 is module **8584**, importing module 2490 into slot 3 and LiveActivityToolkit's wrapper/module 2654 into slot 8. It binds cache-reader initializer F68585 to slot 15, writer initializer F68589 to slot 16, coordinate-producer F68593 to slot 17 and refresh initializer F68597 to slot 18.

Shared body offset **4,305,573** alone has no feature meaning. The enclosing bindings establish:

| Export/shared wrapper | Captured implementation chain |
| --- | --- |
| F68588 `getCachedPayload` | F68585 → generator F68586 → **F68587** |
| F68592 `persistPayload` | F68589 → F68590 → **F68591** |
| F68596 `getBestCardNearbyPayloadForCoordinates` | F68593 → F68594 → **F68595** |
| F68600 `refreshBestCardNearbyLiveActivityForLocation` | F68597 → F68598 → reused **F68599** |

F68587 reads App Group key **`bestCardNearbyLiveActivityPayload`**, JSON-parses it only when the returned value is a string, and returns null for nonstring/error. It contains **no timestamp-age, location-match or row-schema freshness validation**. F68591 serializes and writes a supplied payload to the same key/group. These are static app calls; no stored value was read for this investigation.

F68595 falls back to F68588 **when the newly built payload has no rows** (`0x73–0xa6`). It does not catch a thrown request as a cache fallback; such errors reach the outer refresh catch. This means a successful empty response can reuse old rows, while a transport failure can simply return an error status.

Reused F68599 establishes these ordered outcomes:

| Condition | Static result / effect |
| --- | --- |
| Native wrapper `isSupported` false | `{updated:false, reason:'unsupported'}` |
| No current ID for `best-card.nearby` | `{updated:false, reason:'inactive'}`; this refresh does not start a new activity |
| Not forced and location throttle true | `{updated:false, reason:'throttled'}` |
| Producer/cache result has no rows | `{updated:false, reason:'empty'}` |
| Not forced and serialized `rows` equals saved rows signature | `{updated:false, reason:'unchanged'}`; no native update or payload persist |
| Remaining success path | Copy payload with **timestamp overwritten to Date.now()** → await native `updateActivity(id,payload)` → await App Group persist → save rows signature → return `{updated:true,activityId}` |
| Exception inside fetch/update/persist segment | Log and return `{updated:false, reason:'error'}`; prior writes/native effects are not rolled back |

Reused F68582/F68583/F68584 supply throttle inputs: recorded refresh time/coordinates; malformed/missing coordinates return null. With usable prior metadata, throttling is **elapsed <180,000 ms OR distance <100 meters**. Force bypasses both this throttle and unchanged-row suppression. Refresh time/coordinates are saved after the producer resolves but **before empty/unchanged checks** (`F68599 0xcf–0xfa`), so those early results can still advance location-refresh metadata.

F68579's signature is `JSON.stringify(payload.rows ?? [])`: title, updated-label and timestamp are outside the signature. Therefore a label/time-only change does not update the activity on the unforced path. Conversely a force refresh can send cached older rows with a new timestamp; it does not establish that the rows themselves were freshly computed. `Updated now` is a client-supplied label, not a verified freshness guarantee. The selected JS cache reader has no expiry rule; **native ActivityKit stale-date, timeline scheduling and native UI fallback were not traced**.

## MAI-04 — App deep-link handler → LiveActivityToolkit result; debug scope separated

Module 2651's ordinary deep-link hook **F30459** captures the same nearby selector payload and `startOrUpdateActivity` module 2654. Its generated callback **F30464** is the concrete non-debug path:

`nearby selector F27753 → F30464 → module2654 startOrUpdateActivity → F30556/F30557/F30558 → LiveActivityToolkit.startOrUpdateActivity(type, normalizedPayload) → returned activity ID → Recoil state`.

F30464 does not start with empty rows: it marks the activity pending and returns (`0x36–0x75`). An already-running request similarly sets pending. With rows and no in-flight call it copies the selector payload, overwrites timestamp with `Date.now()`, and calls `startOrUpdateActivity(BEST_CARD_NEARBY_ACTIVITY_TYPE, payload)` (`0x99–0xe1`). The returned ID controls `isActive: Boolean(id)` and state `{activityId,isActive,isPending:false}`; row signature is retained and an optional consumed deep link cleared (`0xea–0x1b6`). A null return is not represented as an active activity. Errors are caught and the in-flight ref cleared; no issuer/server acceptance is implied.

The import binding is concrete: F30541/module **2654** obtains dependency 2655's default from F30571 `requireNativeModule('LiveActivityToolkit')`, falling back to `NativeModulesProxy.LiveActivityToolkit` if nullish. It sets type **`best-card.nearby`**, reads native `isSupported`, and reads native `minimumSupportedVersion` with string fallback **`16.2`** (`0x14e–0x194`). This JS wrapper does **not** itself compare OS version to 16.2. F30558 returns null if unsupported or if native `startOrUpdateActivity` is not a function; otherwise it calls the native method. F30570 copies the payload and converts a `Date` timestamp through `.getTime()`; ordinary numbers pass through. Native authorization, lifetime/stale-date policy and actual ActivityKit rendering remain beyond this selected bridge path.

The seed F68616 instead lives inside **LiveActivityDebugBridge**: F68601/module 8585 → F68610 effects → F68615 → F68616. F68615 installs `globalThis.LiveActivityDebug` only if F68609 returns true. That test reads `APP_VARIANT`, defaults a falsy value to `development`, and checks `!== 'production'`. F68616 merges current payload with overrides, keeps current rows when override rows are nullish, and supplies `Date.now()` when override timestamp is nullish. F68629/F68633 share the generic wrapper body but bind through F68626/F68627/**F68628** and F68630/F68631/**F68632**. The latter throws when no current ID exists, then calls the same native bridge with the merged payload. These are statically resolved **debug functions**, not evidence that a production build exposes or executes them. This task did not inspect the actual configured APP_VARIANT value or enable that bridge.

## MAI-05 — Widget category and merchant links reach specific app routes

Reused **F30443** URL-encodes `merchantId` and optional truthy `merchantName`, producing `maxrewards+production://widget/best-card-merchant?...`. F30429's patterns accept `maxrewards+[a-z]+` variants for category/merchant/live-activity routes. F30454 validates category route suffix as digits; merchant parsing uses `URL.searchParams`, requires a truthy merchant ID, and returns optional merchant name/source. Invalid merchant URL or parse failure returns null. Category route without an ID remains a category link with an undefined ID.

The selected Expo route components establish two route-to-result paths:

- **Category:** F68704 normalizes an array-valued `categoryId` to its first element. One-shot effect F68705 immediately replaces to `ROUTES.BEST_CARD.TAB.CATEGORY`; with truthy ID it schedules F68706 after **250 ms** to push `CATEGORY_DETAILS({categoryId})`. With no ID, it stays on the category tab.
- **Merchant:** F68713 normalizes the first merchant ID/name parameters. One-shot F68714, if ID is truthy, builds the merchant widget URL and calls `queueBestCardMerchantDeepLink`, then replaces to the location tab. F30455/F30457/F30458 store the queued URL in `deepLinkToOpen`.

The common F30459/F30481 consumer waits for its `isDataLoaded`/tab/onboarding gates. For merchant links it moves to the location tab if necessary, then finds a nearby row by **URL-or-name/index fallback ID equal to merchantId OR row name equal to merchantName** (F30487). If not found it attempts the existing location action once, then the places action once when coordinates exist, using separate request/finished refs; exhausted branches clear the queued link. If found, it calls `setSelectedMerchantDetails`, serializes/URL-encodes that **existing row**, and after **200 ms** F30488 pushes `MERCHANT_DETAILS({merchant: encodedRow})`. This reaches the previously analyzed merchant-details input boundary without fetching a private endpoint or executing navigation here. Matching by name is part of the actual predicate, not a proven unique merchant identity guarantee.

F30475 returns false for unsupported/invalid deep links. A recognized live-activity-start queues the activity flow rather than directly mutating an activity in the parser. Live Activity creation is not a read-only runtime action and was not performed. App-specific route declarations, native URL scheme registration, OS link delivery and actual navigation were not revalidated in this pass.

## MAI-06 — Coverage and platform boundaries

| Question | Result | Remaining exact boundary |
| --- | --- | --- |
| Category payload writer and refresh source | **Answered statically:** favorite selector, validation/defaults, App Group native callback and WidgetToolkit method bound | Hook mounting/execution, native widget decoding/configuration/defaults, actual iOS timeline result |
| Nearby payload values and shared recommendation inputs | **Answered for two selected paths:** in-app selector versus coordinate response mapper | Backend candidate production; other surface-specific paths; observed equality on account data |
| Stale/default behavior | **Answered for selected JS cache/throttle/dedup branches** | ActivityKit staleDate/native timeline scheduling, native placeholder/expired UI |
| Live Activity entry to native result | **Answered statically:** deep-link callback to native ID and state; debug route correctly scoped | Native permission/authorization implementation and actual result; no activity was started |
| Category/merchant deep-link destinations | **Answered for selected JS route components/common handler** | Native URL delivery and actual current app navigation |
| Current iPad product behavior | **Not observed in this offline pass** | Parent's separate controlled runtime work, existing account content/entitlement and version identity |

These findings apply to the acquired **4.8.35 iPhoneOS-compatible Hermes carrier**. They do not establish current installed iPad versions, macOS widgets, Watch/CarPlay/Shortcuts support, native extension implementation or backend internals. The acquired main Mach-O's prior encryption boundary is preserved; no bypass was attempted. Native widget readers and timeline code are **untraced here**, not declared inherently unavailable. The next useful offline increment would inspect explicitly selected acquired extension reader/timeline symbols or available native metadata, with its own artifact identity; a controller failure is not evidence that these client questions are complete.
