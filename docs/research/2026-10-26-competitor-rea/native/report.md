# CardPointers Mac offline REA findings

## Exact selected target

The user requested the Mac equivalent of the apps already installed on their iPhone. Root obtained the official CardPointers Mac app through the Mac App Store, then selected `/Applications/CardPointers.app`. This supersedes the earlier native-acquisition-pending checkpoint.

Observed package identity: CardPointers 8.1.4, build 20261019, bundle `com.getcardpointers.app`, minimum macOS 12.0. The executable is a universal x86_64/arm64 Mach-O. Its SHA-256 is `e5e4947e7c6dd288b50f3b84a26efd7f7df8f20e1b2a0c8f573063ea80c09afa`. This differs from the currently advertised iOS 8.1.5, and version distinctions must be preserved.

A copy of the executable alone is retained in `artifacts/CardPointers-8.1.4-universal`. App Store receipts, user containers, keychains, and existing account data were not copied. A derived arm64 slice was made using Apple's `lipo -thin arm64` for Ghidra's supported import route; its SHA-256 is `447e88aced06f027f75b4037a54f089e6750c0e8dc46e648a56ec416966754d0`. It is a derived artifact, not the universal input identity. No encryption load command was observed in the `otool -l` output for this executable; no encryption bypass was performed.

The minimum macOS value comes from Info.plist. The arm64 build-version command separately records platform MACCATALYST, minimum 15.0 and SDK 27.0; these platform-specific fields are retained separately rather than treated as the same compatibility declaration.

## REA evidence ledger

| Evidence | Exact retained ID | Coverage |
| --- | --- | --- |
| Package inventory | `ev_49d990fa0b0b46eaf3c03fc5b0e414a0db53b89ec573c8f2e5d92dac7a042a80` |167 regular files,119 directory occurrences; full inventory within package |
| Package inspection parent | `ev_ae6b48ee1e55f58a8639df4c4ab3cbc018cced6477c12dc6e8a638c96c3c5e1d` | Static archive graph/hypotheses |
| Apple application projection | `ev_ea9dd48026ce14aa8a28b979b71f9fde2cee333dac98c21d5a59c878997863a3` | Package paths and app-extension roles |
| Main Mach-O | `ev_e2b55f906cb4f7892bf9116465390e95e66761ae60c42c619a4fbd94d312c051` | arm64 slice metadata;105 dependencies,6,096 returned imports,234 returned exports; symbol inventories non-exhaustive |
| Main signature metadata | `ev_9a7472d5ac62be0b4e8636df3fe09934221c9779b683eb27dc586cf00cd4de3f` | Snapshot signing metadata/entitlements, not independent trust verification |
| Main Info.plist | `ev_d133d71e2fcf19be7be9b94471ccd2a6f8aa8d7adea14cd4771f220767a55938` | Parsed shipped configuration |
| Expanded dispatch metadata | `ev_efd3886ab6ff0e0dc4ea8589202f66907974517293e3052d286dbb77eb649378` | Maximum 20,000-record request;1,148 class/metaclass rows,1,853 Objective-C dispatch rows,2,827 ivar rows; partial/unsupported Swift metadata explicit |
| CoreData model full object-table decode | `ev_7ab422a3a5c0172bcad15d4eed7f3c923a7853a895a3e249b0f15ce8f9f6e642` |637/637 NSKeyedArchive objects, no object-table truncation; arbitrary classes not instantiated |

The expanded dispatch result exceeded the MCP transport budget but completed and was retained; it was exported rather than rerun. The initial 3,000-record pass is superseded for coverage purposes by the 20,000-record pass. The reader still reports unresolved ivar pointers, budget limits in some metadata families, and unsupported generic/resilient Swift tables. A completed export is not a claim of complete native semantic recovery.

## Artifact observations

### Native structure and capabilities

The package contains three app extensions: `CPPointersWidgetExtension.appex`, `CPSafariExtension.appex` and `CPWidgetExtension.appex`. The main binary links SwiftUI, CoreData, WebKit, StoreKit, AppIntents and other Apple frameworks. Some frameworks are weakly linked. Framework presence establishes an integration surface, not feature execution.

