# Focused followup and iPad installation status

Updated 2026-10-27. The earlier selected offline investigation in PR #81 remains complete. This followup first checked that PR and the retained archive, then reused existing function dossiers and artifact bytes to answer specific unresolved bindings. No whole-application REA import, app decryption or completed scenario was repeated.

## New static results

| Question | Result | Evidence |
| --- | --- | --- |
| CardPointers fetch sort keypaths | `is_favorite` descending, then `name` ascending; this is presentation order, not the reward formula | [Report](cardpointers-report.md), [exact pattern/string offsets](cardpointers-sort-keypaths.json) |
| CardPointers selected metadata budget | Two exact descriptors, 39 slots, nine resolved implementations and 30 partial slots; no focused-budget exhaustion | [Reader scope and provenance](cardpointers-metadata-summary.json) |
| MaxRewards comparator caller | `BestCardRewardsScreen` → card normalizer → each card's reward-row `.sort` → F67344; not wallet-card or merchant ordering | [Report MRF-01](maxrewards-report.md), [function/anchor ledger](maxrewards-evidence.json), [module registrations](maxrewards-module-bindings.json) |
| MaxRewards string-storage provider | F16155/F16158 share a constructed MMKV instance in environment slot 23; the app call supplies no configuration argument | [Report MRF-02](maxrewards-report.md), [verification](maxrewards-validation.json) |

These are static artifact findings. Existing native/bytecode runtime, server-ranking, unsupported-metadata and banking limits remain. They do not establish current iPad build identity, storage contents, all-layer encryption or end-to-end feature behavior. Original 117-function coverage counts describe the earlier review, not a total for this later selected binding pass.

Full local scripts and outputs are retained under `CardWise-REA-2026-10-26/ipad-followup-20261027/`. New analyst labels and host CLI observations are not REA MCP Evidence IDs. The CardPointers sort result links back to the original fetch-construction Evidence.

## iPad installation and runtime scope: pending

The selected physical iPad Air (4th generation) runs iPadOS 26.7. Host inspection verified a wired connection, paired state, enabled Developer Mode and no passcode requirement at observation time. REA Frida discovery also found the USB device; process discovery alone does not imply target-app attach capability.

Exact-bundle inventory with all app classes included returned zero matches for both `com.getcardpointers.app` and `com.max.MaxRewards`. Launch attempts independently returned CoreDevice error 10002, underlying OSStatus -10814, explicitly stating each requested app was not installed. See the [sanitized host observations](device-check.json). The earlier Mac artifacts must not be described as captured from this iPad.

The user then explicitly requested installation before further runtime analysis. Device Hub's View Screen attempt ended with: “must be running iOS 27.0 or above to screen share with this Mac.” The current 26.7 device therefore cannot be driven through that interface. No OS upgrade was attempted. The official Mac App Store Apple Configurator download was attempted as an alternative, but its account/download sheet did not expose a continuation or verification control and installation had not completed. This is not evidence that a target-app account login is required.

[Apple's Configurator instructions](https://support.apple.com/en-ge/guide/apple-configurator-mac/cad4cd08c03/mac) document personal Apple Account sign-in and verification before assigning apps. Installation can alternatively be completed in the iPad's own App Store. Authentication secrets and account identifiers are excluded from this report. Until target installation is verified, iPad screenshots, authenticated features, instrumentation and behavioral comparisons remain pending rather than falsely marked completed or silently substituted with Mac observations.
