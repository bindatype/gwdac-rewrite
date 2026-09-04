# CM12 PRBAS pre-grid-state full corpus

Evidence label: **reference candidate failure** corroborated by three retained
executable lineages. This is the complete pre-correction corpus result retained
to show why the typed grid-lifetime correction was required.

The isolated sequential gate completed all 14 commands and all 24 fixtures.
The modern headless, checked-in arndt64, and checked-in GWDAC executable results
were exact for every fixture and all 288 displayed records. The candidate was
exact for 21 fixtures and differed on three multi-point sweeps:

- `cm12_pi_plus_dsg_energy_sweep`
- `cm12_pi_plus_h1_energy_sweep`
- `cm12_pi_plus_h1_w_sweep`

`fixture-gate.tsv` has SHA-256
`ed52a19b86a28663e5955b49d37311512675e2f93ab2a9a3da834098813c6224`.
No fixture, expectation, tolerance, or oracle was changed in response. The
subsequent row-complete diagnostic localized the difference to dispatch state
lifetime between energy preparations.

This package records a failed candidate, not an accepted result or a physics
judgment. `manifest.sha256` was added when the candidate evidence was sealed;
the 513 pre-existing captured files were not modified.
