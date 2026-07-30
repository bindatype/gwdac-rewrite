# Claude primer: CM12 PRBAS replacement

Date: 2026-07-30

Repository:
`/Users/maclach/Documents/Codex/2026-07-29/gwdac/outputs`

Branch: `main`

## Where we are

There are two distinct checkpoints:

- `2f8caec` is the last accepted evidence checkpoint. It proves that the
  pion-plus, 1000 MeV, 90-degree discrepancy is fully attributable to omitted
  non-1xx forms.
- `9cb0009` is an intentionally failing WIP candidate. It preserves the
  attempted 60-form implementation so another agent can diagnose it. It is
  not an accepted PRBAS replacement.

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

The repository currently has uncommitted generated build reports and an
untracked candidate diagnostic directory from the stopped run. Use commit
`9cb0009` in a clean worktree or clone as the handoff source of truth.

## Read this first

1. `phase2/reports/cm12-form-diagnostic/CANDIDATE-HANDOFF.md`
   - Exact candidate failure, source hashes, and the immediate isolation point.
2. `phase2/reports/cm12-form-diagnostic/README.md`
   - Accepted quantitative proof that the form-count gap explains the original
     mismatch.
3. `phase2/reports/cm12-form-diagnostic/cm12-form-attribution-summary.txt`
   and `cm12-form-attribution.tsv`
   - Counts, exact-equality results, and per-form reference evidence.
4. `phase2/kernel/cm12_non_cm12_seam.f90`
   - The failing experimental forms 3/21/25 translation.
5. `phase2/kernel/cm12_request_kernel.f90`
   - Typed orchestration and preserved accumulation order.
6. `phase2/kernel/cm12_prsd_hadronic_trace.patch` and
   `cm12_prsd_pure.patch`
   - Diagnostic instrumentation applied only to isolated build copies of the
     frozen Fortran.
7. `phase2/scripts/build-cm12-seam` and
   `phase2/scripts/run-cm12-form-diagnostic`
   - Reproducible build and attribution entry points.
8. `phase2/scripts/run-cm12-gate`
   - Clean-checkout absolute gate across the modern build, arndt64 executable,
     GWDAC executable, and candidate.
9. `phase2/contracts/pion-photoproduction-dsg-v1.md`,
   `pion-photoproduction-amplitude-v1.md`, and
   `cm12-pure-kernel-interface.md`
   - Retained contracts and acceptance rule.

Useful history:

```text
9cb0009 wip: preserve failing CM12 60-form candidate
2f8caec evidence: attribute CM12 non-1xx form residual
a67e4ea diagnostic: instrument CM12 form attribution
77c0ebb test: record failed PRBAS clean-checkout gate
e2b4d5c ci: add clean-checkout CM12 fixture gate
f54532e diagnostic: preserve failed PRBAS orchestration attempt
abfc13c chore: reconstruct accepted CM12 baseline
```

## Likely next step

Do not redesign orchestration again. Isolate the first upstream mismatch in the
18 non-1xx forms.

1. Complete the instrumented legacy build from `9cb0009`. The two patches now
   pass sequential zero-fuzz dry-runs against the checksummed frozen source.
2. Run the forced-legacy target request with
   `CM12_FORCE_LEGACY_PRBAS=1`. Capture every `CM12DIAG HADRONIC` row emitted
   for pion-plus, 1000 MeV, 90 degrees.
3. Add a diagnostic-only probe for the candidate side and compare, per form:
   `EPX`, `EPXX`, `TER`, `TEI`, `QCM`, `ZKCM`, state index, and form selector.
4. Stop at the first differing input. Do not change the translated formulas
   until the input divergence is identified.

The leading hypothesis is an unmapped energy-scaling or hadronic-state
boundary around legacy `PNPWI`/`PNSM05`, possibly involving `EPXX` or saved
state. This is inferred, not confirmed.

The strict request fixture intentionally stops `build-cm12-seam` before the
later form-diagnostic probe is linked. Preserve that fixture. If needed, move
diagnostic-probe compilation earlier or create a dedicated diagnostic build
entry point; do not bypass or weaken the exact check.

If all 18 non-1xx multipoles become exact, rerun the focused attribution first.
Only then run:

```sh
phase2/scripts/run-cm12-gate
```

A 24-fixture/288-record byte-identical pass is still only a candidate result.
Report it and stop for explicit acceptance.

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
