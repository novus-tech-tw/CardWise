# MaxRewards acquired extension reader boundary

The later [LockWidget continuation](maxrewards-lock-widget.md) supersedes the header-only LockWidget coverage statement below; its encrypted dispatch boundary remains explicit.

This addendum inspects only the three acquired widget/Live Activity extension carriers in the already acquired official **4.8.35 / build 1792099341** package. It does not reuse the encrypted main executable as a substitute for extension identity. `native-reader-boundary.json` contains exact hashes, allowlisted plist fields, Mach-O load commands/section mappings and bounded clear-string/symbol matches. It is supplementary static parsing, not new REA Evidence. No extension was launched, decrypted or modified.

The retained native package provenance is `maxrewards/native/provenance.json`. Existing REA package inventory parent is `ev_5f183e69c10e069f64ed18f69c51596ebf11f77a4320517f0856751ecc96e4e2`, with inventory `ev_1788543234267b19830e387ea0eddfae4a15437b26fdfad24ac912c3883d5d63`; the prior main-Mach-O parent `ev_d4c4152c3e50fb513c3b63114a9ad2147331c9c3d4abe2f154476757f3db7667` describes **main only**, not these newly selected extension headers.

## Exact acquired identities and encryption ranges

All three are thin little-endian arm64 Mach-O executables (`MH_MAGIC_64=0xfeedfacf`, CPU type 0x0100000c, executable file type 2), with `com.apple.widgetkit-extension` declared as extension point and `iPhoneOS` as the supported platform. IDs below append to `com.max.MaxRewards.`. Version and build are 4.8.35 / 1792099341 in each selected plist.

| Extension / identifier suffix | Bytes | Minimum OS in plist | `cryptid`, encrypted file interval |
| --- | ---: | --- | --- |
| `BestCardsByCategory.appex/BestCardsByCategory` | 396,496 | 16.0 | **1**, `[233472,237568)` = `[0x39000,0x3a000)` |
| `MaxRewardsLockWidget.appex/MaxRewardsLockWidget` | 149,360 | 16.0 | **1**, `[45056,49152)` = `[0xb000,0xc000)` |
| `MaxRewardsLiveActivity.appex/MaxRewardsLiveActivity` | 578,480 | 16.2 | **1**, `[368640,372736)` = `[0x5a000,0x5b000)` |

Each `LC_ENCRYPTION_INFO_64` declares exactly **4,096 bytes**; command locations are 3136, 2816 and 3296 respectively. Raw command bytes and hashes are retained in the JSON ledger.

| Executable | SHA-256 |
| --- | --- |
| BestCardsByCategory | `18a36a2d30280733ff9b1f49d2df3a43dfcec4ddea95c3bdf39b58f13d6dc2a3` |
| MaxRewardsLockWidget | `c8cf678113102892d46a77919a572e239ee68fd1a6f66be637d40520ce44e599` |
| MaxRewardsLiveActivity | `6801204ee710b2b4bbfd50cf8b57b0816601c6b9a734be445d149ef55aa640e3` |

**The encryption flag does not make the entire carrier opaque.** The section intersections are:

- Category: final **120 bytes of `__TEXT,__text`**, 3,276 bytes of stubs and 688 bytes of `__const` (plus alignment padding). Its `__text` file span is `[16384,233592)`; `[16384,233472)` is outside the declared encrypted page.
- Lock widget: final **1,392 bytes of `__text`**, 1,476 bytes of stubs and 1,216 bytes of `__const` (plus padding). Its `__text` span is `[16384,46448)`; `[16384,45056)` is outside that page.
- Live Activity: **no `__text` overlap**. The page intersects 2,812 bytes of stubs, 772 bytes of Objective-C method-list data and 508 bytes of Swift type-reference data (plus padding). Its 350,208-byte `__text` span `[16384,366592)` is outside the encrypted interval.

The declared encrypted pages are excluded from semantic claims. An analyzer may misinterpret encrypted stubs or metadata; a call that crosses such a boundary needs separate clear import/ABI corroboration. Nothing was decrypted, patched or reconstructed to bypass FairPlay. Conversely, reporting all native reader code as unavailable solely because `cryptid=1` would overstate this boundary.

