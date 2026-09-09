# CM12 PRBAS dual-energy correction full corpus

Evidence label: **reference candidate** corroborated by three retained
executable lineages. This package establishes engineering compatibility at the
displayed contract precision; it is not physics approval and does not by itself
accept or publish the candidate.

## Candidate identity

The run used exact committed candidate
`8752594e44d4eb2b5be6c894223597b51de54615`. The candidate preserves the
legacy PRBAS post-scale energy and angular-momentum ownership identified by the
selector-134 and selector-135 supply diagnostics. Its correction and focused
evidence are committed in the candidate ancestry.

`summary.txt` records the exact candidate as `outputs_commit`. The seam build
manifest binds the executable hashes, kernel and fixture sources, archived
Fortran source commit, CM12 solution identity, and strict probe settings.

## Execution

The isolated sequential runner used Ubuntu 24.04, GNU Fortran 13.3.0, and
x86_64 emulation. It built and exercised:

- the modern headless executable;
- the typed PRBAS candidate;
- the checked-in arndt64 executable;
- the checked-in GWDAC executable.

The run required the typed candidate and disabled the historical request-probe
mismatch allowance:

```text
candidate_required=1
seam_engine=seam
request_probe_mismatch_allowed=0
```

The runner completed every command and fixture rather than stopping at the
first disagreement.

## Result

All 14 runner commands passed. All `24/24` fixtures and `288/288` displayed
records are exact across the four executable paths:

```text
command_failures=0
fixture_failures=0
oracle_failures=0
candidate_failures=0
result=pass
```

The result covers 11 DSG fixtures and 13 choice-1 amplitude fixtures.
`fixture-gate.tsv` records exact per-fixture hashes and has SHA-256
`a36cec23cbf1a0055f8525b5e818f662bd38430dd657c33b826fdf1cce854098`.

The strict candidate build also passed the immutable dataset and solution
loaders, pure layer and PRDA/DSG checks, request orchestration, hadronic
dispatch, form-contribution, negative-contract, and threshold-rescaling probes.

## Reproducibility prerequisite

The runner redirects probe reports below its run-specific report root.
`build-cm12-seam` currently expects three established diagnostic inputs below
that same root. This package pre-seeded the committed inputs used by prior
successful corpus runs:

```text
353f916c65a1d531ee2c3b34c574b4e1c8ae02f3e5f09580f72e156e17f69713  hadronic-pipeline-diagnostic/legacy-pipeline-trace.tsv
1578f1015d06b6b853d555e31c09734364bdea944c74234fd870fcc494e683e8  cm12-form-diagnostic/legacy-form-trace.tsv
ae88b10b0d0b049f4c76f335e6f63c12956cab000d103209311cdd8550da2a6b  cm12-form-diagnostic/legacy-target-summary.tsv
```

An earlier clean retry completed all 24 fixtures exactly but returned failure
because those report-root prerequisites were absent. Pre-seeding them changes
no source, fixture, expected result, tolerance, or oracle. The report-root
coupling remains classified as harness debt.

## Gate

This is a full-corpus candidate pass, not formal Gate 1 or Gate 2. No production
access, formula port, frontend work, `pdesd` work, or Phase 3 work occurred.
Publication remains gated on review of the evidence commit followed by the
formal gates and explicit acceptance.
