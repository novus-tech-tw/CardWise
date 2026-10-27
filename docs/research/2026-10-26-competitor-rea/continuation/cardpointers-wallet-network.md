# CardPointers selected wallet network → decoder → persistence boundary

Date: 2026-10-27. This finite offline continuation uses the retained **Mac CardPointers 8.1.4 arm64** executable, SHA-256 `447e88aced06f027f75b4037a54f089e6750c0e8dc46e648a56ec416966754d0`. No app/device/HTTP request, credentials, account preferences or application-data storage was accessed. No main-image Ghidra import or whole-app instruction query was repeated.

## Answer and remaining limits

A selected, conditional static path is now linked from the compiled **`/v1/user/wallet/?app=mac&version=`** URL component through **URLSession Data → JSONDecoder.decode(NewDataResponse) → a captured NewDataResponse → the already documented Core Data reconciliation/materializer chain**. The processor-to-decoder and processor-to-persistence callbacks are concrete async descriptors, rather than adjacency or type-name guesses.

This closes the previously unresolved *selected Mac network producer → typed decoder → persistence input* edge. It does not establish which requests run on the current account, HTTP status/body contents, endpoint host or deployment behavior, that every response reaches persistence, or the server's scoring formula. It also does not prove there are no other local calculations, cache paths, recommendation producers or iPad-specific differences. Prior CPW-01–04 field/decoder/materializer findings retain their narrower scopes.

## CPWN-01 — URLSession results reach the processor unchanged as Data words

The existing exact-address candidate points to `0x10046e928–0x10046f143`. At `0x10046ed78–0x10046ed8c` the instructions load the specified wallet URL component. Later `0x10046ef60` calls the imported `Foundation.URLRequest.init(url:cachePolicy:timeoutInterval:)` stub `0x1012ac374`. The continuation address installed at `0x10046f108–0x10046f110` is `0x10046f144`. At `0x10046f140`, the selected tail branch reaches `0x1012b3034`, independently bound through the image's indirect symbol table to:

```text
Foundation.NSURLSession.data(for: Foundation.URLRequest, delegate: NSURLSessionTaskDelegate?) async throws -> (Foundation.Data, NSURLResponse)
```

The returned Data words x0/x1 are stored at the parent async context's `+0x170/+0x178` by `0x10046f170`. The non-error path schedules `0x10046f1c4`; the error path schedules a different continuation that this report does not interpret. In the selected non-error continuation, `0x10046f300` reloads exactly those two words, `0x10046f30c` puts the first in x0, w2 is zero, and `0x10046f328` branches to processor **`0x10048b460`**. This is transport-call completion evidence, not an HTTP-200 or issuer-success check.

The processor stores those arguments at context `+0x378/+0x380` (`0x10048b47c–0x10048b480`), allocates storage using the NewDataResponse accessor `0x10123bac0` (`0x10048b4d8–0x10048b4f4`), and switches to `0x10048b584`. An initial guard and an intermediate task precede later processing. Their complete policies are not claimed recovered. A later existing-state optional/comparison selects continuations `0x10048ba18`, `0x10048bc7c` or **`0x10048bee8`** (`0x10048b994–0x10048ba14`). The newly linked decode path is the last of these; the first two are retained as contextual candidates.

## CPWN-02 — A captured async descriptor closes the actual typed decoder edge

In `0x10048bee8`, the original Data words are loaded from processor context `+0x378/+0x380` (`0x10048bf14–0x10048bf18`) and stored at a new capture's `+0x20/+0x28` (`0x10048bf54`). Its first two capture words are zero. At `0x10048bfa4–0x10048bfb4`, `swift_task_create` receives async descriptor **`0x1012f9850`**, the NewDataResponse metadata in x2, and that capture in x4.

The descriptor is not guessed from a nearby address:

| Async descriptor | Raw little-endian record | Signed-relative entry / context bytes |
| --- | --- | --- |
| `0x1012f9850` | `e8e319ff20000000` | **`0x100497c38`**, 32 |
| `0x1012f9658` | `f4ef17ffb0000000` | `0x10047864c`, 176 |

Canonical wrapper start is **`0x100497c38`**. `0x100497c3c` is its second instruction, so an exact reference query using only that second address can miss the closure binding. The descriptor in a non-code section also explains why an immediate ADRP/ADD query for a code address is not an exhaustive callback search.

Wrapper `0x100497c38` loads the capture at `+0x10/+0x18` into x1/x2, the Data words at `+0x20/+0x28` into x3/x4, allocates its async context and tail-branches to `0x10047864c` at `0x100497cac`. The latter saves x3/x4 at decoder context `+0x68/+0x70`, saves its result buffer, obtains NewDataResponse metadata via `0x10123bac0` and switches to **`0x1004786e4`**.

At `0x100478708–0x100478714`, that continuation restores metadata from context `+0xa8`, the Data words from `+0x68/+0x70`, and the result-buffer pointer from `+0x60`. It constructs a JSONDecoder using imported metadata/initializer stubs `0x1012ac458` / `0x1012ac44c`. At `0x100478760–0x10047877c`, it requests the conformance using the exact NewDataResponse accessor and descriptor **`0x1013a1458`**. That is the previously resolved Swift.Decodable conformance in `selected-conformances.json`, not an inferred protocol name.