## What clear native bytes establish before function analysis

Exact selected clear literal anchors in **BestCardsByCategory**:

| File offset | Literal |
| ---: | --- |
| 241808 | `group.com.MaxRewards` |
| 241983 | `categoryList` |
| 241728 | `No data found in UserDefaults` |
| 241760 | `Failed to access shared UserDefaults` |
| 242000 | `[Widget] No data found for key 'categoryList'` |
| 242160 | `[Widget] Error creating timeline:` |
| 242208 / 242608 | `widget/best-card-category` / its slash-suffixed form |

All are in clear `__TEXT,__cstring` after the encrypted interval. Undefined symbol-table entries include `NSUserDefaults`, WidgetKit `TimelineProvider`, `TimelineReloadPolicy.after(Date)` and the `Timeline(entries:policy:)` initializer. At the initial inventory stage these were only literal/API candidates; the focused function evidence below now establishes a selected read/decode/timeline path. The selected imported symbols have `n_type=1`, `n_sect=0`, `n_value=0`; they are not app-defined method addresses.

Exact selected clear literal anchors in **MaxRewardsLiveActivity**:

| File offset | Literal |
| ---: | --- |
| 385344 | `Open MaxRewards to refresh` |
| 385380 | `Updated now` |
| 385584 | `/best-card-merchant` |
| 385792 | `group.com.MaxRewards` |
| 386784 | `bestCardNearbyLiveActivityPayload` |
| 386000 / 386032 | Refresh-intent title/description |

An undefined ActivityKit symbol refers to `ActivityContent(state:staleDate:relevanceScore:)`. Its presence alone does **not** establish a staleDate value; the selected call sites below supply ABI-grounded evidence. The refresh strings and `RefreshBestCardsLiveActivityIntent` metadata are declaration/candidate evidence, not proof of execution. No refresh intent was run.

The finite literal search returned no selected `__cstring` term in LockWidget; that is a bounded search result, not evidence the extension never reads shared defaults. The JSON lists all searched spellings and every returned match, including duplicates in symbol/code-signature data. Only the section-specific anchors above are used as content evidence.

Each selected bundle's top-level resources are `Info.plist`, `Assets.car`, app icons, `_CodeSignature` and `SC_Info`; Live Activity also contains `Metadata.appintents`. No shipped standalone JSON/source/timeline rule file was found among these top-level entries. Asset/resource names alone do not establish widget states. `SC_Info` was inventoried by name only and was not opened. No application data container, preferences value, token or account material was accessed.

## New focused native analysis

Because the category code is mostly clear and has exact App Group/key literals, this pass selected a **new category-extension Ghidra target**. This is separate from the previously completed main/Safari imports and does not rerun them. Existing REA 6.5.0, task-local Ghidra 12.1.3 and JDK22 are reused; the correct existing Xcode `swift-demangle` directory is prepended to the worker's PATH only. No global repair/install/configuration change is involved.

This pass then selected one additional **new Live Activity extension** target in the same private worker. The completed main import and the category target were not imported again. The durable job record and closeout are `native-analysis/job.json` and `category-worker-state.json`. REA 6.5.0/Ghidra 12.1.3/JDK22 were reused; no installation or global change occurred. The task-local Swift demangler worked with the existing Xcode toolchain directory on the child process PATH.

## Category: concrete App Group reader to timeline/default

**Observed path:** JS `categoryList` writer from the P2 report → category extension configuration `0x10000fe8c` captures the clear group literal through `0x10000cbd4` → `NSUserDefaults.initWithSuiteName:` through `0x10000ca8c` / `0x10001d918` → strict reader `0x100009ae0` → provider timeline `0x100008e48` → `Timeline(entries:policy:)` → completion callback. This is independent native reader evidence, beyond the JavaScript bridge acknowledgement.

The strict reader obtains `stringForKey: categoryList`, converts the Swift string to UTF-8 data, and calls the imported JSON decoder at `0x100009cfc`. Missing shared defaults, a missing key and the Swift decode error path lead to reader error construction. The reader's nonzero Swift error register is tested by the caller at **`0x100009290: cbnz x21, 0x100009768`**, immediately after its call at `0x100009270`.

