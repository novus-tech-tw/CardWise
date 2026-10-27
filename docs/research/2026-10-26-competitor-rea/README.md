# CardPointers and MaxRewards REA investigation

Status: **paused at Rich's explicit request on 2026-10-27**. Preserve the existing analysis, both completed app logins and private evidence. No new offline investigation or device operation is queued; resume only when Rich explicitly asks. The [pause and resume checkpoint](continuation/pause-checkpoint-20261027.md) records completed observations, remaining cases, controller limits and private-evidence retention. PR #81 remains unmerged; publishing this checkpoint does not release the app.

- [Paused checkpoint and explicit-resume procedure](continuation/pause-checkpoint-20261027.md)
- [Consolidated findings](report.md)
- [iPad installation status and focused static followup](followup/README.md)
- [Live progress and remaining work](progress.md)
- [Artifact and Evidence archive](artifacts.md)
- [Unattended offline method](offline-method.md)
- [CardPointers findings](cardpointers/report.md)
- [CardPointers native Mac analysis](native/report.md)
- [MaxRewards findings](maxrewards/report.md)
- [MaxRewards native recommendation/cap review](maxrewards/native-recommendation-review/report.md)
- [CardWise source baseline](cardwise-baseline.md)

The user requested maximum useful parallelism, durable progress, and delivery through a PR. Work is isolated on `docs/competitor-rea-20261026`. No app code is changed, and this PR must not be merged merely to store the investigation: pushes to `main` trigger an app release.

## Evidence standards

Reports distinguish observed artifact/runtime facts, official vendor claims, analyst inference, and unknowns. Every acquired distribution has an identity/hash; static observations do not imply execution. Complete parsing or a complete summary page does not establish complete semantic coverage. Remaining access or provider requirements stay explicit in the progress ledger.

Large Evidence exports and third-party distributions are kept in the retained local archive. This public repository contains analysis, provenance, source offsets/digests, and compact summaries rather than redistributing complete vendor bundles.
