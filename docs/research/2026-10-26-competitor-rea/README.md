# CardPointers and MaxRewards REA investigation

Status: **completed offline investigation**, delivered through [PR #81](https://github.com/novus-tech-tw/CardWise/pull/81). All selected native, extension and bytecode work is finished; owned analysis jobs are closed. Server-side and live banking behavior remain explicit method limits, with no further login or GUI intervention pending.

- [Consolidated findings](report.md)
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