- **Successful decode:** the timeline function transforms the decoded collection, takes a prefix of **12**, constructs one entry and requests `.after(...)` refresh using Calendar + **15 minutes**. If that calendar addition returns no date, it uses `Date.addingTimeInterval(900.0)`. Policy / timeline / callback anchors are `0x100009654`, `0x100009680`, `0x10000969c`.
- **Reader error:** the branch at `0x100009768` logs `[Widget] Error creating timeline:`, constructs an entry with an **empty category array and empty dictionary**, and requests `.after(Date + 300.0 seconds)`. Policy / timeline / callback anchors are `0x100009a1c`, `0x100009a68`, `0x100009a84`.
- **Separate helper/snapshot route:** `0x1000083b8`, called by `0x10000821c`, also reads/decodes `categoryList` and maps/prefixes the collection. Its missing-defaults/missing-key route supplies an empty collection. This is a separate selected path; it does not replace the strict timeline error behavior above.

**Assembly overrides a material pseudocode omission.** Ghidra's timeline pseudocode labels the Swift error block unreachable and removes it. The shipped clear instructions retain the `x21` branch, error-entry construction, 300-second constant, policy and completion. Therefore the success-only pseudocode is not used to claim that errors cannot refresh or yield an empty entry. The full assembly and selected regions are retained in `function-anchor-coverage-ledger.json`.

The 15-minute / 5-minute values are **requested WidgetKit timeline policies**, not promises that iOS schedules execution at those exact times. No running widget, rendered empty-state artwork, installed entitlement, actual App Group value or callback delivery was observed. The extension's decoded result and requested timeline are established statically; the native render and operating-system scheduling boundary remains separate.

Primary category evidence (all source SHA-256 bound):

| Evidence | Canonical clear function | Role |
| --- | --- | --- |
| `ev_eef15d114478304429ec1535c30c5f7b09bf8e8780e1b6cce25da4b85e56362b` | `0x10000fe8c–0x1000103ef` | Widget configuration / captured group-provider data |
| `ev_7046eee5ec909bbf2a2c3b7322c134c183ec29962bb022dcf7a1e7fa203f4c5e` | `0x10000cbd4–0x10000cc47` | App Group literal getter |
| `ev_42ee773cfed1cb8f8cfc83340cadadcbd59b0bf4595b1e94fafb7d69670612d1` | `0x10001d918–0x10001d9c3` | `initWithSuiteName:` boundary |
| `ev_3a1f46ec63ec82ca796a6f38b61cc07311d52c5f726ce5bd20b6514abd4c28a2` | `0x100009ae0–0x100009ebb` | Strict key / UTF-8 / JSON reader |
| `ev_119e36414fe088df80f7c4330446c24f1beb7b8ddbef862593376c1b910d12d7` | `0x100008e48–0x100009adf` | Success and Swift-error timeline branches |
| `ev_eae20c68bba914d8cdd4b42fb0d85e56e507ae8d43670e4e7ffbc48ba2321501` | `0x10000ccb0–0x10000ccfb` | Provider forwarding entry |
| `ev_1ffd6edac16ad6d0cb7f527d4e9ce7b3261bd35d62c5ed7105d1cc58b236edd1` | `0x1000083b8–0x100008e47` | Separate helper/snapshot read/default route |

One large map-function result exceeded the MCP inline transport limit after completing. It was **not reanalyzed**: full retained evidence `ev_7d24f3e077b2015dee33c4d703ba0a5bda2e0a7939437d53cf3685bfe14629ed` is included in `category-evidence-bundle.json`. No semantic claim depends on its truncated transport envelope.

## Live Activity: shared payload decode to ActivityContent

**Observed selected cache path:** shared group getter `0x100042cbc` / initializer `0x100042c7c` resolves `group.com.MaxRewards`; shared-defaults construction `0x1000432fc` → `0x100056180` sends `initWithSuiteName:`. The key getter `0x100042e4c` runs the `0x100042e0c` initializer and returns the stored string **`bestCardNearbyLiveActivityPayload`**. The initializer by itself is not a reader.

