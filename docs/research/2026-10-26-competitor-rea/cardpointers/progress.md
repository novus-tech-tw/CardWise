# CardPointers REA progress

Updated: 2026-10-27 UTC. Worker: cardpointers_rea. All output is outside the CardWise Git repository; root owns PR integration.

## Completed first pass

- Acquired official Mozilla-linked Firefox XPI 8.0.8; verified SHA-256 against AMO API metadata.
- Ran actual REA static analysis of all six JS sources; six parsed, zero parse failures. Retained original partial semantic coverage rather than overstating completeness.
- Preserved complete first-pass evidence ledger, exact source snippets and provenance, and unauthenticated browser runtime on legacy web app.
- Recovered basic merchant/category list-to-wallet/profile matching, issuer adapters, offer synchronization request construction and own-account token flow.

## Completed deeper pass

- Completed independent AST inventory of all six source files and exact webpack factory extraction with original file offsets/digests. Derived files are not represented as a complete runnable extension.
- Analyzed all 344 content webpack factories without resource omissions by reusing the complete full app factory context and seven independent CLI batches for the other 343 factories. All final batches have zero parse failures, no semantic truncation and zero omitted nodes/relations. All 15 popup factories, 132 vendor factories, three small original files and 239 finer content method partitions were also analyzed. Dynamic-binding unknowns remain explicit.
- Recovered local Amex offer-enrollment ranking: category aliases and category total_value comparison, manual inventory priority tie-break, original candidate order, and configured strategy fallback. This is separate from generic shopping recommendation order.
- Inspected issuer activation/enrollment state filters, mapping/sync branches, common offer collection and upload construction. Dynamic this-based interprocedural reachability is not claimed as proved.
- Completed actual returned semantic-node follow-up with one resolved caller edge in the Amex category helper. Zero-match or ambiguous traces are retained.
- Focused Safari extension background/products analysis corroborates native getWallet request, own-account token/pro/signedOut handling, and web/native account UUID switching checks. Host/bundle version 8.1.4 differs from web manifest version 8.1.3. Native bridge was not executed.
- Exported complete deep MCP Evidence and independent CLI Evidence. Completed deep-findings.md, compact batch ledger, exact partition provenance and bounded-field searches. Every extracted exact source partition was verified against its original digest and offsets.

## External boundaries

- No bank login, offer activation, signup, purchase or subscription execution is authorized in this pass.
- Root's separate native worker obtained the Mac app and owns native binary/GUI work. This worker inspected only public Safari packaged resources/plists. Native iOS behavior remains externally blocked here; Android acquisition is separately owned.
- Server ranking, data retention and payload sanitization cannot be established from client source alone.

## Delivery

- Main first-pass report: report.md; deeper static coverage and updated status: deep-findings.md.
- All work authorized within this worker's public extension/static scope is complete. Remaining questions in deep-findings.md are externally blocked or separately owned, with exact evidence boundaries and required next evidence documented.
- Root integrates the written findings into branch docs/competitor-rea-20261026 and owns the requested PR. No CardWise source was changed by this worker.

This public copy contains status and compact metadata. Large Evidence and acquired program code remain in the [retained local archive](../artifacts.md).
