# CardPointers wallet input provenance: focused continuation

The subsequent [wallet network continuation](cardpointers-wallet-network.md) closes the selected network-data → typed-decoder → persistence-input edge that remained open at this checkpoint.

Date: 2026-10-27. This pass reuses the saved native pseudocode and materializer dossier, then reads selected Swift reflection records and selected instruction ranges from the unchanged Mac 8.1.4 arm64 carrier. It does not import the image again, execute the app, inspect user storage or contact the iPad. The source SHA-256 remains `447e88aced06f027f75b4037a54f089e6750c0e8dc46e648a56ec416966754d0`.

## CPW-01: the candidate input types are now concrete

The selected accessor at `0x10123bac0` loads nominal descriptor `0x1013d9cbc`. Its relative name is **NewDataResponse**, with three reflected fields: `wallet`, `user`, and `paywall`. The wallet field's direct symbolic reference resolves to descriptor `0x1013d9dfc`, **Wallet**. Its first vectors are `cards_sponsored`, `cards_user`, `pointers_user`, and `cards_popular`; other fields include offers, favorites and merchants.

Wallet's `pointers_user` is an array whose indirect symbolic reference points through `0x101828c58` to **Pointer**, descriptor `0x1013d9f64`. The relevant Pointer fields are `id`, `cards`, `sort_order`, `top_card_id`, `name`, `topCard`, `subcategories`, `pinned_id`, and `top_inventory_id`. Its `cards` array references **PointerCard**, descriptor `0x1013d9f80`, with these fields in reflection order:

| Field | Encoded type | Narrow meaning established |
| --- | --- | --- |
| points | `Sf` / Float | Supplied numeric reward-rate value |
| total_value | `Sf` / Float | Separate supplied numeric value |
| feature | `SS` / String | Supplied explanation/presentation field |
| sponsored | Optional Bool | Distinct supplied flag |
| card_id / card | Optional Int / optional Card | Card identity and nested value |
| color | Optional String | Presentation |
| order | Optional Int | Explicit supplied order, separate from points/value |
| inventory_id | Optional Int | Wallet inventory identity |

`wallet-field-provenance.json` retains all 37 selected field records, exact file addresses, raw mangled bytes and symbolic-reference resolution. Indirect references use the image's declared chained-pointer format **6**, not an arbitrary mask of a runtime address. The decoder rejects binds, nonzero high bits and other pointer formats. It uses the installed Apple SDK's `mach-o/fixup-chains.h` and Swift's [field records](https://github.com/swiftlang/swift/blob/main/include/swift/RemoteInspection/Records.h), [type descriptor layout](https://github.com/swiftlang/swift/blob/main/include/swift/ABI/Metadata.h), and [symbolic-reference rules](https://github.com/swiftlang/swift/blob/main/docs/ABI/Mangling.rst).

**Limits:** reflection field order is not a runtime field-offset vector. A type called NewDataResponse does not independently prove an HTTP response, decoding execution, endpoint identity or server calculation. The following instruction/data-flow corroboration narrows this candidate input interpretation.

## CPW-02: input rows reach persistence without a score computation in the selected copy-to-call spans

The already retained parent `0x1012778cc`, Evidence `ev_4cbce8c4f3c331449191c10549ba1c709c787b2dfca30777a4392c55cd21f35d`, reads vectors from its second argument. Its normalized pseudocode lines 552–574 retain those reads. Lines 2177–2224 iterate a vector with row stride `0x3f8` and take the per-row card vector at `+0x38`; that layout is consistent with the reflected Wallet/Pointer chain, but the nominal-type-to-runtime-layout binding remains an inference.

Lines 2498–2524 copy `0x3b1` bytes from each supplied card record into a local value and call `0x101297288` with it. Lines 2542–2547 advance the source by `0x3b8`. The subcategory branch similarly copies `0x3b1` bytes and calls the same materializer at lines 2996–3023. The already recovered concrete call sites are `0x10127bad8` and `0x10127c88c`, respectively. Matching existing records or creating Core Data objects surrounds these calls; no reward formula is introduced in the selected copy-to-call slices.

The **reused** materializer dossier, Evidence `ev_8dc5ac1feba7feeb359843f76ae1b1c175d3d28197abf7dd260e03a6d415e109` for incoming call references, and `main-native-pointercard-materialization.json` for instructions, shows this map:

| Source record bytes | Persistence operation |
| --- | --- |
| `+0x0` Float | Compare with existing `points`, set when different |
| `+0x4` Float | Compare with existing `total_value`, set when different |
| `+0x398` Int, optional tag at `+0x3a0` | Set `order` only when supplied |
| `+0x3a8` Int, optional tag at `+0x3b0` | Compare/set or clear `inventory_id` |
| Supplied card/inventory IDs | Resolve related existing objects through dictionaries/arrays |