The call at **`0x100478798`** reaches imported stub **`0x1012ac440`**, `Foundation.JSONDecoder.decode<A: Decodable>(_: A.Type, from: Data) throws -> A`, with NewDataResponse metadata, the original Data words, and its witness. x8 is the task's result buffer. Its success branch `0x1004789c8–0x1004789ec` returns without replacing that decoded value. This connects the specific network Data to the previously inspected `PointerCard` keyed Float/optional-Int decoding path. Actual payload values remain unobserved.

## CPWN-03 — Decoder success enters a captured persistence operation

The processor awaits the decoding task using imported `_swift_task_future_wait_throwing` at `0x10048c000`, with the result buffer at processor context `+0x3c8` and resume address **`0x10048c004`**. The resume saves/tests its error result at `0x10048c01c–0x10048c024`. Its error path schedules `0x10048c1ec`; its selected successful path loads that decoded result-buffer pointer, sets w1 to 1 and branches to **`0x10048cb80`** at `0x10048c08c`.

`0x10048cb80` saves the response pointer and object context, obtains NewDataResponse metadata and switches to `0x10048cc14`. That continuation retains an early guard. After the guard, it prepares the response with type-directed transfer helpers: `0x10048ce00` calls `0x10000ef4c` with the NewDataResponse accessor, and `0x10048ce50` calls `0x1000b2c00` with the same accessor to place the value in an aligned capture. The helper bodies dispatch through the type's value-witness slots `+0x10` and `+0x20`, respectively. These are typed value transfers, not a recovered scoring operation; this report does not infer the fields of an unrelated opaque object.

The capture layout and consumer agree: an aligned NewDataResponse begins after a 0x20-byte capture header, and an additional object field follows the aligned response. The producer computes that layout from NewDataResponse value-witness size/alignment (`0x10048ce04–0x10048ce54`); the consumer independently computes the same layout (`0x100497e74–0x100497e9c`).

The producer builds an outer capture containing **descriptor `0x1012f9870` plus the response capture** (`0x10048cf00–0x10048cf08`), then calls `swift_task_create` with **outer descriptor `0x1012f9880`** (`0x10048cf38–0x10048cf48`). Both descriptors are resolved from raw bytes:

| Descriptor | Raw little-endian record | Entry |
| --- | --- | --- |
| `0x1012f9870` | `e0e519ff20000000` | **`0x100497e50`** |
| `0x1012f9880` | `70e619ff20000000` | **`0x100497ef0`** |
| `0x1012f9878` | selected raw record in ledger | `0x1000719c8` generic descriptor dispatcher |
| `0x1012f9868` | `00bc19ff50000000` | **`0x100495468`**, context size 80 |

Outer wrapper `0x100497ef0` restores the inner descriptor and response capture, resolves the dispatcher at `0x1012f9878`, and branches through it. Dispatcher `0x1000719c8` adds the signed displacement at the supplied inner descriptor, allocates the descriptor's context size, installs a return continuation, and branches to the resolved entry. Thus **`0x1012f9870 → 0x100497e50`** is a bound indirect callback, not a free-floating function candidate.

`0x100497e50` obtains the response at its aligned capture offset, forwards it as x3 and tail-branches to **`0x100495468`** at `0x100497eec`. `0x100495468` moves that response pointer into x20 and branches to **`0x1012773c0`** at `0x1004954c8`. That entry saves the response, allocates type-directed buffers, then switches to the **already retained `0x101277458`** capture/Core Data handoff. CPW-03's existing `wallet-capture-handoff.asm`, `wallet-parent-thunk.asm`, `coredata-schedule.asm` and reconciliation evidence complete the selected parent/materializer connection. Those completed producers were not rerun.

## Interpretation for CardWise and acceptance boundary

For this selected shipped Mac path, NewDataResponse is now more than a suggestive name: Data returned by a wallet URLSession request is captured into the typed decoder, and a successful decoded response can be captured into the existing reconciliation/persistence path. Together with CPW-04 and the existing materializer map, this supports supplied `PointerCard.points`, `total_value` and optional `order` entering persistence through a concrete network decoding route.

It still does not justify the claim “all recommendation scoring is server-side”. The full server computation is absent; other local transformations, alternate producers/cache paths and surface-specific selection can coexist. The initial guard, intermediate task, comparison/suppression branches, complete decode/error recovery policy and the persistence operation's complete scheduling/result policy are not exhaustively reconstructed. The current iPad build and actual account output were not inspected. Endpoint host, authorization details and user data are outside this pass.

## Verification and retained evidence

`wallet-network-evidence.json` binds 28 finite LC_FUNCTION_STARTS-bounded disassemblies (9,204 carrier bytes), exact branch/descriptor/capture anchors, import-symbol identities, source/output hashes and reused CPW artifacts. Contextual bodies without product-semantic claims are labeled. `network-boundary/checks.json` records structural validation; no helper implementation was reimplemented as a test and no application was executed. LLVM's unrelated nearest-symbol annotations are ignored; all function identities use exact addresses.

The local reader and assembly outputs are in `network-boundary/`; they operate only on the already retained shipped executable. Raw memory, real preferences, tokens and account contents were never read. Local scripts and all new files remain outside the repository for the parent's review and integration.
