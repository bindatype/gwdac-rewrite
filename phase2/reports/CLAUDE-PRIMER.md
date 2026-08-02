# Claude primer: CM12 PRBAS replacement

Date: 2026-08-02

Repository:
`/Users/maclach/Documents/Codex/2026-07-29/gwdac/outputs`

Branch: `main`

## Where we are

There are three distinct checkpoints:

- `2f8caec` is the last accepted evidence checkpoint. It proves that the
  pion-plus, 1000 MeV, 90-degree discrepancy is fully attributable to omitted
  non-1xx forms.
- `9cb0009` is an intentionally failing WIP candidate. It preserves the
  attempted 60-form implementation so another agent can diagnose it. It is
  not an accepted PRBAS replacement.
- `516c375` is the latest diagnostic evidence checkpoint. It identifies the
  frozen hadronic dispatch path without changing or accepting the candidate.

Established reference evidence:

- CM12 contains 60 active forms: 34 1xx and 26 non-1xx.
- Pion-plus uses 40 of them: 22 1xx and 18 non-1xx.
- All 22 applicable 1xx scalar multipoles match the frozen calculation.
- Replaying all 40 frozen per-form contributions in
  `family -> branch -> orbital_l` order reproduces every final amplitude
  component exactly.
- That replay gives DSG `2.03560233`, displayed as `0.2036E+01`.
- The modern headless build and both checked-in historical executables produce
  the same displayed result.

The WIP candidate:

- Adds `cm12_non_cm12_seam.f90`, an experimental translation of retained forms
  3, 21, and 25.
- Extends typed request orchestration to the 40 pion-plus forms in frozen
  order.
- Produces DSG `2.69659853` for the target request.
- Matches 0 of the 18 applicable frozen non-1xx multipoles.
- Has not run the full 24-fixture, 288-record gate because the focused exact
  request fixture already fails.

This establishes a compatibility regression, not a physics judgment. The
oracles establish retained SAID behavior; stakeholder physics review is still
required before calling that behavior scientifically correct.

The repository currently has uncommitted generated build reports and raw
diagnostic transcripts from stopped or focused runs. Use commit `516c375` in
a clean worktree or clone as the handoff source of truth. Use `2f8caec` for
the last accepted orchestration evidence and `9cb0009` for the failing
candidate itself.

## Read this first

1. `phase2/reports/hadronic-pipeline-diagnostic/README.md`
   - Latest runtime result, hypothesis determination, hashes, and stop gate.
2. `phase2/reports/cm12-form-diagnostic/CANDIDATE-HANDOFF.md`
   - Exact candidate failure, source hashes, and the immediate isolation point.
3. `phase2/reports/cm12-form-diagnostic/README.md`
   - Accepted quantitative proof that the form-count gap explains the original
     mismatch.
4. `phase2/reports/cm12-form-diagnostic/cm12-form-attribution-summary.txt`
   and `cm12-form-attribution.tsv`
   - Counts, exact-equality results, and per-form reference evidence.
5. `phase2/kernel/cm12_non_cm12_seam.f90`
   - The failing experimental forms 3/21/25 translation.
6. `phase2/kernel/cm12_request_kernel.f90`
   - Typed orchestration and preserved accumulation order.
7. `phase2/kernel/cm12_prsd_pipeline_trace.patch`,
   `cm12_prsd_hadronic_trace.patch`, and `cm12_prsd_pure.patch`
   - Diagnostic instrumentation applied only to isolated build copies of the
     frozen Fortran.
8. `phase2/scripts/run-cm12-hadronic-pipeline-diagnostic`,
   `build-cm12-seam`, and `run-cm12-form-diagnostic`
   - Reproducible build and attribution entry points.
9. `phase2/scripts/run-cm12-gate`
   - Clean-checkout absolute gate across the modern build, arndt64 executable,
     GWDAC executable, and candidate.
