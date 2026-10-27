# MaxRewards LockWidget: finite clear-code path and encrypted dispatch boundary

This new offline pass analyzes **only the previously unimported MaxRewardsLockWidget extension**. It does not repeat the main, category or Live Activity imports. The earlier `native-reader-boundary.md` and its current digest manifests are intentionally preserved as the prior checkpoint; this report supersedes only its statement that LockWidget had received header/resource inspection alone. New evidence, coverage, validation and hashes are isolated under `lock-widget-native/`.

## Fixed acquired source and exclusion

- Carrier: `/Applications/MaxRewards.app/Wrapper/MaxRewards.app/PlugIns/MaxRewardsLockWidget.appex/MaxRewardsLockWidget`.
- Acquired bundle ID: `com.max.MaxRewards.MaxRewardsLockWidget`, version **4.8.35**, build **1792099341**, arm64, **149,360 bytes**, minimum iPhoneOS **16.0**, WidgetKit extension point. These identities reuse the prior acquired plist/header inventory.
- Executable SHA-256: **`c8cf678113102892d46a77919a572e239ee68fd1a6f66be637d40520ce44e599`**.
- `LC_ENCRYPTION_INFO_64`: **cryptid 1**, **`[45056,49152)` / `[0xb000,0xc000)`**, 4,096 bytes. This intersects the final **1,392 bytes of `__text`**, **all 1,476 bytes of stubs**, and **1,216 bytes of `__const`**, plus padding. Clear `__text` is `[16384,45056)`.

All function-body semantics below come from ranges entirely before that interval. No encrypted stub, conformance descriptor or name bytes were interpreted as code/metadata semantics. Imported API labels are corroborated by **clear undefined symbol/import metadata** and demangled signatures, not by the encrypted stub bodies. The local ledger independently decodes nine branch instructions from the original clear bytes to confirm their target addresses. `selected-clear-import-bindings.json` additionally maps their seven imported targets through the clear section header, indirect-symbol table and nlist/string table, without decoding encrypted stub instructions. This validates the call edge and imported name, not the encrypted target implementation.

REA 6.5.0 / task-local Ghidra 12.1.3 / JDK22 were reused. The existing Xcode `swift-demangle` directory was prepended to the child process PATH only. No installation, global configuration repair, decryption, application launch or target execution occurred.

## Selection from protocol and field metadata

The prior bounded literal search found no `categoryList` or App Group candidate for this extension. This pass therefore started from the named **`StaticConfiguration`**, **`TimelineProvider`**, **`TimelineEntry`**, `Timeline(entries:policy:)` and `TimelineReloadPolicy.after` imports. Their candidate inventory is `ev_682489b20fc91981fb5a6f3691bba4a463de875ec49c8918ab599e9782fe79a0`; exact demangled ABI signatures are retained in `ev_258f97ff51a1026ff7f3da78537d80bc7f1bf8be14c4660e73ad2efc41644676`.

Only three small clear metadata-string sections were parsed: 713-byte `__cstring`, 53-byte `__swift5_reflstr` and 146-byte `__objc_methname`. The selected Swift entry descriptor at file `0xcb00` declares **one field**. Its clear field descriptor `0xcf68` names that field **`date`**, and the selected entry initializer copies a Foundation Date through its value witness. The descriptor's **type-name pointer targets file `0xbd50` inside the encrypted page**, so no original entry type-name claim is made. This is recorded explicitly in `entry-field-metadata.json`.

## Clear entry → value → timeline path

A clear forwarding routine at **`0x100004a10–0x100004a53`** calls the complete timeline-building routine **`0x1000042dc–0x1000047e7`**. The latter:

1. Creates a current Foundation Date (`0x100004594`) and copies it into the one-field entry through **`0x100004040–0x10000407f`** (`0x1000045a0`).
2. Uses Calendar.current with the **hour** component and value **12** (`0x1000045b8–0x100004610`).
3. If Calendar supplies a date, uses that date. If it returns none, computes **Date + 43,200 seconds**; the clear floating-point construction is at `0x1000046b4–0x1000046c0` (`0x40e5180000000000` = 43200.0).
4. Allocates a **single-entry array**, copies the entry into it, calls `TimelineReloadPolicy.after` at **`0x10000474c`**, creates `Timeline(entries:policy:)` at **`0x100004774`**, and calls the supplied completion callback at **`0x100004784`**.

Thus this selected routine requests a **12-hour refresh**, with a 43,200-second calendar-nil fallback. This is a WidgetKit scheduling request, not proof that the OS executes exactly 12 hours later. The complete selected timeline body has no App Group/key read, JSON decode, category/card payload evaluation, network request or empty-category fallback branch. That bounded absence does not assert that every byte of the extension has been semantically audited.

A separate clear date-default builder, **`0x1000040a8–0x100004127`**, also constructs Date.now and calls the same Date-copy initializer. Its forwarding wrapper is retained, but its exact placeholder-versus-snapshot protocol slot is **not claimed**, for the dispatch reason below.

Primary function evidence:

| Evidence ID | Canonical clear function | Role |
| --- | --- | --- |
| `ev_70401de4ef0daf51b22ce679985425439aac0dd88dffb315b6c2da09647189d6` | `0x100004a10–0x100004a53` | Forwarding entry to timeline routine |
| `ev_f7efb46832d41e83aeaceadbea4768aa40e01a348a77f1711fea8d5060036a28` | `0x1000042dc–0x1000047e7` | Date, +12 hours, fallback, Timeline and completion |
| `ev_819ef99137546d32b2d487884ea4f3d7034d838a0cb46b5fd6d4b8b743324a80` | `0x100004040–0x10000407f` | Date value-witness copy into entry |
| `ev_d26fe1f09e7ec4da22bb6355e057716cc30c16b10e8aaf293d489982f1f3f83d` | `0x1000040a8–0x100004127` | Date.now default builder |

