# Retained artifacts and Evidence

The complete local archive is `/Users/rich/Desktop/CardWise-REA-2026-10-26/`. It contains original public distributions, acquired web files, source-bound excerpts, REA JSON records, and progress files. This public PR retains reports and compact provenance instead of republishing complete third-party application bundles.

| Local archive path | Identity / purpose |
| --- | --- |
| `cardpointers/cardpointers_x-8.0.8.xpi` | Official Mozilla distribution; SHA-256 `691c287f0c640e5c0cefd77fed49c3e9e6a4630ee0c8461a3e2fdf6022327af3` |
| `cardpointers/extension/` | Extracted shipped extension; root identity in detailed report |
| `cardpointers/rea-evidence.json` | Initial 7-record portable REA ledger, 150,937,035 bytes when first verified |
| `cardpointers/source-anchors.json` | Original source paths, exact offsets and source/snippet digests; compact copy included in PR |
| `maxrewards/web-artifacts/` | Acquired public web source corpus; [manifest](maxrewards/artifact-manifest.json) included in PR |
| `maxrewards/rea-evidence-bundle.json` | Initial 6-record portable REA ledger, 94,636,146 bytes when first verified |
| `maxrewards/scenario-evidence.json` | Product-to-signup runtime, without collected credential/header/body values |
| `native/` | Native artifact acquisition and inspection results, added by the native workstream |

Current native originals are installed through the official Mac App Store at `/Applications/CardPointers.app` and `/Applications/MaxRewards.app/Wrapper/MaxRewards.app`. Static snapshots and derived carrier identities are recorded in the product/native ledgers. User containers, receipts, keychains and live account values are excluded from the public PR.

The [native Evidence index](native/evidence-index.json), [native binary provenance](native/binary-provenance.json), [native jobs](native/jobs.json), [CardPointers deep ledger](cardpointers/deep/analysis-summary-ledger.json) and [partition manifest](cardpointers/deep/cli-batches-compact.json) preserve subsequent analysis beyond the initial export sizes above. Consult each workstream's progress for the final retained bundle paths.

Each retained initial Evidence ID is recorded in the [consolidated report](report.md) and detailed product ledgers. Later exports can add records and change file size, so use the exact record ID and artifact digest rather than file size as semantic identity.

If the retained archive is unavailable, reacquire the exact public distribution version from the source URL recorded in the product report and verify the digest. Website builds can change between requests; a new build is a new artifact and must not be presented as reproducing the original hash or runtime bytes.