Actual reader **`0x10003eb88–0x10003f5a3`** calls those getters, sends `stringForKey:`, obtains UTF-8 data and JSON-decodes the payload. At `0x10003efb8` it calls the decoder; **`0x10003efc8: cbnz x21, 0x10003f520`** retains the Swift error route in assembly. Missing defaults/string, failed data/JSON decode and missing/empty rows return no payload. A decoded payload with nonempty rows is accepted. **The complete selected reader contains no timestamp-age, TTL, coordinate or schema-version comparison**; this bounded absence does not describe every upstream refresh routine.

In async refresh continuation **`0x10003c794`**, an absent upstream optional value calls that cache reader (`0x10003c884`), then checks the resulting optional. A present value is passed to a state-preparation async function `0x10003f5a4`, and its return continuation **`0x10003ca60`** switches explicitly to **`0x10003cacc`**. If both upstream and cache are absent, this selected entry cleans up and returns; it does not manufacture a successful payload.

State preparation `0x10003f638` supplies `Best Card Nearby` if title is absent and `Updated now` if the update label is absent. It delegates row preparation across another asynchronous helper, then `0x10003f820` → `0x10003f894` constructs the content state. The latter preserves a supplied timestamp; a missing timestamp is filled with **`Date.timeIntervalSince1970 * 1000`**. The row-preparation helper's internal policy is outside this finite closure; the argument/return continuation is established, without claiming complete transformation semantics for that helper.

Before constructing content, **`0x10003cacc` calls the native cache writer `0x10003fc7c`**. That writer JSON-encodes the payload, converts the result to a string and sends **`setObject:forKey:`** with the same key (anchor `0x10003ffd8`). This identifies shipped write instructions only; no actual preference value was read or written during the analysis.

The selected content constructor has two branches: an existing activity is updated through the imported ActivityKit async update boundary; absence of an existing activity takes `Activity.request`. Both call the same ActivityContent initializer at **`0x10003cc90`** and **`0x10003ce00`**.

**ABI-grounded inference for these two call sites: `staleDate: nil`.** Clear import metadata, independently demangled in `ev_bb4313c183c68996df23bca4d11b006a0e9346249f07a2b7dfdaa23d7faa7f08`, identifies:

```text
ActivityKit.ActivityContent.init(state: A, staleDate: Foundation.Date?, relevanceScore: Swift.Double)
```

At `0x10003cc24–0x10003cc44` and `0x10003cd8c–0x10003cdb4`, the code obtains Date metadata, loads value-witness slot `+0x38` (`storeEnumTagSinglePayload`), and supplies tag **1**, empty-case count **1**, to the optional Date buffer. It then passes that same buffer as staleDate to the initializer, without a Date payload write. That is the Optional<Date>.none representation, not a timestamp-plus-expiry calculation. The conclusion applies to **this selected native refresh/update/request flow**. It does not prove the separate main-app `LiveActivityToolkit` bridge always uses nil or that the OS never ends an activity.

## Live Activity native empty/default view boundary

View normalization function **`0x10000d984–0x10000df13`** reads `ActivityViewContext.state`, obtains its row collection and tests `isEmpty`:

- With rows, it preserves the state title, substitutes **`Updated now`** only when the state update label is absent, and supplies **the first three rows** to the display model.
- With no rows, it constructs a one-row display model containing **`Best Card Nearby`**, **`Open MaxRewards`**, **`fallback-empty`**, **`standard`**, **`No nearby cards yet`**, **`Open MaxRewards to refresh`**, **`--`**, and **`green`**, with other optional fields unset. These are the clear native fallback literals and branch construction; exact rendered appearance was not observed.

The complete selected view-normalization function has **no age comparison and no `ActivityViewContext.isStale` access**. Thus the observed empty-row fallback is not evidence of an age-expired fallback. Together with the selected cache reader's lack of age gating and the two nil staleDate call sites, old nonempty cached rows can enter this static display path; this is a path possibility, not a measured runtime event. The label fallback is based on missing label, not computed freshness. ActivityKit scheduling, dismissal, system expiry, other view branches and the main bridge's content policy remain outside this bounded analysis.

