# CM12 GO3PR oracle comparison

Generated: 2026-07-29T13:28:24Z

## Result

The current-GFortran source build, checked-in arndt64 executable, checked-in
GWDAC executable, and committed GWDAC `TPR` transcript produce byte-identical
19-row DSG tables for the captured CM12 command deck.

- Result-table SHA-256: `80868398e786c36ff11ef6ef4388e7896fc867d69e319c843b1923d5819a86c3`
- Maximum absolute difference in every parsed field: `0`
- Maximum relative difference in every parsed field: `0`
- Both historical executable runs: exit `0`, empty stderr, normal SAID exit
- Shared generated files `SAID.TMP`, `SAID.PCT`, `SAID.LOG`, and
  `fort.7`: byte-identical across all three executable runs

## Interpretation

For this fixture, exact text equality at the legacy program's displayed
precision is the regression requirement. This establishes behavioral
correspondence for one workflow; it does not establish hidden floating-point
identity, correctness of the underlying physics, or parity for other inputs.
Higher-precision absolute and relative tolerances remain a Phase 2 domain
decision.

The two checked-in executables produce byte-identical full stdout. The modern
stdout is not byte-identical because bibliography punctuation differs after
the source-level Hollerith compatibility overlay. The parsed scientific table
and tested generated artifacts remain exact. The committed GWDAC `TPR`
transcript contains the same result table but an older run date, so it is
retained as corroborating `captured` evidence rather than the primary oracle.

## Evidence

- Machine-readable summary: `go3pr-oracle-comparison.tsv`
- Per-field differences: `go3pr-numeric-differences.tsv`
- Captured transcript extraction: `go3pr-captured-gwdac-tpr-dsg.tsv`
- Historical manifests: `go3pr-historical-*-manifest.txt`
- Opened-file inventories: `go3pr-historical-*-opened-files.txt`
