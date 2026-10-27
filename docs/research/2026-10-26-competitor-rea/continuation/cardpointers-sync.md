# CardPointers native offer-sync scheduling and save-queue boundary

New offline continuation, 2026-10-27. This pass recovers a concrete **eligible-account selection → schedule-date selection → macOS login-item helper registration/status → observable result flags** path. It also independently establishes an actor-backed save queue that chains asynchronous operations and prevents an older completion from clearing newer queue state. These are executable instruction paths, not conclusions drawn from class names.

No app, helper, account, bank connection, network request, credential API, or user storage was used. Code that calls those facilities was read, never executed. This supplement does not establish that a real sync or offer activation succeeded, and does not close the full competitor investigation.

## Provenance and bounded selection

- Original retained universal executable: `native/artifacts/CardPointers-8.1.4-universal`; SHA-256 `e5e4947e7c6dd288b50f3b84a26efd7f7df8f20e1b2a0c8f573063ea80c09afa`.
- Existing arm64 derivative: `native/artifacts/CardPointers-8.1.4-arm64`; SHA-256 `447e88aced06f027f75b4037a54f089e6750c0e8dc46e648a56ec416966754d0`. Original fat slice offset is 29,032,448. No new thinning or decryption occurred.
- Reused retained dispatch metadata record `ev_efd3886ab6ff0e0dc4ea8589202f66907974517293e3052d286dbb77eb649378` in `native/cardpointers-native-extra-initial-metadata-evidence.json`, plus `native/native-business-class-candidates.json`. Those records bind the class names and stored fields to the original universal digest. New byte reads use the arm64 digest and thin-file offsets.
- Original seeds: OfferSyncAccountManager `0x10187ca98`, OfferSyncCardMappingStore `0x10187cfd8`, OfferSyncCoordinator `0x101880268`, OfferSyncBackgroundRunner `0x1018811c8`, OfferSyncBackgroundScheduler `0x101881360`, PendingOfferChanges `0x1018987f0`, OfferChangeSaveQueue `0x1018988b0`. Two direct dependencies were added: the scheduler's nested BackgroundTaskCompletion and the called OfferSyncMacService.
- The retained Objective-C records expose zero Objective-C methods for these Swift classes. That is not absence of code. Focused parsing of their Swift class descriptors yields metadata accessors, field records and method descriptors. Coordinator exposes 241 vtable entries/60 nonnull implementations; those are inventoried, **not semantically reviewed**. Most final classes expose only a nil allocator entry, so their ordinary devirtualized methods are found through precise caller references instead.
- Mach-O chained fixups identify pointer format 6. Selected class descriptor pointers and selector references use their low-36-bit image-relative target; chain bits are excluded. Relative method implementation pointers are signed Int32. The save-queue async method points to an async entry/context-size record rather than directly to executable code.
- One exact-target aligned B/BL and ADRP+ADD query of `__text` produced caller addresses; `LC_FUNCTION_STARTS` supplied finite caller bounds. Only selected functions/regions were passed to existing Xcode `llvm-objdump`. No Ghidra import, metadata producer rerun, blanket disassembly or duplicate native-function export occurred.
- CPS-01–CPS-04 are analyst labels, not new REA MCP Evidence IDs. `selected-metadata.json`, `selected-abi-dependencies.json`, `exact-xrefs.json`, `evidence.json` and `validation.json` retain byte spans, hashes and anchors. LLVM's nearest-export annotations often name an unrelated `SegmentedIndicatorRing` export; **those annotations are not function identities** and are excluded from interpreted anchors.

## CPS-01 — Account eligibility reaches a concrete scheduling implementation

**Observed.** The selected scheduler class descriptor is `0x1013a90b8`, whose metadata accessor is `0x1000dfda4`. That accessor's ADRP/ADD resolves class metadata `0x101881360`. Exact caller `0x1000ff44c` calls the accessor, obtains a static scheduler instance through `swift_initStaticObject`, moves it into Swift self register x20, and calls function `0x1000ba53c` at `0x1000ff46c`. The same target is reached from two selected schedule-change callbacks (`0x1000ff7cc`, `0x1000ff8dc`). Thus `0x1000ba53c` is bound to the scheduler instance, not merely near a scheduler string.

At `0x1000ba578–0x1000ba5e8`, this function obtains OfferSyncAccountManager metadata via `0x100021910`, initializes an instance, and calls the imported Combine `Published` enclosing-instance getter with two constant key paths. The retained manager fields include `_accounts` as its sole Published field; treating the returned collection as that accounts property is a binding inference supported by these records and the element type below.

