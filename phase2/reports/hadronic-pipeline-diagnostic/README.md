# CM12 hadronic pipeline diagnostic

Date: 2026-08-02

Evidence labels:

- **captured**: the new forced-legacy runtime trace and the previously
  captured candidate hadronic-input table;
- **reference**: the frozen dispatch/control flow and the candidate's direct
  `PNSM05` call;
- **inferred**: mechanism statements explicitly identified below.

Physics/domain review remains pending. This report diagnoses retained
implementation behavior; it does not scientifically endorse that behavior.

## Scope

- CM12 pion-plus only
- photon laboratory energy: 1000 MeV
- center-of-mass angle: 90 degrees
- target form order: `family -> branch -> orbital_l`
- instrumentation commit: `f366d73`
- frozen arndt64 source commit:
  `f6c81d01a1fe8b007c247acc2213f821a62dc4f2`
- solution SHA-256:
  `dbcaae30bbf44aca6e5482fc2b10b81cb6e1033cf41061bc089d5f6a85576522`

No orchestration, formula, fixture, tolerance, or oracle change was made.
Instrumentation is applied only to isolated build copies of the frozen
Fortran.

## Result

The first retained `TER`/`TEI` divergence is row 1:

```text
family=1
branch=1
legacy_l=5
form_selector=25
legacy PNPWI EIN=0.0
legacy dispatch=none
legacy TER/TEI=0.0,0.0
candidate direct PNSM05 energy=849.95721435546875
candidate TER/TEI=-0.0052219554781913757,0.0032694728579372168
```

This row carries forward the already-established one-time `BCOFFM` energy
reset. The new trace shows its downstream consequence: `PNMOD` is a no-op,
then `PNPWI` returns before selecting a hadronic solution because `EIN` is
zero. The candidate instead unconditionally calls `PNSM05` at the calculated
final-meson energy.

Rows 2-18 expose a second, general dispatch mismatch:

- all 17 dispatching retained rows select branch `N=7` (`PNTEST`);
- no retained row selects branch `N=10` (`PNSM05`);
- the first dispatched title is captured as `M05`, which does not equal the
  `SM05` dispatch token; `PNTEST` then replaces the saved title with `SP00`;
- the title transition also applies the frozen `+/-0.001 MeV` saved-energy
  perturbation behavior;
- the candidate direct call has neither the branch-7 path nor that saved
  title/energy sequencing.

`TER` and `TEI` match the candidate on 0/18 retained rows.

## Hypotheses

The runtime evidence resolves the three hypotheses from the review notepad:

- **Solution/title dispatch is the active divergence.** Captured legacy
  execution selects `PNTEST`, while the candidate source directly calls
  `PNSM05`.
- **`PNMOD` interception does not explain this fixture.** `NFG(N,L)=0`, the
  selected branch is no-op, `PG(1:3)=0`, and `TR/TI` remain unchanged on all
  18 retained rows.
- **`ADDRESK` does not explain this fixture.** `NF=0`, `PG(1:3)=0`, and its
  pre/post `TER/TEI` values are exact on all 18 retained rows.

The inference is limited to this retained CM12 target fixture. It identifies
why the experimental kernel's direct `PNSM05` assumption does not reproduce
the frozen path; it does not authorize a correction.

## Regression Check

The instrumented target's displayed choice-1 amplitudes are byte-identical to
the accepted reference target table:

```text
Acm  90.0  -10.22  -4.52  2.77  -0.81  1.49  15.64  2.76  5.33
```

The broader `build-cm12-seam` command linked the instrumented binary, then
stopped at the already-known experimental request-probe `STOP 6`. The focused
diagnostic entry point completed successfully. No full corpus gate was run,
because this session authorized only the single diagnostic fixture.

## Artifacts

- `legacy-target.stdout.gz`: deterministic compressed raw legacy transcript.
- `legacy-target-result.tsv`: normalized displayed target amplitudes.
- `legacy-pipeline-trace.tsv`: all 26 active non-`1xx` rows with correlated
  `PRDLT`, `PNMOD`, `PNPWI`, and `ADDRESK` fields.
- `retained-candidate-comparison.tsv`: the 18 retained pion-plus rows compared
  with the previously captured candidate inputs.
- `summary.txt`: checked counts and first divergence.
- `manifest.txt`: source, binary, patch, fixture, and evidence hashes.
- `../../kernel/cm12_prsd_pipeline_trace.patch`: build-copy-only tracing.
- `../../scripts/run-cm12-hadronic-pipeline-diagnostic`: reproducible focused
  entry point.

## Stop

The authorized diagnostic is complete. No fix, orchestration change, formula
translation, formula-porting decision, or Phase 3 work follows without a new
explicit direction.