Signature metadata records team `489M9V6472`, Apple Mac OS Application Signing, app sandbox, hardened runtime and `get-task-allow=false`. Entitlements declare App Groups, network-client access, location, Sign in with Apple, FinanceKit financial-data access and Private Cloud Compute. These are capability declarations; the investigation has not shown a FinanceKit data grant, a cloud inference request, bank access or actual private-data transmission.

Shipped native metadata names dedicated `OfferSyncCoordinator`, `OfferSyncAccountManager`, `OfferSyncCardMappingStore`, `OfferBankCoordinator`, `WalletStore`, `PointersStore` and location/search components. Names and field metadata alone do not prove their control flow or persistence policy. In particular, a field named `capturedPassword` is not proof of persistent banking-password storage or an observed credential transfer.

### Persistent domain model

The shipped CoreData model has 24 entities. `coredata-schema.json` resolves the inert archive's entity/property UID references without executing Objective-C unarchiving. Important structures include:

- `DBPointerCard`: `points`, `total_value`, `order`, `pinned`, merchant/category/pointer identity and inventory relationships.
- `DBPointer`: `top_inventory_id`, `topInventory`, subcategories, offers and merchants.
- `DBInventory`: profile and card relationships, selected bonus categories/plans, approval/closure dates, notes, bonus-earned state and offer-sync identity.
- `DBBonusPlan` and `DBBonusPlanCategory`: period/date and point/spend configuration.
- `DBOfferSyncAccount`, `DBOfferSyncCard`, `DBOfferSyncHistory`: connected issuer/account/card identity and sync outcome/history fields.
- `DBOfferParent` / `DBOfferInventory`: offer conditions, period/frequency, total-used, redeemed date, snooze/hide state and recurring automation flags.
- `DBHost`, `PointerMerchantEntity` and `PointerSubcategoryEntity`: host/merchant/category relationships.
- `DBUserProfile`: wallet/profile membership and related offers.

These are schema observations, not actual wallet records. A stored ordering/value field does not establish whether ranking was computed locally or downloaded. Other stores outside this model may exist.

### AppIntents and Safari boundary

The package's compiled `Metadata.appintents/extract.actionsdata` JSON contains 70 action declarations, including legacy, hidden/non-discoverable and platform/version-specific declarations. They cover card edits, offer edits/redemption/snoozing, best-card/offer queries, search, nearby locations, AutoPilot and AI. This is not a claim that all 70 appear in the user's system UI or are currently usable. The exact resource hash and parsed declarations are retained in local `native-appintents-provenance.json` and `native-appintents-summary.json`, linked to the package inventory; public identifiers are in `app-intents.json`.

The Safari extension resource manifest is 8.1.3, distinct from the host's 8.1.4. The CardPointers extension worker separately analyzed its native-wallet message bridge, including a `getWallet` request and account-mismatch checks; see their deep report. This worker has not executed the bridge.

## Analysis method and completion

Official Ghidra 12.1.3 was acquired from its upstream GitHub release and SHA-256 verified against release metadata. Its public ZIP lacks a mac_arm_64 native decompiler, so the bundled official C++ source was built locally with the existing Xcode clang and copied into this task-local tool directory. Existing JDK 22 satisfies the release's declared JDK 21+ bound. No global REA/client configuration or system dependency installation was changed.

Both scoped Ghidra default-profile analyses completed after a diagnosed tool-path correction: 461 seconds for the main app and 159 seconds for the Safari native extension. The initial default startup deadline and subsequent blocked imports are preserved as superseded attempts. JVM thread diagnostics identified a Swift-demangler subprocess problem: this host's unqualified `swift` was an OpenStack client. Prepending the existing Xcode toolchain to these workers' PATH resolved the issue without disabling analyzers or changing global configuration. See `engine-recovery.json` and `tool-provenance.json`.

The selected main-app and native Safari questions below are complete within their stated static coverage. The main canonical export has 24 records; Safari has 4. Both exports are retained locally with SHA-256/byte counts in `evidence-index.json`. Their structured unknown-entry count of zero is an export-format fact, not a claim that all semantics are known. All owned REA/Ghidra sessions were closed after export, and recorded worker/server/JVM/decompiler PIDs were absent at the final check in `jobs.json`.