The loop obtains concrete `OfferSyncAccount` metadata through `0x100018e54` (`0x1000ba628–0x1000ba64c`). Its descriptor `0x1013a7ca8` has five stored fields in order: `id`, `bank`, `label`, `addedAt`, `isActive`. The loop loads the field-offset-vector entry at metadata+0x14, reads the corresponding bank byte, and skips raw value 6 (`0x1000ba64c–0x1000ba658`). It then loads the field-offset-vector entry at metadata+0x20, reads `isActive`, and skips false (`0x1000ba65c–0x1000ba664`). Passing records are appended to a collection whose count is tested at `0x1000ba708–0x1000ba714`.

With no eligible accounts, it constructs a nil optional Date and calls the helper update function `0x100014928` (`0x1000ba83c–0x1000ba868`). With eligible accounts, it calls scheduler function `0x1000dc28c` for an optional date (`0x1000ba798–0x1000ba7bc`); a nil result reaches the same disabling path. A nonnil date eventually reaches that helper at `0x1000baba4`.

**Inference.** Active accounts and the selected bank discriminator gate whether this macOS helper is scheduled. The exact bank case represented by raw 6 is not identified here. Neither this boolean nor helper registration proves a bank session is authenticated or that offers can be added.

## CPS-02 — Scheduling passes into a real macOS helper and returns status/error flags

**Observed.** Scheduler `0x1000ba53c` reads the retry marker `offerSyncBackgroundRetryCreatedAt` through a resolved `NSUserDefaults.standardUserDefaults` / `objectForKey:` call (`0x1000ba8d8–0x1000ba93c`). One data-dependent branch adds the literal double 900.0 to the computed date through `Foundation.Date.addingTimeInterval` (`0x1000baae8–0x1000baaf8`). This is a 900-second date adjustment, not proof of a universal fixed retry interval. The surrounding date comparison and selection use indirect value-witness operations; the full scheduling formula is not reconstructed here.

The optional-date selector `0x1000dc28c` reads selected UserDefaults configuration/override keys and calls the date helper at `0x1000c1160`. Its nil-date branch removes two override keys (`0x1000dc5b0–0x1000dc66c`). Only this selected surrounding behavior is interpreted; an exhaustive schedule-policy or date-helper review is not claimed.

The scheduler reads static helper storage `0x1019d7240` before calling `0x100014928` (`0x1000bab30–0x1000baba4`). The exact initialization routine `0x1000144a0` binds that storage: it calls OfferSyncMacService metadata accessor `0x1000154e4`, allocates the class, loads a bound class reference whose chained import is `_OBJC_CLASS_$_SMAppService`, and calls resolved selector `loginItemServiceWithIdentifier:` using the bundled literal `com.getcardpointers.app.OfferSyncHelper`. It stores the returned service in instance+24 and the instance into `0x1019d7240` (`0x1000144b0–0x100014534`). Retained class fields name instance+16 `_requiresApproval`, +17 `_hasError`, +24 `service`.

In helper `0x100014928`, selected normal branches read that service's resolved Objective-C `status` selector. At `0x100014e10–0x100014e44`, raw status 0 or 3 reaches `registerAndReturnError:`. A different branch at `0x100014f10–0x100014f44` reaches `unregisterAndReturnError:` for raw status 1 or 2. The raw values are reported directly; no external enum definition is needed for these branch observations.

After the registration/unregistration call, a false return branches to the error path (`0x100014f48–0x100014f50` → `0x1000151dc` → `0x100014acc`). That path sets `_hasError` to true, either directly at `0x100014ae4` or through Observation mutation machinery. A normal completion clears that flag at `0x100014f58–0x100014fe4`. The mutation closures are concretely resolved: `0x1000155cc` writes its captured byte to self+17; `0x100015604` writes its captured byte to self+16; wrappers `0x100015668` and `0x10001567c` call those setters. Service status is read again; `(status == 2)` is stored in `_requiresApproval` at `0x100015094`, with an alternate `ObservationRegistrar.withMutation` path when the observable value changes. The earlier error branch also refreshes this status flag (`0x100014c8c–0x100014d28`).

**Inference.** The recovered result represents helper registration/approval/error state, not successful offer synchronization. This establishes a complete selected account-state → scheduler → actual helper API → result-state boundary. It does not establish the helper's execution time, OS approval outcome, downloaded offers, bank-side acceptance, or a foreground UI observation. No registration or UserDefaults operation was performed by this investigation.

## CPS-03 — The save queue serializes asynchronous operations and guards stale cleanup

