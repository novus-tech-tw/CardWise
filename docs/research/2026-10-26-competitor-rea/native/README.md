# CardPointers native REA checkpoint

This subtree contains the public-reviewable native checkpoint for the official CardPointers Mac app 8.1.4. MaxRewards native analysis is owned by the separate MaxRewards investigation subtree.

- [Report](report.md): observed metadata, domain model, capabilities, limitations, and active function-analysis status.
- [Evidence index](evidence-index.json): exact REA Evidence IDs and bounded coverage.
- [Progress and resume checkpoint](progress.md): current owned analysis workers and remaining steps.
- [Owned job ledger](jobs.json): exact process/session identities and local result/log locations.
- [Binary provenance](binary-provenance.json): original universal executable and derived arm64 identity.
- [CoreData schema](coredata-schema.json): inert model UID-reference resolution; no live wallet rows.
- [AppIntents declarations](app-intents.json): action identifiers and declaration metadata, without copied localized descriptions.
- [App-extension identities](extension-bundles.json): packaged bundle versions and extension points.
- [Tool provenance](tool-provenance.json): upstream Ghidra release hash and scoped local native-component build.
- [Sanitized UI structure](ui-structure.json): exact passive capture reference, role counts and allowlisted labels only; no screenshot or arbitrary accessibility values.

Original vendor binaries, full REA exports, full accessibility trees, store receipts, user containers and credentials are not committed. Large/static local evidence resides under `/Users/rich/Desktop/CardWise-REA-2026-10-26/native`; the raw UI export is local-only and must not be published.

Current work is offline REA only. Function-level Ghidra analysis is still running at this checkpoint; no GUI, login or live-fixture task is pending. Complete package/model inventory and a retained Evidence export do not mean the entire native app has been semantically recovered. See the progress file before continuing rather than restarting the same jobs.
