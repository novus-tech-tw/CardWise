# CardPointers bounded static follow-up (2026-10-27)

This pass uses the existing CardPointers Mac 8.1.4 arm64 slice (SHA-256 `447e88aced06f027f75b4037a54f089e6750c0e8dc46e648a56ec416966754d0`). It is not iPad execution. No binary import, application launch, account access or whole-image analysis was repeated.

## Fetch presentation sort keys resolved

The existing fetch-construction dossier for `0x1006e5990`, Evidence `ev_32dbb3c7eb67a8bf5f429eaec9110ce9e6a179a49397fae86acc1752a967dd04`, has exact assembly that loads patterns `0x101316270` and `0x1013162a0` into `swift_getKeyPath`. These are passed in sequence to the Foundation `NSSortDescriptor` initializer with `ascending=false` and `ascending=true`, and stored in the sort-descriptor array in that order.

The digest-verified pattern bytes have signed-relative KVC string references at pattern+16. Resolving the first field `0x101316280 + (-32)` yields `is_favorite` at `0x101316260`; resolving the second field `0x1013162b0 + (-24)` yields `name` at `0x101316298`. Thus this selected fetch path sorts **is_favorite descending, then name ascending**. This closes the previous unresolved key-name question. It does not recover the reward calculation or prove runtime results.

The compact header interpretation is corroborated by the official [Swift runtime implementation](https://github.com/swiftlang/swift/blob/main/stdlib/public/core/KeyPath.swift): the runtime advances the incoming pattern by four bytes, then resolves the signed-relative KVC field twelve bytes into that adjusted header. Exact bytes, mappings, source Evidence and verification assertions are retained in `sort-keypaths.json` and reproducible with `decode-sort-keypaths.py`.

## Metadata budget isolated for two classes

The existing maximum 20,000-record metadata Evidence `ev_efd3886ab6ff0e0dc4ea8589202f66907974517293e3052d286dbb77eb649378` was read completely. Its shared record budget is exhausted across families; retained pagination cannot restore metadata that the producer never decoded. The REA 6.5.0 CLI schema accepts no facet/offset selector and caps `maxRecords` at 20,000. Its source processes Objective-C, Swift conformances and class vtables under one budget.

A focused analyst script reused the installed REA 6.5.0 `parseMachoLayout` and `decodeSwiftClassVtables` exports, giving the existing class-vtable decoder a fresh bounded budget and only the exact `PointersStore` and `AppCommandsPointersStore` descriptor entries. The name-selection scan visited all 3,124 `__swift5_types` entry fields with no selection failures. It selected exactly two descriptors. The focused reader emitted 39 slot records, resolving nine implementation addresses; 30 remained partial under the reader's existing async/coroutine/external/unmapped limits. It used 41 of a separate 300-record budget, so this focused pass is not budget-truncated.

For `PointersStore`, decoded slot 30 points to the already analyzed lazy fetch accessor `0x1006e592c`, and slot 38 to the already analyzed refresh routine `0x1006e61dc`. This corroborates those selected structural bindings. Slot indices are metadata word offsets, not source method ordinals. No source property names are inferred for the unresolved slots.

`focused-vtables.json` and `focused-vtables.mjs` retain the exact selected type-entry fields, descriptor locations, reader results and limitations. These new files are analyst-produced static evidence, not new REA MCP Evidence records. Whole-application metadata completeness, generic/resilient tables and reward/server behavior remain unproven.
