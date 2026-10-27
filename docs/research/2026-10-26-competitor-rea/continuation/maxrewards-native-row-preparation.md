# MaxRewards Live Activity native row-preparation closure

The previously unexpanded helper is **`0x100046170`**, entered from state preparation `0x10003f638` and switched to body **`0x1000461e4`**. Its row policy is recoverable from the clear shipped bytes: use the payload's rows or an empty array, take **the first three in existing order**, and append one reconstructed row per selected input. It preserves all row fields except that an absent `cardImageFileName` can be filled by an asynchronous image helper. It does not rerank rows, select by reward value, filter by location/eligibility, or compare the payload timestamp/age in this finite path.

This is offline static analysis of the already acquired **iPhoneOS MaxRewardsLiveActivity extension 4.8.35 / build 1792099341**, bundle `com.max.MaxRewards.MaxRewardsLiveActivity`. Source executable: `/Applications/MaxRewards.app/Wrapper/MaxRewards.app/PlugIns/MaxRewardsLiveActivity.appex/MaxRewardsLiveActivity`, SHA-256 **`6801204ee710b2b4bbfd50cf8b57b0816601c6b9a734be445d149ef55aa640e3`**. The hash matches the retained extension identity ledger. No target, image download, preference read/write, device, UI, or network operation was executed. No Ghidra import or repeated whole-app producer was run. Existing dossier exports and their hash manifests are unchanged; new files are confined to this subdirectory.

**MRNR-01 — Exact input and return boundary.** The existing state body supplies its payload pointer in `x20` at `0x10003f7e8`, installs return continuation `0x10003f820` at `0x10003f7dc–0x10003f7e4`, and tail-branches to `0x100046170` at `0x10003f7f8`. That existing helper entry saves the payload pointer in async-frame slot `+0x490` (`0x100046188`) and switches to `0x1000461e4`; no new decompilation of those existing regions was needed.

The new body restores that pointer at `0x10004620c` and loads the payload's optional rows word at **payload `+0x20`** (`0x100046234`). Selected clear Swift field metadata declares payload fields `title`, `updatedAtLabel`, `rows`, and `timestamp`; the existing state-preparation dossier supplies the matching layout context. The helper returns a Swift row array in `x0` through its installed async continuation, rather than a complete content state.

The reused `0x10003f820` stores the returned array in parent frame `+0x138`, deallocates the child frame, and switches to reused `0x10003f894`. That function passes the array into content-state construction. Its already-recovered timestamp/title/update-label behavior remains separate: this helper does not update those payload fields or choose `staleDate`.

**MRNR-02 — Prefix, order, cardinality, and missing-image behavior.** The body initializes an empty output array at `0x10004621c–0x100046230`. A non-nil payload rows array is used; nil rows create an empty input (`0x100046254–0x1000462ac`). The `3` argument is materialized at `0x1000462d8` and supplied at `0x1000462e0` to the import bound exactly to `Swift.Collection.prefix(Int)`. `makeIterator` follows at `0x100046330`, then `IndexingIterator.next` at `0x100046380`; subsequent iteration resumes at `0x100046b34`.

The selected row type is **`BestCardNearbyRow`**. Its clear nominal descriptor and runtime field-offset vector bind all twelve fields:

| Byte offset | Field |
| ---: | --- |
| `0x00` | `id` |
| `0x10` | `kind` |
| `0x20` | `merchantName` |
| `0x30` | `cardName` |
| `0x40` | `badgeLabel` |
| `0x50` | `offerTitle` |
| `0x60` | `spendLabel` |
| `0x70` | `progress` |
| `0x80` | `paymentService` |
| `0x90` | `cardImage` |
| `0xa0` | `cardImageFileName` |
| `0xb0` | `cardArt` |

The loop copies a 192-byte row into its frame. At `0x1000463dc–0x10004641c`, it inspects the two-word optional string at row `+0xa0`. If a filename is present, it preserves it, reconstructs the row via `0x10000a054` (`0x1000465f4`), and calls the import-bound `Array.append` at **`0x100046624`**. This is a presence check; no check that a supplied filename is nonempty or that the file exists is observed in this branch.

