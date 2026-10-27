# Investigation progress

Status: **in progress**. Updated 2026-10-27; initial request was 2026-10-26 America/Phoenix.

## Current execution mode

The user requested an unattended method after interactive login/UI checks required repeated participation. The investigation now runs **fully offline** against the already acquired official apps, extensions, public configuration snapshots and bytecode. No further user login, GUI navigation, native runtime capture or banking demonstration is required. Complete the remaining static analysis; classify unavailable server internals and live banking outcomes as scope limits rather than user-blocked tasks.

## Reconnect and continue

- Repository: `novus-tech-tw/CardWise` (the existing origin URL redirects from `tmj-studio/CardWise`).
- Branch: `docs/competitor-rea-20261026`.
- Draft PR: https://github.com/novus-tech-tw/CardWise/pull/81.
- Worktree: `/Users/rich/Desktop/CardWise-worktrees/competitor-rea-20261026`.
- Retained artifacts/results: `/Users/rich/Desktop/CardWise-REA-2026-10-26/`.
- Baseline app commit: `5f7b9823e053924ee3d353e3198c88738f66af0d`.
- Engine: connected REA 6.5.0; browser and JavaScript analysis supported. Initially inspected Ghidra, Hopper and JADX providers unavailable. No global setup mutation performed.
- Continue existing scope and outputs; do not repeat completed acquisition/analysis just to reproduce a large response. Each product's external `progress.md` records ongoing worker detail.

## Parallel workstreams

| Workstream | Completed | Current follow-up | State |
| --- | --- | --- | --- |
| CardPointers extension and public web | Official Firefox XPI 8.0.8 hash verified; all six JS parsed; all 344 content factories covered using bounded partitions without resource truncation; popup/vendor/helpers analyzed; Safari bridge analyzed | Final compact ledgers integrated under `cardpointers/`; dynamic/external bindings remain explicitly unknown | Reachable extension static scope delivered |
| MaxRewards public web and extension | 38-file frontend classified; official Firefox 0.1.7 and all nine JS parsed; untruncated business/core follow-up; public routes/planner observed; all 74 public Connect descriptors fetched without bank execution | Reports and compact Evidence integrated; server/runtime limits retained | Offline scope delivered |
| CardPointers native Mac app | Official Mac App Store download succeeded; 8.1.4/build20261019; signed universal Mach-O and three extensions inventoried; Core Data model 24 entities/637 objects decoded; 70 compiled intent actions inventoried | Scoped Ghidra 12.1.3 main and Safari-extension native analysis; offline only | Active |
| MaxRewards native iPhone/iPad-compatible Mac app | Official 4.8.35/build1792099341; native inventory and cryptid=1 metadata; Hermes v96 all headers/strings parsed; 17 focused entry functions decoded | Digest-bound report integrated; no FairPlay bypass | Offline scope delivered |
| Native recommendation cross-check | All distinct bodies/instructions traversed for bounded identifier searches; 100 selected functions and 28 byte-range anchors reviewed | Date/category/cap/bonus/merchant findings and explicit limits integrated | Offline scope delivered |
| Consolidation and PR | Dedicated worktree; first-pass reports, hashes, evidence ledger and CardWise baseline recorded | Integrate follow-up results, reconcile findings, validate files and publish updates | Active |

## Open questions

| Question | Next evidence needed | Current status |
| --- | --- | --- |
| Extension upstream ranking and cap handling | CardPointers Amex enrollment ordering is now recovered separately from shopping order; MaxRewards client display/row ordering is partly decoded | Partial; external server-ranking formula still unknown |
| MaxRewards extension offer handling | Provider descriptor/interpreter and enrollment branches are now acquired; preserve exact version/minVersion limits | Static analysis active; no bank execution |
| Native implementation and local data model | Both official native artifacts acquired; CardPointers Core Data decoded, MaxRewards React/Hermes/Expo metadata and bytecode identified | Native analysis active |
| Authenticated recommendation correctness and bank activation | Actual execution cannot be established from static artifacts | Outside current offline scope; no user action requested |
| Paid feature behavior | Shipped entitlement branches and official plan descriptions can be analyzed statically | Live entitlement/checkout behavior outside offline scope |

## Completion gate

Do not describe the whole investigation as complete merely because a report or PR exists. Finish all reachable public-artifact work, verify artifact identities and report links, reconcile each open question to evidence or a concrete external blocker, preserve exact continuation steps, and update this ledger and PR. Do not convert unknown native or authenticated behavior into an absence claim. No personal accounts, credentials, bank sessions or payment submissions have been used. Authenticated behavior requires a selected authorized test fixture; an account creation or a bank connection must not be silently substituted for that missing evidence.

## Validation so far

- Recomputed CardPointers XPI SHA-256 and matched its official AMO metadata.
- Checked initial report links and retained large Evidence files.
- MaxRewards worker rechecked all 38 acquired source hashes in the initial corpus.
- Main checkout is unchanged. No application build/test result is claimed for this documentation-only investigation; repository PR checks remain applicable.
- Initial PR CI passed build-and-test, Python pipeline tests and SwiftLint on both push and pull-request runs. Later commits require checking their own head before claiming final CI status.
- Root independently rechecked the exact Hermes carrier, all 100 supplemental bytecode spans and disassembly/pseudocode output pairs, plus the main workstream's 17 output pairs; all hashes matched.
- An independent cross-report review identified stale native-acquisition and user-blocked language in the initial CardPointers report. Those statements were corrected to distinguish historical extension scope, separate acquired Mac analysis and current offline method limits.

## Native engine recovery

The first extended Ghidra attempts stalled in Swift demangling because the scoped PATH lacked `swift-demangle` and its `swift` fallback resolved to an unrelated OpenStack Python CLI. The native worker preserved thread/log evidence, canceled only owned analysis processes, and restarted with the actual Xcode toolchain bin prefixed in its process PATH. Default analyzers remain enabled, and neither global configuration nor target bytes were changed. Exact current jobs and recovery evidence are in `native/`; native function completion is still pending.