Primary Live Activity evidence:

| Evidence | Canonical clear function | Role |
| --- | --- | --- |
| `ev_d68026fbbddfe091aef6efbde8d41c1d9cf676247349ef13cc484783dbc94c51` | `0x10003eb88–0x10003f5a3` | Shared payload read / decode / nonempty check |
| `ev_8700c2ba5b1cebdb47ef5d6ba3e1c5bab49e2a32d6d66084137641e6e4e74543` | `0x10003c794–0x10003ca5f` | Upstream-none → cached payload, optional gate |
| `ev_d3101cd1297060704664dcd74dc41681fc8da550579bdb6f23dc8e297712602e` | `0x10003ca60–0x10003cacb` | Explicit task switch to content constructor |
| `ev_c657a29a01e6416fcab8ed4fed96de0dfcd58f07dbf4004f654fc8053b7b4e00` | `0x10003f894–0x10003fa17` | Content state / missing timestamp → current ms |
| `ev_a983f3be5d9d5f685bbfa251c7f081a2e3a44d6c9cc98bb0d1beccbca9118615` | `0x10003fc7c–0x100040087` | Native JSON writer to same shared key |
| `ev_f2c8eed645b08b08b7fb93fdc86bee9f263a74105363afdf702d65df0fc987f2` | `0x10003cacc–0x10003d287` | Optional Date none / update and request branches |
| `ev_97a1cfac2f7a10c7298c45ab081a0ca24f7964219fe13a9d5a50bc0a365a21ea` | `0x10000d984–0x10000df13` | Nonempty/default-label and empty-row display paths |
| `ev_d193b6ba0518af49c73e5f8b21352282418ea1dfbf0a3ff93f7cff3fc09c9e10` | `0x100056180–0x10005622b` | `initWithSuiteName:` boundary (exact retained range in ledger) |

## Coverage, excluded bytes and closeout

`native-analysis/function-anchor-coverage-ledger.json` binds the retained canonical function bodies, complete inclusive address sets, file offsets and **SHA-256 per body span** to the two selected executable hashes. Its **30 dossier records represent 29 unique functions**, with one recorded duplicate caused by two call-site addresses canonicalizing to the same Live Activity constructor. The large category map transport envelope is separately recorded as retained/exported. The ledger retains **26 selected assembly anchor regions** and reports **zero encrypted-byte overlap across all 29 function bodies**. File mappings were independently checked through `address_to_file_offset` for the category reader/timeline and Live Activity reader/content functions.

Encrypted stubs and metadata remain excluded. For example, category decoder/Timeline call targets may lie in its encrypted stub page; the report names those APIs from clear symbol/import metadata and corroborating surrounding argument/call-site instructions. It makes no claim about the encrypted stub's body. Live Activity's selected ActivityContent stub `0x100059adc` is before its encrypted page; helper calls elsewhere can still cross into the excluded interval. No semantic claim depends on an encrypted helper implementation. The LockWidget extension received no Ghidra import or reader-body analysis.

Full exports are `native-analysis/category-evidence-bundle.json` and `live-evidence-bundle.json`; close results are `category-close.json` and `live-close.json`. Both binary sessions and the private MCP client were closed. EOF terminated the owned Node worker and its execution session exited. A host-only process check confirmed the owned worker, REA child, category JVM and decompiler absent. Process/session locators remain in the local ledger. `job.json` and `category-worker-state.json` record complete/closed. No parent-owned session was altered.

`native-analysis/validation.json` validates source hashes, ranges, anchors, canonical deduplication and the encryption exclusion. `native-analysis/hashes.json` covers the native analysis artifacts; the parent directory's `hashes.json` binds this addendum and its supplementary header ledger. All findings are shipped-artifact static evidence or explicitly marked ABI/control-flow inferences. No device operation, target execution, server, HTTP request, auth access, application-data-container access or repository edit was performed.

The earlier row-preparation-policy boundary is now closed by the [focused native helper followup](maxrewards-native-row-preparation.md): first three rows in input order, optional image-filename enrichment, no selected-helper reranking or timestamp-age gate. Deeper image cache/download policy and actual OS rendering remain separate.