If the filename is absent, the helper passes the optional `cardImage` string from row `+0x90` to async helper **`0x100046f04`** at `0x1000466d0`, installing return continuation **`0x100046738`**. That continuation records the returned optional string (`x0/x1`) in frame `+0x4b0/+0x4b8` and switches to **`0x1000467c0`**. The latter substitutes those returned words into the reconstructed row's `cardImageFileName`, while carrying the other eleven field values through unchanged; it appends at **`0x100046af8`**. There is no nil-result branch that drops the row. It obtains the next iterator element and repeats. The two normal exit paths return the accumulated array through the original continuation at `0x100046734` and `0x100046bd8`.

Observation: the prefix precedes image resolution, the loop appends in iterator order, and both filename paths reconstruct and append a row. Inference: **on normal completion**, output count is `min(input row count, 3)`, with nil rows treated as zero, and output order matches that prefix. An image helper returning nil leaves the filename absent and still retains the row. This is not a guarantee that an asynchronous operation completes, succeeds, or is never cancelled.

The complete selected row-preparation bodies contain no reward-score comparison, sort call, card eligibility predicate, coordinate calculation, schema-version comparison, or timestamp-age/TTL gate. This bounded observation applies to the row transformation, not to every upstream payload producer or to the image helper's cache policy. It closes the earlier “row-preparation policy unexpanded” item: this stage truncates and enriches image filenames rather than deciding recommendation ranking or freshness.

**MRNR-03 — Image child boundary is narrower than row policy.** The image child entry is `0x100046f04`, with body `0x100047034`. Its input is the optional row `cardImage` string, not the full payload/timestamp; its output is the optional filename string used above. Clear body `0x100047034` contains an async call edge at **`0x100047448 → 0x10005a424`**, whose clear import metadata identifies `URLSession.data(from:delegate:) async throws`; its installed return continuation is **`0x100047550`** (`0x100047424–0x10004742c`). This identifies shipped code only: no URL was requested.

The deeper image helper callees `0x100050de4`, `0x100050fd8`, and async continuation `0x100047550` are not expanded here. Image naming/hash, cache-directory selection, image bytes, response/error acceptance, file creation, retries, expiry, and cache-size policy are therefore not claimed. Those are precise reachable image-policy boundaries, not evidence that the row-ranking/row-age question is blocked. The row caller's append-and-preserve behavior is established independently of how that optional filename is obtained.

**MRNR-04 — Clear semantics and encrypted exclusions are separate.** The carrier retains `cryptid=1` over file interval **`[0x5a000,0x5b000)`**. All selected new function bodies are in clear `__TEXT,__text` and have zero overlap with that interval. The field descriptors, field names and selected row runtime metadata/offset vector are also outside the encrypted page.

Several called Swift/import stubs, including `prefix`, iterator, append and the image `URLSession` edge, lie in the excluded page. Their machine-code bodies are not interpreted. API identity is instead tied to their stub ordinal, clear indirect-symbol entry, clear `nlist_64` entry and clear symbol-string span. `import-bindings.json` records those separate spans and the encrypted-stub flag. No encrypted instructions or type-reference bytes are used to infer these helper semantics; no decryption, patch or FairPlay bypass was attempted.

The output array can flow into the previously recovered content-state constructor and nil-staleDate selected native refresh path, but this pass neither executes that flow nor establishes an OS render event. It introduces no new claim about the main-app toolkit bridge, iPad runtime behavior, current cached rows, or scheduling.

`evidence.json` contains complete new instruction anchors and exact source/output hashes, references the existing canonical dossier records for the four reused functions, and marks the image-child boundary explicitly. `compact-evidence.json`, `validation.json`, and `output-hashes.json` provide the review manifest and checks. Validation rechecks the previous 516-entry and native 130-entry snapshots without rewriting them, and verifies clear-body spans, imported API metadata, row field offsets, raw direct branches and async continuation materialization.
