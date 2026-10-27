# Unattended offline REA method

The active investigation uses this method after the user requested an approach without repeated authentication or manual demonstrations. Both official apps and their browser extensions have already been acquired, so no further account access is needed to finish this scope.

## Inputs are acquired once, then frozen

Record the distribution source, product/version/build, architecture, artifact SHA-256, and extracted or derived identities. Keep original app packages separate from architecture slices and decoded representations. Do not copy receipts, keychains, live user containers or bank records into the analysis inputs.

The selected native targets are CardPointers Mac 8.1.4 and MaxRewards iPhone/iPad-compatible 4.8.35. The selected Firefox extensions are CardPointers X 8.0.8 and MaxRewards 0.1.7. These are distinct artifacts; a bridge resource can have a different version from its native host.

## Independent static work runs in parallel

| Track | Method | What it can establish |
| --- | --- | --- |
| Native package structure | REA package inventory, Mach-O/signature/plist inspection, application graph | Shipped components, architecture, linked interfaces, capability declarations and target identity |
| Native domain data | REA inert archive/model decoding and compiled metadata inspection | Stored schema, relationships and declared intent surfaces; not real user records or executed behavior |
| CardPointers native functions | Scoped Ghidra provider on the explicit arm64 app/extension snapshots | Function bodies, calls and value-flow evidence within recovered native code |
| Browser extensions | REA JavaScript analysis with exact-file/factory provenance and bounded partitions | Shipped request/handler/cache/entitlement branches, ordering and data boundaries |
| MaxRewards native client | Pinned offline Hermes decoder on the separately shipped HBC96 bundle | Exact bytecode instructions and selected pseudocode/control flow; not original JavaScript source |
| Independent recommendation cross-check | Full function/identifier inventory followed by exact candidate disassembly | Cap/category/date/choice/bonus and valuation logic supported by the inspected client functions |

The JavaScript REA CLI supports a task-local extracted extension without native engines:

```sh
rea analyze-javascript-application /absolute/path/to/extracted-extension --json
```

For a new distribution, first inventory it and choose exact relevant sources. A complete summary projection is not complete semantic analysis. Large graphs are analyzed in source-bound partitions with exact original offsets/digests; omitted outer bindings and dynamic dependencies remain explicit. Reuse retained Evidence rather than re-running a producer to recover a truncated display.

Ghidra uses the task-local verified tool distribution, existing JDK, and scoped process environment documented under `native/`. Job IDs/logs and selected artifacts are recorded in [native progress](native/progress.md) and [job snapshots](native/jobs.json); all investigation jobs are now closed. The apps themselves are not executed for this native code pass. MaxRewards' main Mach-O encryption is not bypassed: its separately shipped unencrypted Hermes bytecode is a different, legitimate static carrier.

## Completion is evidence-based

For each question, record the exact artifact/function/offset, Evidence ID or offline decoder provenance, coverage, conclusion and remaining unknowns. Finish all declared reachable static work and resource-recovery passes before marking the offline investigation delivered.

Static code can show a branch that constructs a bank request, a value fallback, or a ranking comparator. It cannot establish that an actual bank accepted the request, that a server used a particular hidden formula, or that every paid feature works for a real account. Those are limits of the method and do not require another login request under this scope.

The PR contains reports, digests, schema and compact ledgers. Full vendor distributions, decoded code, large Evidence and historical private UI observations remain in the retained local archive. Final validation checks exact identities, report links, JSON parsing, intended Git paths and PR CI.
