# Investigation progress

Status: **original offline investigation complete; new iPad installation/runtime scope pending**. Delivered through PR #81. Updated 2026-10-27; initial request was 2026-10-26 America/Phoenix. Final-head CI status is reported on the PR rather than inferred from an earlier commit.

## Original completed execution mode

The user requested an unattended method after interactive login/UI checks required repeated participation. The investigation now runs **fully offline** against the already acquired official apps, extensions, public configuration snapshots and bytecode. No further user login, GUI navigation, native runtime capture or banking demonstration is required. Complete the remaining static analysis; classify unavailable server internals and live banking outcomes as scope limits rather than user-blocked tasks.

For the later iPad followup, the user explicitly authorized installing both apps, asked to avoid repeating REA already in the PR, and requested immediate notice if login is needed. Reuse prior artifacts and Evidence. Installation remains pending as described in [the followup status](followup/README.md); no target-app account login requirement has yet been observed on the iPad.

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
| CardPointers native Mac app | Official 8.1.4/build20261019; native inventory, 24 entities/637 objects, 70 intent declarations; selected main refresh/materialization/consumer and Safari bridge paths recovered | Canonical main 24/Safari 4 records exported; all owned sessions closed | Offline scope delivered |
| MaxRewards native iPhone/iPad-compatible Mac app | Official 4.8.35/build1792099341; native inventory and cryptid=1 metadata; Hermes v96 all headers/strings parsed; 17 focused entry functions decoded | Digest-bound report integrated; no FairPlay bypass | Offline scope delivered |
| Native recommendation cross-check | All distinct bodies/instructions traversed for bounded identifier searches; 100 selected functions and 28 byte-range anchors reviewed | Date/category/cap/bonus/merchant findings and explicit limits integrated | Offline scope delivered |
| Consolidation and PR | Dedicated worktree; final reports, hashes, ledgers, baseline, method and progress reconciled | Final publication validation and CI recorded through PR #81 | Documentation delivered |

## Open questions

| Question | Next evidence needed | Current status |
| --- | --- | --- |
| Extension upstream ranking and cap handling | CardPointers Amex enrollment ordering is now recovered separately from shopping order; MaxRewards client display/row ordering is partly decoded | Partial; external server-ranking formula still unknown |
| MaxRewards extension offer handling | Provider descriptor/interpreter and enrollment branches acquired; preserve exact version/minVersion limits | Selected static scope complete; no bank execution |
| Native implementation and local data model | Both official native artifacts acquired; CardPointers Core Data decoded, MaxRewards React/Hermes/Expo metadata and bytecode identified | Selected native scope complete |
| Authenticated recommendation correctness and bank activation | Actual execution cannot be established from static artifacts | Outside current offline scope; no user action requested |
| Paid feature behavior | Shipped entitlement branches and official plan descriptions can be analyzed statically | Live entitlement/checkout behavior outside offline scope |

## Completion gate

The [2026-10-27 followup](followup/README.md) reuses these outputs and closes selected sort/storage binding gaps without repeating whole-application REA. The connected iPad is paired with Developer Mode enabled. After an initial preflight found neither target installed, the user explicitly requested installation: **MaxRewards 4.8.35 is now installed and launched**, with process presence independently observed; its identity-only Frida attachment failed and is skipped. **CardPointers installation remains pending**; its App Store launch with the official product URL succeeded, but the rendered page was not observed. Device Hub explicitly requires iOS 27.0 or above for screen sharing with this Mac, while the selected iPad runs 26.7. Do not confuse this partially completed new scope with completion of the earlier offline investigation.

The selected offline scope is complete: reachable static questions were reconciled to observations, bounded partial findings or explicit method limits; exact artifacts and continuation locations are preserved. Unknown native or authenticated behavior is not converted into an absence claim. No real banking credential, bank session or payment submission was used by the static analysis. Historical login/UI work is supplemental and no further test fixture, account creation or bank connection is pending. Future live/server questions require a separately selected scope rather than silently expanding this completed investigation.

## Validation so far

- Recomputed CardPointers XPI SHA-256 and matched its official AMO metadata.
- Checked initial report links and retained large Evidence files.
- MaxRewards worker rechecked all 38 acquired source hashes in the initial corpus.
- Main checkout is unchanged. No application build/test result is claimed for this documentation-only investigation; repository PR checks remain applicable.
- Initial PR CI passed build-and-test, Python pipeline tests and SwiftLint on both push and pull-request runs. Later commits require checking their own head before claiming final CI status.
- Root independently rechecked the exact Hermes carrier, all 100 supplemental bytecode spans and disassembly/pseudocode output pairs, plus the main workstream's 17 output pairs; all hashes matched.
- An independent cross-report review identified stale native-acquisition and user-blocked language in the initial CardPointers report. Those statements were corrected to distinguish historical extension scope, separate acquired Mac analysis and current offline method limits.

## Native engine recovery

The first extended Ghidra attempts stalled in Swift demangling because the scoped PATH lacked `swift-demangle` and its `swift` fallback resolved to an unrelated OpenStack Python CLI. The native worker preserved diagnostics, canceled only owned analysis processes, and restarted with the Xcode toolchain bin prefixed in its process PATH. Default analyzers remained enabled; auto-analysis completed in 461 seconds for the main app and 159 seconds for Safari. Selected native results were exported and all owned jobs closed. Neither global configuration nor target bytes changed. Exact recovery evidence and former job IDs are in `native/`.
