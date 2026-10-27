# Native REA final offline checkpoint

Current scope: **offline REA only**, per the user's latest steering. The selected CardPointers native questions are complete within the static coverage in `report.md` and `main-native-findings.json`. No GUI, login, accessibility capture, account setup, bank activity or runtime fixture is pending. All owned REA/Ghidra analysis jobs are closed; original app processes were not terminated by analysis cleanup.

## Exact selected artifacts and owners

- CardPointers Mac **8.1.4**, build **20261019**, bundle `com.getcardpointers.app`, obtained by root from the Mac App Store at `/Applications/CardPointers.app`.
- Main universal SHA-256: `e5e4947e7c6dd288b50f3b84a26efd7f7df8f20e1b2a0c8f573063ea80c09afa`; derived arm64: `447e88aced06f027f75b4037a54f089e6750c0e8dc46e648a56ec416966754d0`.
- Safari native universal SHA-256: `94cb7c00e9433e4cfdbfcf35a2a95c3330db7ab8905d77b226f89b9951689c7d`; derived arm64: `77da6a6bf88efcbb4bbf7ae1139dde529d526dd2d3ade0820a8c595ff05131ba`.
- Apple's `lipo` produced the arm64 inputs; no decryption or bypass. `binary-provenance.json` records the mapping. Host native8.1.4 and Safari web-manifest8.1.3 are distinct.
- This subtree owns CardPointers native static evidence. Separate workers own MaxRewards native/web and CardPointers extension JavaScript. Root owns overall PR staging, commit, publication and final CI.

## Final question status

| Question | Status / exact boundary |
| --- | --- |
| Artifact identity, package graph, Mach-O/signature/plist | Complete within selected package/tool inventory;105dependencies; imports/exports non-exhaustive |
| CoreData model | All637 archive objects decoded;24entities; no live records |
| AppIntents |70 declarations, including hidden/legacy/platform-specific; not all exposed/executed actions |
| Native metadata | Maximum 20,000-record pass retained; unresolved pointers/family budgets/unsupported Swift metadata remain explicit |
| PointersStore refresh | Wrapper→400ms debounce→work item→filtered CoreData publication chain recovered |
| Pointer value writer and caller | Incoming points/total_value copied into DBPointerCard; two parent reconciliation call sites and relationship cleanup recovered |
| Value consumer and ranking explanation | Selected display arithmetic recovered; vendor ranking help separately labeled; exact sort keypaths/upstream formula unproven |
| Safari native getWallet | Four native dossiers plus independent JS correspondence; own-account auth/entitlement reply, not full card-row reply |
| Remote/server/bank/full offer automation | Stated static-method limit; no live execution claim or runtime deliverable pending |
| Canonical export and cleanup | Main24records +Safari4records retained; both sessions closed; final recorded process check found0owned workers |
| PR handoff | Native subtree final, unstaged by this worker; root owns final delivery |

## Durable jobs and results

All large results remain outside Git under `/Users/rich/Desktop/CardWise-REA-2026-10-26/native`.

| Job | Former worker / REA / JVM | Former unified exec session | Final result |
| --- | --- | --- | --- |
| Main native |7919 /7928 /9739 |62773 |24 canonical records in `main-native-functions-evidence.json`; closed after export |
| Safari native |8084 /8085 /9744 |92657 |4 canonical records in `safari-native-functions-evidence.json`; closed after export |

`jobs.json` retains per-process final absence checks, exact state/result/log paths, export sizes/hashes and superseded worker identities. `evidence-index.json` links the compact ledgers. Main export SHA-256: `22bd9ac5a523e916921723e1dccbce1c75cb629c403a56bf03013553a84ce027` (7,877,435bytes). Safari export SHA-256: `5083426b24f050f1e8bee7b45b8dbb2bf4343bcbdac4733605169a4c1e5cc840` (5,720,654bytes). Zero structured unknown entries in these files does not mean complete semantic recovery.

## Provider recovery retained

Official Ghidra 12.1.3, existing JDK 22, task-local native decompiler compiled from bundled official source, and REA 6.5.0 were used. No global configuration or system dependency install changed. Initial startup timed out; longer attempts then stalled in SwiftNativeDemangler. Own JVM dumps showed a subprocess pipe wait, and host PATH resolved `swift` to OpenStack's Python client instead of Apple's compiler. Prepending the existing Xcode toolchain to the two workers' PATH fixed the issue. Default analyzers were preserved; auto-analysis then completed in 461 seconds (main) and 159 seconds (Safari). `engine-recovery.json`, `tool-provenance.json`, and local diagnostic/log snapshots preserve this history. Superseded attempts were cancelled; their nonexistent function results are not claimed.

## Continue only if scope changes

No analysis job should be restarted for the current completed static scope. Read the existing canonical exports and compact ledgers first. A future question about backend calculation, full offer automation, live payloads or runtime outcomes needs a separately selected evidence target and scope; the current report does not silently claim them. Root can finalize the existing PR without further user intervention.

## Retention and historical acquisition

Do not publish vendor binaries, full pseudocode, receipts, user containers, real credentials, raw accessibility trees or screenshots. Only metadata/schema/identifiers/analysis and allowlisted historical UI structure belong in this subtree. Earlier mirror-acquisition attempts remain historical local files; official Mac acquisition superseded them. The44-node passive screenshot-free/no-action observation is supplemental, with exact reference in `ui-structure.json`; no further UI task exists.