A historical coordinated passive UI observation supplements the static findings. At that checkpoint, this worker passively observed PID 2578/window 1406 with screenshot disabled and no actions. REA Evidence `ev_1831e6a489f8666cc897d8097c45df0ec598a05b21d5faceedc6dadc8c53d1ba` contains 44 AX nodes (window, sheet, groups, headings, buttons, text field and pop-up buttons), no truncation and no gaps. Only allowlisted labels and role counts are copied to public `ui-structure.json`; raw AX values remain local. Root resumed GUI work only after capture completion. This bounded structural observation does not verify any reward calculation.


## Native Safari bridge recovered from machine code

The scoped Xcode PATH correction resolved the blocked Swift-demangler phase: the unchanged `ghidra-default` profile completed the Safari binary's auto-analysis in 159 seconds. Selected function results are now available. This confirms that merely extending the timeout was insufficient on this host; no analyzer was disabled to obtain the result.

The native Objective-C entry `SafariWebExtensionHandler.beginRequestWithExtensionContext:` at `0x100001ff8` directly calls the Swift implementation at `0x10000272c`. The implementation decodes the extension request and matches the `getWallet` message. Its reply dictionary contains the fields `token`, `tokenAvailable`, `signedOut`, `pro`, `proAuthoritative`, and `protocolVersion` (constant 2). It obtains the CardPointers own-account `userToken` through `CardPointersShared.KeychainItem.readItem` and reads subscription/signed-out state through App Group defaults under `group.getcardpointers.app`.

The separately inspected keychain helper constructs a generic-password query and calls `SecItemCopyMatching`, then attempts UTF-8 decoding of the returned data. These are decompiled static instructions; this investigation did not execute that helper against the user's keychain or acquire any actual token. A first-use helper also conditionally stores extension-use flags/date/message and a pending-analytics flag. That local flag is not evidence that an analytics request was sent.

This matches the extension worker's independently observed Safari JavaScript `sendNativeMessage(...getWallet...)` call and response/account-identity handling. The meaningful boundary is **native own-account authentication/entitlement state to Safari JavaScript**, which then has its separately analyzed backend-wallet flow. The native `getWallet` branch here does not itself return all wallet card/merchant/offer rows. This is static correspondence across the shipped native and JS components, not an executed message or a statement that any real credential was transferred during this investigation.

Exact function Evidence:

- Entry wrapper: `ev_0a16c67456016b05daa5381cadf41ab4296e2dab260f563982c35ff4146c6318`.
- Native handler implementation: `ev_2d1f780e2209cc805d45abe178ec0e86ee65c5802f840993766713f526208894`.
- Keychain read helper: `ev_bb5d9ca65d158f7d8536acdfde51bb3b2b137c4597b2ed92f9522f4be134df76`.
- First-use helper: `ev_b6f83cd68509b71984ae71789ca19f637d5b9ae7b83efddb8ade096a65c6d005`.
- Independent Safari JS parent: `ev_822ac3d70ae63bad2c8e3449d52ebcf03b3f29409ceb8572c647882705e9101b`.

The compact per-function ledger is `safari-bridge-findings.json`; full local pseudocode/assembly/reference records are preserved in `safari-native-functions-evidence.json`. No vendor machine code or full pseudocode is committed to the PR. Decompiled types/locals retain Ghidra warnings, and unresolved indirect paths remain unknown. The main app findings follow below.


## Main native pointer presentation and value boundary

`PointersStore.controllerDidChangeContent:` at `0x1006e6190` forwards to `0x1006e70b8`. Its implementation cancels an existing DispatchWorkItem and schedules replacement work on the main queue after **400 milliseconds**, through `0x1006e74d0` and `0x1006e6124` to refresh routine `0x1006e61dc`. This is an observed static debounce policy, not measured UI latency. Wrapper Evidence: `ev_f3082c3aa777907071031fd6b0a7509aec91bbb74344833ba7562cafe948c53d`; implementation: `ev_347fc064a34b63358dfc315a31688a66af7b1e269ad3a5c3d1daa49f9d609f82`.

Initialization and lazy fetch setup (`0x1006e5b2c`, `0x1006e592c`, `0x1006e5990`) initialize published/filter state and construct an NSFetchedResultsController using WalletStore's persistence viewContext, a predicate and two sort descriptors. The exact Swift sort keypaths were not resolved. The refresh routine fetches objects, applies search/favorites filtering and publishes results, with optional SwiftUI animation. This selected UI-store path does not recover the underlying reward calculation. Fetch construction Evidence: `ev_32dbb3c7eb67a8bf5f429eaec9110ce9e6a179a49397fae86acc1752a967dd04`; refresh: `ev_32baccdbf0342300f759f81e9d80bce5601d65c3d43f91aa123f3fd3519cea24`.

