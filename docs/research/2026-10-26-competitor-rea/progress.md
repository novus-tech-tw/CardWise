# Investigation progress

Status: **in progress**. Updated 2026-10-26 America/Phoenix; raw tool timestamps can be 2026-10-27 UTC.

## Reconnect and continue

- Repository: `novus-tech-tw/CardWise` (the existing origin URL redirects from `tmj-studio/CardWise`).
- Branch: `docs/competitor-rea-20261026`.
- Worktree: `/Users/rich/Desktop/CardWise-worktrees/competitor-rea-20261026`.
- Retained artifacts/results: `/Users/rich/Desktop/CardWise-REA-2026-10-26/`.
- Baseline app commit: `5f7b9823e053924ee3d353e3198c88738f66af0d`.
- Engine: connected REA 6.5.0; browser and JavaScript analysis supported. Initially inspected Ghidra, Hopper and JADX providers unavailable. No global setup mutation performed.
- Continue existing scope and outputs; do not repeat completed acquisition/analysis just to reproduce a large response. Each product's external `progress.md` records ongoing worker detail.

## Parallel workstreams

| Workstream | Completed | Current follow-up | State |
| --- | --- | --- | --- |
| CardPointers extension and public web | Official Firefox XPI 8.0.8 hash verified; all six JS parsed; source-bound offer/session/cache analysis; legacy-web login gate captured | Reduce avoidable semantic truncation with focused exact scopes, trace merchant/ranking/cap and sync boundaries | Active |
| MaxRewards public web and extension | Product-to-signup runtime; identity/provisioning/mobile handoff traced; ten supplemental files analyzed without semantic truncation; official Firefox extension 0.1.7 acquired/hash matched and all nine shipped JS files parsed | Finish extension business traces, public frontend inventory and bounded graph partitions | Active |
| Native CardPointers / MaxRewards artifacts | Official listing identities resolved; direct HTTP and fresh REA browser attempts documented; APKMirror/APKPure/Aptoide paths blocked with 403 and other tested paths 404/410 | Continue credible distribution checks; requested existing local IPA/APK paths from user while independent analysis continues | Active; external artifact requirement if public acquisition stays blocked |
| Consolidation and PR | Dedicated worktree; first-pass reports, hashes, evidence ledger and CardWise baseline recorded | Integrate follow-up results, reconcile findings, validate files and publish updates | Active |

## Open questions

| Question | Next evidence needed | Current status |
| --- | --- | --- |
| Extension upstream ranking and cap handling | Focused shipped-code/module traces; native package where logic is absent from web | Partial |
| MaxRewards extension offer handling | Follow server-returned card recommendation, offer fields, cached response and account synchronization branches | Artifact acquired; analysis active |
| Native implementation and local data model | Legally accessible native distribution and matching supported provider | Acquisition in progress |
| Authenticated recommendation correctness and bank activation | Suitable authorized test wallet/session and known fixtures | Not executed; real user banking access is outside current scope |
| Paid feature behavior | Authorized test entitlement or unsubmitted public purchase UI | Vendor claims/source branches only |

## Completion gate

Do not describe the whole investigation as complete merely because a report or PR exists. Finish all reachable public-artifact work, verify artifact identities and report links, reconcile each open question to evidence or a concrete external blocker, preserve exact continuation steps, and update this ledger and PR. Do not convert unknown native or authenticated behavior into an absence claim. No personal accounts, credentials, bank sessions or payment submissions have been used. Authenticated behavior requires a selected authorized test fixture; an account creation or a bank connection must not be silently substituted for that missing evidence.

## Validation so far

- Recomputed CardPointers XPI SHA-256 and matched its official AMO metadata.
- Checked initial report links and retained large Evidence files.
- MaxRewards worker rechecked all 38 acquired source hashes in the initial corpus.
- Main checkout is unchanged. No application build/test result is claimed for this documentation-only investigation; repository PR checks remain applicable.
