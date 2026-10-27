# MaxRewards focused offline binding followup

Completed 2026-10-27. This supplement answers two previously unresolved binding questions using the already acquired official iPhone/iPad-compatible-on-Mac MaxRewards 4.8.35 Hermes96 resource. It is not evidence of execution on the newly connected iPad. No application was launched, no user container or stored secret was read, and no network request or bank action was performed.

Carrier: `maxrewards/native/main.jsbundle`, 12,633,156 bytes, SHA-256 `efe8a8901364e9a633d0edb1810687f18932ebaf306995c235fccaef23278ba9`. Decoder: existing P1sec/hermes-dec source commit `2e796663e1fedb93dca51060797ebf3327b3fedb`. The labels below are local static-analysis references, not REA MCP Evidence IDs. Source-bound disassembly and closure/module arguments establish the findings; function names alone do not.

## MRF-01: reward-row comparator has a concrete screen caller

**Observed.** The root `__d` registration binds F67341 to module 8470. F67341 stores F67344 `sortBestCardRewardsRows` in environment slot 6 (`0xc5–0xcc`) and F67359 `normalizeCardRewards` in slot 16 (`0x133–0x13a`). Within F67359, `GetEnvironment 0` selects that module environment, and `0x1b8–0x1c2` obtains `.sort`, loads slot 6, and calls the sort with that comparator. The sorted array is returned as the card object's `rows` at `0x29e`.

F67341 exports `normalizeBestCardRewardsCards` through getter F67342, which returns slot 17/F67371. F67371 flatMaps the supplied cards through closure F67372; that closure accesses the enclosing module's slot 16 and invokes F67359 with the captured arguments.

The root registration also binds F67281 to module 8465, whose dependency index 16 is module 8470. F67281 imports that dependency into environment slot 15 (`0x171–0x17d`) and creates F67284 `BestCardRewardsScreen` in the same environment (`0x24d`). F67284 accesses slot 15's `normalizeBestCardRewardsCards` property and calls it at `0xf6–0x10e` when its memoization inputs require recomputation. This closes the static chain from this screen to the comparator.

**Inference.** For this recovered screen's card-reward normalization, each card's reward rows are ordered by descending `percent`, with a `progress` row preferred on a percentage tie and otherwise type-name locale comparison. This follows the already analyzed F67344 comparator and the newly resolved caller chain.

**Limit.** This is within-card row presentation, not a proof that wallet cards or merchant recommendations use that comparator. No screen was executed and no server ranking policy or current iPad build equivalence is established.

## MRF-02: typed string storage wrappers use a constructed MMKV instance

**Observed.** F16129 is registered as module 1485, with dependencies `[20, 1486, 1497]`. It creates F16155 `loadString` and F16158 `saveString` using its environment at `0x404` and `0x41f`. Both wrappers access environment slot 23: F16155 calls its `.getString` (`0x3–0x13`); F16158 calls its `.set` (`0x6–0x15`).

F16129 imports dependency index 1/module 1486, obtains `.MMKV`, constructs it without an explicit configuration argument, and stores the resulting object in slot 23 (`0x443–0x45d`). Module 1486/F16163 imports module 1487 and forwards its nondefault exports through F16165/F16166. Module 1487/F16169 explicitly exports `MMKV` through getter F16171; the getter returns its slot 7. Slot 7 is the result of class-building helper F16172, which creates constructor F16173 `MMKV`. Thus the previously unresolved provider is statically bound to this shipped MMKV class, rather than merely sharing an identifier name.

The F16173 constructor's no-argument path creates a configuration object with `id: 'mmkv.default'` (`0x18–0x1e`). Its ordinary branch calls imported `createMMKV` with that configuration (`0x5d–0x67`), while a separate `isTest` branch creates a mock. F16196 `createMMKV` subsequently calls the MMKV TurboModule's `createMMKV` (`0x96–0x9c`); it also conditionally asks the platform-context module for an App Group directory when no path is supplied. These are shipped branches, not executed platform results.

**Inference.** The selected wrappers are intended to use a default MMKV-backed store in the ordinary native route. The recovered call site does not supply an explicit JavaScript encryption-key configuration.

**Limit.** This does not establish actual device file contents, native at-rest protection, Keychain usage elsewhere, a complete token lifecycle, or an absence of encryption in all layers. No storage API was called by this investigation. Current runtime overrides, native implementation details, and iPad build identity remain outside this evidence.

## Method and coverage

- Reused existing disassembly, then performed a new exact direct-function/identifier reference selection for these binding questions. The seed pass traversed all 68,786 headers / 49,418 distinct bytecode bodies / 2,098,689 instructions with zero decode errors. Its inventory is not a semantic review of all matches.
- `focused-bindings.json` retains seed/identifier references and generated candidate disassembly identities. `round2.json` retains the changed target selection and exact root/screen contexts. `module-bindings.json` preserves the selected module registrations and dependency arrays.
- `evidence.json` records carrier and selected source-span/output digests, plus the chain anchors. Only the selected regions needed for MRF-01/MRF-02 were interpreted. Extra candidate outputs are retained locally without claiming they were semantically reviewed.
- `validation.json` verifies the carrier, selected source bytes, retained disassembly identities and expected instruction anchors. Original bytecode, raw disassembly and scripts remain local. Compact findings may be integrated into the investigation report.

Both selected binding questions are answered within static scope. The limits above remain; no login or user action is required for this supplement.
