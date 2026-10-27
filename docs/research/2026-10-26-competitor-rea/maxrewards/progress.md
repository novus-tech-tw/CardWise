# MaxRewards investigation progress

Updated: 2026-10-26 America/Phoenix.

## Completed

- [x] Public product-to-signup REA runtime, without form submission. Evidence `ev_ea10ac8fd04e2f98a2eebf6f667e47d98d7beb2f1863021bfc1edd94cb37ba01`.
- [x] Acquired 38 public JavaScript artifacts, verified SHA-256 manifest.
- [x] Initial seven-source REA static pass, parent `ev_a1ab54ca0e29ba5922c67b4c0bf00f27dcfeae2b2aa23d0407e0b47c22c27584`.
- [x] Six-record Evidence bundle and report saved.

## In progress

- [x] Classify all 38 acquired web files. Seventeen business/inline sources were REA-parsed; 21 shared/SDK files received a separate bounded inventory/marker review (`corpus-classification.json`). This is not a claim that every vendor implementation was semantically analyzed.
- [x] Analyze ten supplementary exact web sources with no semantic truncation; parent `ev_d1878e7ea9adf13bb4dc11ad80696b4d96b3401219201f39c40e948eadc45f60`.
- [x] Resolve initial business-node ceilings with a changed-budget pass; parent `ev_60c99d921a4b12ae853443674e1fb310eb14582fc2c27cc3b34356f479fcd078`, semantic.truncated=false. Dynamic relationships and unselected scopes remain partial.
- [x] Acquire official Firefox XPI 0.1.7 and verify AMO SHA-256 `5a8866b7c1760bddf125564249bc174548db4264e3a28c62ff0f6be856bd0c4b`. REA parsed all nine shipped JS sources; broad graph reached resource limits.
- [x] Resolve extension core limits with exact-source pass of background/bank/browser/webapp/canvas/passkey plus manifest/popup; parent `ev_4489deb9a5d9177945f4a467e17bc8ccb83e8c9f9c47cebdabfe5923194a8728`, semantic.truncated=false. Three UI-heavy sources remain outside this core pass but were parsed in the broader pass.
- [x] Acquire all 74 public Connect provider descriptors GET-only, with digests. No descriptor was executed and no bank URL was visited. Bilt requires a newer extension than the acquired 0.1.7.
- [x] Exercise login, recovery, download, extension login, account gate, terms/privacy, Platinum, card directory, membership gate and website-best-card gate via declared REA actions. No account form submitted.
- [x] Verify a public signed-out value calculator using synthetic annual spend and a credit toggle; all four declared actions completed, result reconciled arithmetically, browser cleanup confirmed. Evidence `ev_763929fb25bfe1dc8dc51cc391659cf9502b9907164253a993bba1e80790824f`.
- [x] Inspect official installed native app 4.8.35/build1792099341 via REA artifact/plist/signature/Mach-O. Native executable cryptid=1; no FairPlay bypass. Main business bundle is separate Hermes bytecode v96.
- [x] Parse the unencrypted shipped Hermes carrier with pinned source-only P1sec/hermes-dec; 68,786 functions/72,616 strings. Seventeen focused entry functions disassembled/decompiled with byte offsets and output digests; decompiler pseudocode is a supplementary inferred representation, not original source or runtime.
- [x] Capture exact native welcome window with REA. Rebinding the true translocated executable resolved target mismatch. Welcome is signed-out, so no personal financial data appeared in these successful captures.
- [x] Final user steering incorporated: complete the investigation offline and unattended. No further runtime observation, application launch or login request remains in scope. Existing target/provider failures are recorded limitations, not work awaiting user intervention.
- [x] Expanded report, compact provenance/Evidence/runtime/source-anchor files written. Expanded REA bundle exported: 36 records, 519,535,700 bytes, retained only externally.

## Limits and next action

No native artifact or authenticated wallet was available in the first pass. The parent session later obtained the official native application, expanding this worker's scope to package metadata and offline Hermes decoding. Static source presence is not runtime execution; vendor claims are not product verification. Initial graph limits are preserved in their historical records and addressed by the quantified supplementary passes above.

Latest native action limitation: REA `capture_native_ui_scenario` rejected its declared welcome click before executing steps because the selected CG window had no uniquely matching AX-window geometry. A later post-login passive capture timed out in its xcrun helper; fresh process/window enumeration then found no live target. Root was informed; no stale-target retry or permissions change was attempted.

Current status: this worker's web, extension, provider-configuration, native-package/auth/data/presentation analysis is complete within the unattended offline scope. No further live target or permissions are needed. A separate worker owns additional native cap, quarter, signup-priority and merchant-logic audit under `native-recommendation-review/`.
