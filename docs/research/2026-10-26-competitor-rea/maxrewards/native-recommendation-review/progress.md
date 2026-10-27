# MaxRewards native recommendation review progress

Status: **Finished within the authorized offline static scope** on 2026-10-26. This supplement is independent of the main native REA metadata report. No target execution, account creation, login, bank action or encrypted-code bypass was performed by this workstream. Runtime/server questions below are scope limits; they do not await user intervention.

## Deliverables

- [Report](report.md): observed bytecode, business inference and unresolved input/server behavior separated.
- [Function evidence](function-evidence.json): 100 additional disassemblies, original bytecode offsets/lengths/digests, output digests and pseudocode fallback status.
- [Source anchors](source-anchors.json): 28 exact source ranges and digests.
- [Coverage](coverage.json): bounded exhaustive searches and semantic-review scope.
- [Validation](validation.json): all 100 source spans/digests and retained outputs verified, zero errors.
- [Archive manifest](archive-manifest.json): method-script/candidate-ledger digests for the retained local archive. Original carrier, disassembly and complete candidate lists remain in that archive; see [artifact policy](../../artifacts.md).

## Identity and method

Input: already acquired plaintext `maxrewards/native/main.jsbundle`, Hermes96, SHA-256 `efe8a8901364e9a633d0edb1810687f18932ebaf306995c235fccaef23278ba9`, 12,633,156 bytes. Static decoder: P1sec/hermes-dec commit `2e796663e1fedb93dca51060797ebf3327b3fedb`. `HBC-F`/`HBC-A` are local offline labels, not REA MCP Evidence IDs. Decompiled pseudocode is not original or reconstructed runnable JavaScript. Fifty-seven standalone pseudocode results fell back to disassembly; explicit bytecode and parent closure bindings support the reported findings.

All 68,786 function headers and 72,616 strings inventoried. Every direct-operand pass examined 49,418 unique bodies / 2,098,689 instructions with zero decode errors. Broad258 / focused20 / choice10 identifier searches produced 496 / 85 / 116 matching functions, respectively; counts overlap. A separate20-key serialized object-buffer search produced six matching functions and did not read values. Candidate inventory coverage is exhaustive for the selected terms, not a semantic audit of all app functions. Full arbitrary dynamic-key and server logic is outside this bound.

## Question ledger

| Question | Static status | Evidence | Exact limit / next evidence if scope changes |
| --- | --- | --- | --- |
| Cap definition choice and removed/deprecated/category eligibility | Complete for recovered helpers | HBC-A01–A03 / F61113, F61116, F61118 | Server-supplied definition records can differ over time |
| Category cap status and rate-derived spent | Complete for recovered mapper | HBC-A04–A11 / F27893, F27895, F27896, F27937 | Input amount aggregation, units/period and universal ranking consumption unknown; would require upstream implementation or execution with synthetic authorized data |
| Posted/pending signup remaining spend | Complete for UI arithmetic | HBC-A24–A26 / F28821, F56846, F56859 | Supplied totals and transaction reconciliation unknown |
| Temporal eligibility and quarter labels | Complete for recovered predicate/helpers | HBC-A11–A14 / F23670, F23667, F67348 | Bank-confirmed activation not checked in this predicate; upstream gating unknown |
| Saved selectable choice and current option rows | Complete for recovered selector | HBC-A15–A20 / F27939, F27942, F27944, F27946, F67362, F67364 | Bank acceptance/change effective date unknown |
| Signup value versus recommendation weighting | Partial by design | HBC-A21–A27 / F27689, F27690, F27698, F38985 | Bonus summary is explicit; merchant sort reads percentage only; upstream/server signup weighting remains unknown |
| Merchant/category override precedence | Complete for recovered record helper | HBC-A28 / F27964 | Purchase-time MCC/search route equivalence unknown |
| Live native/server outcomes | Outside offline scope | No execution evidence produced | Optional future authorized runtime/server inspection, not required for this deliverable |

`isRotating` animation matches were rejected as rotating-reward evidence. Existing CardWise statement-credit tracking, signup tracking and widgets are recognized as baseline features. Recommendations focus on cap-state propagation, rule explanations and improvements to existing tracking.
