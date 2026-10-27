# CardPointers Mac REA checkpoint

## Exact selected target

The user requested the Mac equivalent of the apps already installed on their iPhone. Root obtained the official CardPointers Mac app through the Mac App Store, then selected `/Applications/CardPointers.app`. This supersedes the earlier native-acquisition-pending checkpoint.

Observed package identity: CardPointers8.1.4, build20261019, bundle`com.getcardpointers.app`, minimum macOS12.0. The executable is a universal x86_64/arm64 Mach-O. Its SHA-256 is`e5e4947e7c6dd288b50f3b84a26efd7f7df8f20e1b2a0c8f573063ea80c09afa`. This differs from the currently advertised iOS8.1.5, and version distinctions must be preserved.

A copy of the executable alone is retained in `artifacts/CardPointers-8.1.4-universal`. App Store receipts, user containers, keychains, and existing account data were not copied. A derived arm64 slice was made using Apple's `lipo -thin arm64` for Ghidra's supported import route; its SHA-256 is`447e88aced06f027f75b4037a54f089e6750c0e8dc46e648a56ec416966754d0`. It is a derived artifact, not the universal input identity. No encryption load command was observed in the `otool -l` output for this executable; no encryption bypass was performed.

## REA evidence ledger

| Evidence | Exact retained ID | Coverage |
| --- | --- | --- |
| Package inventory | `ev_49d990fa0b0b46eaf3c03fc5b0e414a0db53b89ec573c8f2e5d92dac7a042a80` |167 regular files,119 directory occurrences; full inventory within package |
| Package inspection parent | `ev_ae6b48ee1e55f58a8639df4c4ab3cbc018cced6477c12dc6e8a638c96c3c5e1d` | Static archive graph/hypotheses |
| Apple application projection | `ev_ea9dd48026ce14aa8a28b979b71f9fde2cee333dac98c21d5a59c878997863a3` | Package paths and app-extension roles |
| Main Mach-O | `ev_e2b55f906cb4f7892bf9116465390e95e66761ae60c42c619a4fbd94d312c051` | arm64 slice metadata;105 dependencies,6,096 returned imports,234 returned exports; symbol inventories non-exhaustive |
| Main signature metadata | `ev_9a7472d5ac62be0b4e8636df3fe09934221c9779b683eb27dc586cf00cd4de3f` | Snapshot signing metadata/entitlements, not independent trust verification |
| Main Info.plist | `ev_d133d71e2fcf19be7be9b94471ccd2a6f8aa8d7adea14cd4771f220767a55938` | Parsed shipped configuration |
| Expanded dispatch metadata | `ev_efd3886ab6ff0e0dc4ea8589202f66907974517293e3052d286dbb77eb649378` | Maximum20,000-record request;1,148 class/metaclass rows,1,853 Objective-C dispatch rows,2,827 ivar rows; partial/unsupported Swift metadata explicit |
| CoreData model full object-table decode | `ev_7ab422a3a5c0172bcad15d4eed7f3c923a7853a895a3e249b0f15ce8f9f6e642` |637/637 NSKeyedArchive objects, no object-table truncation; arbitrary classes not instantiated |

The expanded dispatch result exceeded the MCP transport budget but completed and was retained; it was exported rather than rerun. The initial3,000-record pass is superseded for coverage purposes by the20,000-record pass. The reader still reports unresolved ivar pointers, budget limits in some metadata families, and unsupported generic/resilient Swift tables. A completed export is not a claim of complete native semantic recovery.

## Concrete observations so far

### Native structure and capabilities

The package contains three app extensions: `CPPointersWidgetExtension.appex`, `CPSafariExtension.appex` and `CPWidgetExtension.appex`. The main binary links SwiftUI, CoreData, WebKit, StoreKit, AppIntents and other Apple frameworks. Some frameworks are weakly linked. Framework presence establishes an integration surface, not feature execution.

Signature metadata records team`489M9V6472`, Apple Mac OS Application Signing, app sandbox, hardened runtime and `get-task-allow=false`. Entitlements declare App Groups, network-client access, location, Sign in with Apple, FinanceKit financial-data access and Private Cloud Compute. These are capability declarations; the investigation has not shown a FinanceKit data grant, a cloud inference request, bank access or actual private-data transmission.

Shipped native metadata names dedicated `OfferSyncCoordinator`, `OfferSyncAccountManager`, `OfferSyncCardMappingStore`, `OfferBankCoordinator`, `WalletStore`, `PointersStore` and location/search components. Names and field metadata alone do not prove their control flow or persistence policy. In particular, a field named`capturedPassword` is not proof of persistent banking-password storage or an observed credential transfer.

### Persistent domain model

The shipped CoreData model has24 entities. `coredata-schema-summary.json` resolves the inert archive's entity/property UID references without executing Objective-C unarchiving. Important structures include:

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

The package's compiled `Metadata.appintents/extract.actionsdata` JSON contains70 action declarations, including legacy, hidden/non-discoverable and platform/version-specific declarations. They cover card edits, offer edits/redemption/snoozing, best-card/offer queries, search, nearby locations, AutoPilot and AI. This is not a claim that all70 appear in the user's system UI or are currently usable. The exact resource hash and parsed declarations are retained in `native-appintents-provenance.json` and `native-appintents-summary.json`, linked to the package inventory.

The Safari extension resource manifest is8.1.3, distinct from the host's8.1.4. The CardPointers extension worker separately analyzed its native-wallet message bridge, including a`getWallet` request and account-mismatch checks; see their deep report. This worker has not executed the bridge.

## Active deeper analysis

Official Ghidra12.1.3 was acquired from its upstream GitHub release and SHA-256 verified against release metadata. Its public ZIP lacks a mac_arm_64 native decompiler, so the bundled official C++ source was built locally with the existing Xcode clang and copied into this task-local tool directory. Existing JDK22 satisfies the release's declared JDK21+ bound. No global REA/client configuration or system dependency installation was changed.

REA's scoped Ghidra worker has opened the derived arm64 target. The first business-procedure search reached the provider's default330-second startup deadline. A changed-deadline attempt uses the documented per-process `REA_GHIDRA_STARTUP_TIMEOUT_MS=1800000` and retains the default analyzer profile; no completed function results have yet been claimed. Worker PID/session, selected arguments, logs and last checkpoint are in `progress.md` and `native-worker-state.json`; the binary is not being executed. Function-level findings will extend this report when the provider returns.

Root owns interactive native GUI work. At an explicitly coordinated checkpoint, this worker passively observed PID2578/window1406 with screenshot disabled and no actions. REA Evidence `ev_1831e6a489f8666cc897d8097c45df0ec598a05b21d5faceedc6dadc8c53d1ba` contains44 AXnodes (window, sheet, groups, headings, buttons, text field and pop-up buttons), no truncation and no gaps. Only allowlisted labels and role counts are copied to `native-ui-sanitized-summary.json`; raw AXvalues remain local. Root resumed GUI work only after capture completion. This bounded structural observation does not verify any reward calculation.