Thus the inspected persistence boundary **consumes** rate/value/order rather than deriving their complete origin. This is stronger than a string match and narrower than a claim that all native ranking happens remotely. Local transformations before this boundary remain possible.

## CPW-03: a new capture handoff narrows the unresolved edge

An offline scan of aligned immediate ARM64 `B`/`BL` instructions finds one direct caller of the parent: `0x10128084c` in `0x1012807d0–0x101280863`. This excludes indirect dispatch and is not an exhaustive call graph. A focused disassembly shows the thunk computing a capture's aligned NewDataResponse offset, passing its address as argument 1 and calling the parent.

A bounded ADRP/ADD reference finds the thunk captured at `0x1012776ac` in funclet `0x101277458–0x1012776ff`. That funclet references the NewDataResponse accessor at `0x1012775cc–0x1012775dc`, copies the value through helper `0x1000b2c00` at `0x10127764c–0x101277658`, and hands the thunk plus capture to a continuation at `0x1012776e4` (`br x2`). The relative descriptor at `0x1013a6a20` resolves to **0x101277170**, which reaches the imported `NSManagedObjectContext.perform(schedule:_:)` stub at `0x1012772c0`. The image's indirect symbol table identifies stub `0x1012b3244` with that exact Core Data import; `0x1012b5338` is `swift_task_switch`. This closes the persistence-scheduling handoff. It is not an HTTP decoder or scoring function. The objdump nearest-symbol headings are unrelated preceding symbols and are intentionally ignored; claims use exact instruction addresses.

**Current status: partial.** The new evidence links concrete input type candidates, a capture/copy handoff, parent vectors, persistence fields and the previously decoded value consumer (`0x1002b7a00`, cents-per-dollar/welcome presentation). The remaining origin is the callback/decoder/producer before the capture, including any transformation of `PointerCard.points`, `total_value` or `order`. It is not yet justified to label that entire unresolved client edge hidden server computation. No Ghidra re-import or device retry was used to obtain these findings.

## CPW-04: selected Decodable witnesses and actual field decoding

A new finite metadata query resolves the four selected types' **Decodable** conformances. Their protocol binds to imported `_$sSeMp` (Swift.Decodable), and their resilient requirement binds to `_$sSe4fromxs7Decoder_p_tKcfCTq` (the decoder initializer). The selected conformance records carry flags `0x30000`: the witness-table-pattern relative field is **null**, and the implementation comes from the resilient-witness entry. Treating a null relative pointer as a table at its own field address would be incorrect. Generic runtime witness-table instantiation was not executed.

| Type descriptor | Conformance | Decoder witness |
| --- | --- | --- |
| NewDataResponse `0x1013d9cbc` | `0x1013a1458` | `0x10121dac0`, calls `0x10121d6f0` |
| Wallet `0x1013d9dfc` | `0x1013a1888` | `0x10122101c` |
| Pointer `0x1013d9f64` | `0x1013a2160` | `0x1012293ac` |
| PointerCard `0x1013d9f80` | `0x1013a2250` | `0x101229d88`, calls `0x1012450f4` |

The PointerCard witness copies **0x3b1 bytes** from the successful initializer output (`0x101229da8–0x101229db8`), matching the parent reconciliation copy size. Its initializer calls the imported `Decoder.container(keyedBy:)` at `0x1012451d4`. The selected CodingKeys metadata at `0x101820b40` resolves to descriptor `0x1013da2d8`, whose reflected cases are exactly `points,total_value,feature,sponsored,card_id,card,color,order,inventory_id` in that order.

For key index **0**, the call at `0x101245200` reaches the imported `KeyedDecodingContainer.decode(Float,forKey:)`, and `0x10124520c` stores returned `s0` at local `+0xe38`. Key index **1** uses the same Float decoder at `0x101245224` and stores at `+0xe3c`. No scoring arithmetic intervenes in these selected return-to-store spans. The initializer sets key index **7** at `0x1012453e4`, invokes the optional-integer decoder at `0x1012453f8`, stores its value at local `+0x11d0` and optional tag at `structBase+0x3a0`. The relative offset `0x11d0-0xe38 = 0x398` matches the materializer's `order` read.

**New conclusion:** the inspected type has an actual keyed-decoding path for supplied `points`, `total_value` and optional `order`; these are not merely coincidental field-name strings. This closes the selected decoder-to-struct-to-persistence interpretation. It does not prove which network/cache/data source supplied the Decoder or that every caller uses these synthesized initializers. The producer before that input boundary and any other local ranking path remain unresolved. New selected-conformance/decoder evidence is retained locally; no main-image Ghidra analysis was repeated.

## Retained outputs

`read-wallet-fields.py`, `wallet-field-provenance.json`, `wallet-parent-direct-callers.json`, `response-accessor.asm`, `wallet-parent-thunk.asm`, and `wallet-capture-handoff.asm` remain under `continuation-20261027/cardpointers-wallet/` in the original local archive. The public ledger retains exact source/output digests and selected evidence spans without redistributing the app.