10. `phase2/contracts/pion-photoproduction-dsg-v1.md`,
   `pion-photoproduction-amplitude-v1.md`, and
   `cm12-pure-kernel-interface.md`
   - Retained contracts and acceptance rule.

Useful history:

```text
516c375 evidence: identify CM12 hadronic dispatch divergence
f366d73 diagnostic: trace CM12 hadronic dispatch pipeline
7c53192 diagnostic: capture first CM12 hadronic divergence
9cb0009 wip: preserve failing CM12 60-form candidate
2f8caec evidence: attribute CM12 non-1xx form residual
a67e4ea diagnostic: instrument CM12 form attribution
77c0ebb test: record failed PRBAS clean-checkout gate
e2b4d5c ci: add clean-checkout CM12 fixture gate
f54532e diagnostic: preserve failed PRBAS orchestration attempt
abfc13c chore: reconstruct accepted CM12 baseline
```

## Prior input diagnostic

The authorized forced-legacy versus candidate hadronic-input comparison is
complete. Read:

`phase2/reports/hadronic-input-diagnostic/README.md`

The first divergence occurs on
`family=1, branch=1, legacy_l=5, selector=25, state=3`:

```text
legacy EPX/EPXX    = 0.0
candidate EPX/EPXX = 849.95721435546875
```

The frozen `PRDLT` initializes saved `BCOFFM=-1` and zeros `EPX` once when the
current `BCOFF` differs. The candidate unconditionally calls `PNSM05` with the
calculated final-meson energy. This source mechanism corroborates the captured
first divergence.

Across all 18 applicable rows, rotation form, base form, state, selector,
`QCM`, and `ZKCM` are exact. `EPX/EPXX` are exact for 17/18 rows. `TER/TEI`
match 0/18, but those later differences were not investigated because the
authorized stop condition was the first differing input.

That report stopped before investigating the later `TER/TEI` divergence.

## Latest pipeline diagnostic

The authorized `PRDLT -> PNPWI -> PNMOD -> ADDRESK` runtime diagnostic is
complete at `516c375`. Read:

`phase2/reports/hadronic-pipeline-diagnostic/README.md`

The first retained `TER/TEI` divergence is the same first non-`1xx` row:

```text
family=1, branch=1, legacy_l=5, selector=25
legacy PNPWI EIN=0.0, dispatch=none, TER/TEI=0.0,0.0
candidate direct PNSM05 energy=849.95721435546875
candidate TER/TEI=-0.0052219554781913757,0.0032694728579372168
```

Across the 18 retained rows:

- `PNMOD` is a no-op on 18/18 (`NFX=0`, branch 0, zero `PG`);
- `ADDRESK` is a no-op on 18/18 (`NF=0`, zero `PG`, exact pre/post);
- row 1 does not dispatch because the prior `BCOFFM` reset supplies zero
  energy;
- rows 2-18 select branch 7 (`PNTEST`), never branch 10 (`PNSM05`);
- the first dispatch title is `M05`, then `PNTEST` writes `SP00` into the
  saved title state;
- `TER/TEI` match the candidate on 0/18 rows.

The focused instrumented target remains byte-identical at displayed precision
to the accepted target result. This identifies the compatibility boundary; it
does not accept a fix or the WIP candidate.

No fix is authorized. Wait for explicit direction before changing title
dispatch, saved-state sequencing, energy dithering, orchestration, or formulas.

## Constraints still in force

- CM12 pion photoproduction only.
- Do not touch other SAID engines or the pnpolw lineage discrepancy.
- Do not alter tolerances, fixtures, or oracle output.
- Do not make warning-driven fixes without a dedicated fixture.
- Do not edit comments in frozen `prsd.f`, `prsd2.f`, `pru.f`, or `cmmwp.f`.
- Do not decide the separate background-formula porting policy.
- Do not begin Phase 3.
- Label new evidence as oracle, captured, reference, or inferred.
- Physics/domain review remains pending regardless of regression results.