## Configuration and selected output

Configuration routine **`0x100005f30–0x1000063d7`** calls the imported `StaticConfiguration` initializer at **`0x100006158`**, supplying content closure **`0x1000063d8`**. That closure copies the entry into the selected view through `0x100005e94` / `0x100007fc8`; the latter copies the Date. The configuration declares:

- Display name **`MaxRewards`**.
- Description **`Open MaxRewards from your Lock Screen.`**
- Supported family array containing **one `WidgetFamily.accessoryCircular`**.

View routine **`0x100004c0c–0x100004ee3`** obtains an optional URL from **`0x100005938–0x100005a57`**, attaches it with the imported `widgetURL` modifier at **`0x100004dc8`**, and adds accessibility label **`Open MaxRewards`**. The URL constructor appends the fixed clear suffix:

```text
://widget/best-card-location?liveActivity=best-card-nearby
```

Its scheme comes from **`0x100007318–0x100007727`**: it obtains the extension main bundle identifier, splits on `.`, chooses **`production`** when there are at most four components (or no identifier), otherwise selects the penultimate component, then interpolates **`maxrewards+<variant>`**. The acquired identifier has four components; **if that identifier is the runtime main-bundle identifier**, the resulting URL is:

```text
maxrewards+production://widget/best-card-location?liveActivity=best-card-nearby
```

That URL value is passed through Foundation's optional URL initializer to `widgetURL`. The selected constructor contains no alternate URL branch. The shipped configuration and URL attachment support a **Lock Screen launcher into the nearby-card / Live Activity app route**; they do not establish that the extension itself reads or displays the category payload. Neither a successful tap nor the receiving app's subsequent navigation/Live Activity request was executed in this pass. The URL's receiving JS behavior is covered separately in the existing P2 report, not treated as native execution evidence here.

Configuration evidence is `ev_951aaafd282fb8b121dd31910cd2b4f533452566d807c56ef1660c547137b8d6`; content closure evidence is `ev_000d5ef216feb3caa50b0c57f3554db44768b9926de44abc56e69a210cfdfde0`; URL-view evidence is `ev_4c6ffbd2079f2563f5e16a79cefab0c1259b9905da3ef77ef5b0200a589a1e65`; URL-constructor evidence is `ev_66c758ba56f5d2fce8b4ab82ec923149a6ac4635468b99334afe895c10aea2ce`; variant/scheme evidence is `ev_73ba5d300a817f4825b263918546bd7e9a6673187e9f7cb6f8f431883ee8ec58`.

## Exact clear-to-encrypted dispatch limit

The configuration's provider-conformance getter **`0x1000080d8–0x10000813f`** is clear. On cache miss it materializes argument **`0x10000bbf4`** at `0x100008100–0x100008104`, supplies local type metadata at `0x100010628`, and calls the imported Swift witness-table runtime at **`0x100008114`**. **The conformance descriptor at file `0xbbf4` / 48116 lies inside `[0xb000,0xc000)`**. Its bytes and protocol-slot semantics are excluded.

Therefore the following are distinguished:

- **Established:** the complete clear timeline subroutine, its Date-only entry, 12-hour/fallback policy and callback; the configuration call site with provider witness materialization; the content closure's entry copy; the view's optional deep-link URL attachment and accessibility label.
- **Limited by encrypted metadata:** exact mapping of `0x100004a10` and the Date.now-default forwarder into the operating system's TimelineProvider witness slots. A cross-reference returned by Ghidra does not supply the missing descriptor semantics. No claim is made that a specific slot was decoded or that WidgetKit invoked it at runtime.
- **Also excluded:** the Date-entry descriptor's type-name target at **`0x10000bd50` / file 48464**, and all encrypted import-stub bodies. API names are from separate clear imports; none is justified by treating encrypted bytes as valid assembly.

Provider-conformance getter evidence is **`ev_13f54d60e35aa976a096640bf545c052deec8a9c2c3043f6edd48698d74ceee6`**. These limits leave a useful static path without inventing a shared `categoryList` reader or claiming the whole carrier is opaque.

## Validation and lifecycle

`lock-widget-native/function-anchor-coverage-ledger.json` binds **16 unique selected clear functions**, **15 assembly anchor regions**, source hashes, complete canonical body ranges and body-span hashes. All 16 bodies have **zero overlap** with the encrypted interval. Nine selected call branches were decoded independently from the shipped instruction words. `address_to_file_offset` confirms the timeline-call and URL-constructor mappings (`ev_19f1335890d2f835c7190cbd61d7261e24c8be30d97e33ae673792882e93fa58`, `ev_f57cef4f68a6c4fb3ea7a79a582e0f5062d0e7572486b32d5751d8fdc6d3cdf5`). This is a finite path pass, not a whole-extension semantic audit.

The private worker's **single new target** was exported to `lock-widget-native/evidence-bundle.json` (**26 records**), then `close_binary` and the MCP client were closed. The owned worker and execution session exited; a host-only process check confirms the worker absent. Exact process/session locators remain local. `job.json`, `close.json`, `lock-worker-state.json` and `worker.log` preserve the lifecycle. No other session was altered.

`lock-widget-native/validation.json` records the successful checks. `protected-digests.json` verifies that the earlier **`native-reader-boundary.md`**, **`native-reader-boundary.json`**, root **`hashes.json`**, and **`native-analysis/hashes.json`** remain byte-for-byte unchanged. The new `lock-widget-native/hashes.json` covers only this new pass, including this report by relative parent path. No prior manifest was regenerated.

All results are shipped-artifact static observations or explicitly marked inference. No device operation, HTTP/network request, server, authentication access, application storage access, target execution or repository edit occurred.