**Observed.** OfferChangeSaveQueue class metadata `0x1018988b0` resolves descriptor `0x1013b146c`. Vtable method index 6, descriptor `0x1013b14dc`, has flags `0x50` and signed-relative implementation address `0x1012f5ea8`. That address contains the async entry displacement and context size 224; it resolves executable entry `0x10043be84`. It must not be treated as an executable function at `0x1012f5ea8`.

Retained fields include `tail` at instance+112 and `latestOperationID` with a dynamic/unresolved offset; `$defaultActor` is also retained. This actor identity is independently supported by concrete destructor calls to `swift_defaultActor_destroy` and `swift_defaultActor_deallocate` (`0x10043c6e8–0x10043c6f8`). The selected method hops through `swift_task_switch` to `0x10043bf94` before touching queue state.

At `0x10043bfc4`, it reads the current tail from self+0x70 and captures it. It constructs a new UUID (`0x10043bfe4`), creates a task (`0x10043c0d0`), replaces tail with that task (`0x10043c0f4–0x10043c108`), and stores the UUID through the dynamically addressed `latestOperationID` slot (`0x10043c140–0x10043c170`). It awaits the created task using the specifically resolved `Swift.Task<..., Never>.value.getter` (`0x10043c174–0x10043c1c4`).

The task closure is not guessed: the parent capture stores async descriptor `0x1012f6550`, which resolves thunk `0x10043dc4c`; it forwards captured values into `0x10043c538` at `0x10043dcc8`. That function checks whether the previously captured tail exists, awaits its Task value when nonnil (`0x10043c550–0x10043c598`), then invokes the caller-supplied async operation. The operation's async entry is loaded from the passed descriptor and branched to at `0x10043c5d8` / `0x10043c678`; the operation itself is an explicit unresolved indirect edge.

After awaiting, the queue compares optional operation IDs; one path invokes the imported `Equatable.==` dispatch at `0x10043c404` and tests its boolean at `0x10043c474`. Only the matching/empty-current cases reach the cleanup block that clears tail at `0x10043c48c` and clears the optional ID (`0x10043c494–0x10043c4cc`). A nonmatching newer ID skips this cleanup.

**Inference.** This is a serialized task chain with protection against an older completion clearing a newer tail. It does not prove durable retry persistence, transaction atomicity, a database save result, ordering across every app subsystem, or issuer offer activation. The exact caller-supplied save body remains indirect. The input method's name is not recovered, so it is identified by class descriptor/index/address rather than an invented method name.

## CPS-04 — Remaining seeds and method boundaries

The retained and newly verified metadata establish the following structural facts, without promoting fields into executed behavior:

| Seed | New concrete boundary | Remaining semantic gap |
| --- | --- | --- |
| AccountManager | Metadata accessor reached from scheduler; account collection read/filter loop | Account storage/login reconciliation and bank-case names |
| CardMappingStore | Descriptor/field records: mappings, defaults key, account/bank identity | No mapping read/write method chain interpreted |
| Coordinator | 45 fields; 241 vtable descriptors, 60 nonnull implementations | Status publishers, activation methods and their dynamic callers not interpreted |
| BackgroundRunner | Class-bound allocator/init; stored queue/progress/completion/timeouts at concrete offsets | Full status subscription → account completion policy not closed |
| BackgroundScheduler | Concrete instance-bound scheduling implementation, date/helper handoff | Complete date formula and OS execution outcome |
| PendingOfferChanges | Descriptor and fields `lock`+16 / `entries`+24 | Lock/update/drain operations not traced |
| OfferChangeSaveQueue | Async vtable entry → actor hop → tail task → stale cleanup guard | Exact supplied save closure/database result |

A selected larger caller region around `0x1000cdf98` is retained as a candidate but has not been attributed to a complete runner-status state machine. Its caller contains unrelated data-dependent paths; it is not counted as evidence that all completion behavior was recovered.

No native capability was declared impossible merely because Objective-C method lists were empty. Final-class methods were reached through metadata accessors and exact immediate references. Additional finite offline analysis can continue from the saved method/caller inventories; server/runtime boundaries remain distinct from those unreviewed code paths.

## Verification

`validation.json` passes for nine selected class descriptors, 37 interpreted source regions, 610 instruction anchors, 26 retained bounded disassembly outputs, the selected async-entry records, Objective-C selector bindings and exact native branch targets. The reported new function set is disjoint from the 14 procedure addresses in the prior 24-record native export. Source/output digests and reader identity are retained. This validates static provenance and binding, not execution or financial results.
