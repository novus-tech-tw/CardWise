# CardPointers and MaxRewards REA investigation

Status: **in progress**. The first public-artifact pass is recorded; parallel follow-up is expanding static coverage, acquiring additional shipped artifacts, and resolving native-app coverage. This is not a claim of full mobile-app analysis.

- [Consolidated findings](report.md)
- [Live progress and remaining work](progress.md)
- [Artifact and Evidence archive](artifacts.md)
- [CardPointers findings](cardpointers/report.md)
- [MaxRewards findings](maxrewards/report.md)
- [CardWise source baseline](cardwise-baseline.md)

The user requested maximum useful parallelism, durable progress, and delivery through a PR. Work is isolated on `docs/competitor-rea-20261026`. No app code is changed, and this PR must not be merged merely to store the investigation: pushes to `main` trigger an app release.

## Evidence standards

Reports distinguish observed artifact/runtime facts, official vendor claims, analyst inference, and unknowns. Every acquired distribution has an identity/hash; static observations do not imply execution. Complete parsing or a complete summary page does not establish complete semantic coverage. Remaining access or provider requirements stay explicit in the progress ledger.

Large Evidence exports and third-party distributions are kept in the retained local archive. This public repository contains analysis, provenance, source offsets/digests, and compact summaries rather than redistributing complete vendor bundles.
