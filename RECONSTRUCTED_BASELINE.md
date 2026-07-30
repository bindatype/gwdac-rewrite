# Reconstructed accepted baseline

Reconstructed: 2026-07-29

This commit reconstructs the last accepted CM12 Phase 2 boundary before the
failed experimental `PRBAS` orchestration attempt. The deliverable did not
have version control at that point, so this commit is not represented as a
byte-for-byte historical snapshot and its timestamp is not backdated.

The reconstruction removed only the unaccepted request-orchestration
experiment, rebuilt the previously accepted seam from arndt64 source commit
`f6c81d01a1fe8b007c247acc2213f821a62dc4f2`, and reran the accepted fixture
comparisons.

Verification:

- 11 DSG fixtures, 138 typed records, exact at displayed precision.
- 13 choice-1 amplitude fixtures, 150 typed records, exact at displayed
  precision.
- Modern headless, checked-in arndt64, and checked-in GWDAC result hashes
  remain correlated by the accepted comparison reports.
- `phase2/reports/cm12-seam-parity.tsv` SHA-256:
  `0276d0631d60b366d7c2142018b4aa4413f51dabca1839670adf78ea6c15f55c`.
- `phase2/reports/prsdd-corpus-comparison.tsv` SHA-256:
  `aab9df253ca782994f51396002b3e426bcb079ce9bf7ac85b758e8ac60119d4a`.
- `phase2/reports/prsdd-amplitude-corpus-comparison.tsv` SHA-256:
  `b7923b7d4f5f4182e82c7ab446cb2affe7bac733102af6484afbef3fed38addc`.

Evidence classification: reconstructed reference, corroborated by the
surviving oracle/corroborated-reference result hashes. Physics review remains
pending.