The selected `DBPointerCard` materializer at `0x101297288` compares incoming structure float fields with the stored `points` and `total_value`, updates changed values, and copies ordering/identity/relationships. The called `0x1012c0ce0` stub resolves to `setTotal_value:`. This routine copies a supplied value rather than revealing a reward-ranking formula. Materializer Evidence: `ev_ef0dc21c4cb87b64dbe4a6da5bf2e32c9e2129f343bc9cd6874d1e653e1db53d`; setter: `ev_c2f5fd8d432bb63541f80481da3a6f3c9d7f213684c4512a5c3b683154f9ee9b`.

Filtering incoming references to actual external entry calls selected parent routine `0x1012778cc`: it calls the materializer at `0x10127bad8` and `0x10127c88c`. Both recovered branches find or create CoreData objects, pass copied input records to the materializer, establish pointerCards relationships, and remove old pointerCards. This establishes a native reconciliation/materialization boundary. It does **not** establish the complete upstream producer, network decoder or server implementation. References Evidence: `ev_8dc5ac1feba7feeb359843f76ae1b1c175d3d28197abf7dd260e03a6d415e109`; parent pseudocode: `ev_4cbce8c4f3c331449191c10549ba1c709c787b2dfca30777a4392c55cd21f35d`.

A selected consumer at `0x1002b7a00` formats stored `total_value` as estimated cents per dollar. Separate welcome-offer display arithmetic multiplies bonus quantity by card point value and divides by 100 for non-Cash currency; Cash takes the bonus amount directly. This display estimate is not proof of the ranking calculation. Evidence: `ev_26b5fe291d996bf025a75097d095daa1a47ccc171a4e9d02c29bf07466812df8`.

Separately, packaged vendor help describes ordering by category multiplier multiplied by configurable card point value, with wallet order as a tie breaker. This is **shipped vendor explanation**, not a verified algorithm or an observed runtime outcome. String-search Evidence: `ev_37fbccc1f8eee331711a7ee8750037c12f2e10bf6eea1ea84eaa519de9e651ce`. Wallet/download/reconciliation log strings and a wallet URL literal also exist, but no direct xref to the selected URL literal was returned; register-built Swift literals can lack such references. Neither request execution nor its absence is proven by that result.

## Completed question matrix and limits

| Question | Final coverage |
| --- | --- |
| Official native identity and derivation | Complete for selected Mac 8.1.4/build 20261019 artifact; iOS 8.1.5 remains a separate advertised version |
| Package/framework/signature/extension inventory | Complete within the stated package/tool coverage; capabilities are declarations |
| Shipped CoreData/AppIntents inventory | All 637 model objects/24 entities and 70 action declarations; no live rows or action execution |
| Pointer model-change handling | Selected wrapper, 400ms debounce, work item and refresh chain recovered |
| Pointer presentation source | Fetched CoreData objects, filtering and published state recovered; exact sort keypaths unresolved |
| Native points/value materialization | Selected writer, setter and two parent reconciliation call sites recovered |
| Value display | Selected cents-per-dollar and welcome-estimate consumer recovered |
| Safari native `getWallet` boundary | Four function dossiers recover own-account auth/entitlement reply and helpers; matched independently against shipped JS |
| Full ranking/server/bank/offer automation behavior | Static-method limit; no full upstream decoder, backend code, complete offer automation paths or executed financial behavior demonstrated |
| Evidence retention and worker cleanup | Main 24/Safari 4 canonical records exported; all owned jobs closed; no runtime fixture pending |

`main-native-findings.json` retains exact operation parameters and Evidence IDs for all 24 main records, plus the per-question assessment. `safari-bridge-findings.json` does the same for the selected bridge findings. Full assembly/pseudocode remains local. Ghidra output includes inferred types, unknown locals and unreachable-block warnings; indirect Swift paths and metadata gaps remain unknown. A completed bounded offline investigation is not a claim that the entire application or remote service has been semantically recovered.
