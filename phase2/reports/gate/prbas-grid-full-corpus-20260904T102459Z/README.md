# CM12 PRBAS typed grid-state full corpus

Evidence label: **reference candidate** corroborated by three retained
executable lineages. This package establishes engineering compatibility at the
displayed contract precision; it is not physics approval and does not accept or
publish the candidate.

## Candidate identity

The run used an uncommitted PRBAS candidate based on exact published
`dev@22493c500c5d84b6ffb2453f834edeced8442071`. Therefore the generated
`outputs_commit` records that base commit, not a candidate commit. The active
kernel and scripts were bind-mounted into the isolated container and are bound
by `candidate-source-scope.sha256`.

The candidate makes PRBAS grid lifetime explicit: typed dispatch state carries
between energy preparations, prepared energy multipoles are reused across
angles, and angle-dependent initial amplitudes are recalculated separately. Its
grid-state components are private, and its public negative-contract probe
covers non-printable formula titles and reaction-provenance mismatch.

## Execution

The isolated sequential gate used Ubuntu 24.04, GNU Fortran 13.3.0, and x86_64.
It built the modern headless baseline and candidate, then ran all DSG and
choice-1 amplitude fixtures through:

- the modern headless executable;
- the typed PRBAS candidate;
- the checked-in arndt64 executable;
- the checked-in GWDAC executable.

All 14 gate commands passed. The runner completed every fixture and did not
stop at a first divergence.

## Result

All `24/24` fixtures and `288/288` displayed records are exact. The three
retained executable lineages agree on every fixture, and the candidate agrees
with them on every fixture. This includes the three multi-point sweeps that
failed before the typed grid-lifetime correction.

- `command_failures=0`
- `fixture_failures=0`
- `oracle_failures=0`
- `candidate_failures=0`
- `fixture-gate.tsv` SHA-256:
  `a36cec23cbf1a0055f8525b5e818f662bd38430dd657c33b826fdf1cce854098`
- candidate headless executable SHA-256:
  `b67584161c13cfd08cc1c2e64702d5f12ebb662ae1232db761e9d7eade9817f3`

The candidate build also passed the immutable dataset and solution loaders,
pure layer and PRDA/DSG checks, four-request orchestration probe, 18-row
hadronic dispatch comparison, 40-form contribution comparison, and four-row
negative-contract probe.

## Gate

This is a full-corpus candidate pass, not acceptance. No Gate 1, full clean
Gate 2, integration, push, production access, formula port, frontend work,
`pdesd`, or Phase 3 work occurred. The next gate is exact-SHA review of the
candidate commit created from these bound sources and evidence.
