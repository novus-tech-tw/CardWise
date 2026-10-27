# Native REA progress and resume checkpoint

Current scope: **offline REA only**, per the user's latest steering on 2026-10-26 America/Phoenix. Analyze the already acquired official native apps and extension artifacts. No GUI, login, additional accessibility capture, banking activity, account setup or live fixture is pending under this scope. Historical passive UI evidence is supplemental only.

## Selected artifacts and owners

- This worker owns CardPointers Mac **8.1.4**, build **20261019**, bundle `com.getcardpointers.app`, acquired by root from the Mac App Store at `/Applications/CardPointers.app`.
- Main universal executable SHA-256: `e5e4947e7c6dd288b50f3b84a26efd7f7df8f20e1b2a0c8f573063ea80c09afa`.
- Derived arm64 executable SHA-256: `447e88aced06f027f75b4037a54f089e6750c0e8dc46e648a56ec416966754d0`; derived with Apple's `lipo`, without decryption. Input/output mapping is in `binary-provenance.json`.
- Native Safari app-extension universal SHA-256: `94cb7c00e9433e4cfdbfcf35a2a95c3330db7ab8905d77b226f89b9951689c7d`; derived arm64 SHA-256: `77da6a6bf88efcbb4bbf7ae1139dde529d526dd2d3ade0820a8c595ff05131ba`.
- The MaxRewards worker separately owns the official MaxRewards native app and any bundled JavaScript. Do not duplicate that pass here.
- The CardPointers extension worker owns Firefox/Safari JavaScript and native-message-call-site analysis. This worker owns native metadata and the compiled Safari handler.

## Current completion matrix

| Question | Status | Evidence / next action |
| --- | --- | --- |
| Official artifact identity, original/derived hashes | Complete | Original package and explicit arm64 derivation retained |
| Package and Apple application graph | Complete within package inventory | 167 regular files, 3 app extensions; full inventory/projection Evidence |
| Main Mach-O, signature and Info.plist | Complete within tool coverage | 105 dependencies; non-exhaustive import/export inventories remain labeled |
| CoreData model schema | Complete within shipped model | REA decoded all 637 archive objects; 24 entities; no live rows or object instantiation |
| AppIntents declaration inventory | Complete within shipped resource | 70 declarations including legacy/hidden/version-specific actions; no execution claim |
| Native dispatch metadata | Maximum supported pass completed | 20,000-record request retained; unresolved pointers, metadata-family caps and unsupported resilient/generic Swift remain provider limits |
| Main native ranking/offer/wallet function questions | In progress | Default-profile Ghidra auto-analysis running under extended per-process startup deadline |
| Native Safari `getWallet` handler/data boundary | In progress in parallel | Smaller compiled app-extension target in a second owned Ghidra session |
| Authenticated/live bank/server behavior | Static-scope limit | No runtime fixture deliverable; do not substitute static paths for observed execution |
| Research PR integration | Checkpoint integrated; updates ongoing | Only this `native/**` subtree is edited here; root stages, commits and publishes |

## Active owned jobs

All job outputs are under `/Users/rich/Desktop/CardWise-REA-2026-10-26/native` outside the repository. `native-jobs.json` records the latest process tree, exact selected request and log locations. Worktree files are public-reviewable compact summaries.

| Job | Worker / REA server / JVM PID | Unified exec session | Current output |
| --- | --- | --- | --- |
| Main arm64 default Ghidra pass | 35337 / 35344 / 36873 | 66241 | `ghidra-business-procedures-extended.json` when complete; state `native-worker-state.json` |
| Safari native handler default Ghidra pass | 42411 / 42413 / 42949 | 57682 | `safari-native-procedures.json` when complete; state `safari-native-worker-state.json` |

The main pass began at **2026-10-27 06:43:55 UTC**; the Safari pass began at **06:45:45 UTC**. Each uses the documented per-process `REA_GHIDRA_STARTUP_TIMEOUT_MS=1800000` setting. The earlier main pass reached the default 330-second startup deadline and returned no function result; its diagnostic is preserved in `ghidra-initial-timeout-summary.json`. The changed deadline is the resolved input difference for the retry. No analyzer was disabled and no native partial database was represented as a completed result.

Engine: REA 6.5.0, official Ghidra 12.1.3 SHA-256-verified distribution, task-local native decompiler built from its bundled source, existing JDK 22. No global REA/client configuration or system dependency installation changed. See `tool-provenance.json`; build log is local `tools/ghidra-native-build.log`. Current Ghidra log snapshots are local `logs/main-ghidra.log` and `logs/safari-ghidra.log`; live source paths are in `native-jobs.json`.

## Resume the existing work

1. Read `native-worker-state.json`, `safari-native-worker-state.json` and `native-jobs.json`; inspect existing owned jobs before submitting anything again.
2. When a current search completes, read its saved result and coverage. Do not rerun the same import just to retrieve output.
3. Resolve returned function identities and inspect focused native functions/references for ranking/value ordering, wallet synchronization, and the Safari `getWallet` reply boundary.
4. Export each current REA session's Evidence before closing it. Preserve original and derived artifact identities and all decompiler warnings/unknowns.
5. Update `report.md`, `evidence-index.json`, this progress file and compact ledgers in the worktree; root owns staging/commit/PR updates.
6. Close owned analysis sessions only after the meaningful offline questions are answered or a concrete provider/static-evidence limit is documented. No GUI or user intervention is required for this resume path.

## Retention and history

Large original/static Evidence remains local under the external native directory. Do not publish vendor binaries, receipts, user containers, credentials, raw accessibility trees or screenshots. Public files include static metadata, schema fields, action identifiers and sanitized UI role counts only.

Before the user selected already-installed phone apps and requested Mac equivalents, public mirror acquisition was audited. Those attempts and official iOS/Android store metadata remain in local `acquisition-attempts.json`, `store-identities.json` and the historical acquisition `report.md`. They are no longer the active work path or a missing-artifact blocker.

A historical passive native observation captured 44 AX nodes, with no screenshot, no actions, no truncation and no gaps, under Evidence `ev_1831e6a489f8666cc897d8097c45df0ec598a05b21d5faceedc6dadc8c53d1ba`. Only allowlisted labels/roles are in `ui-structure.json`. There is no further UI capture task.
