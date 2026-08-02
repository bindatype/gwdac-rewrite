# CM12 PRBAS and oracle status

Date: 2026-08-02

Evidence labels:

- **oracle**: displayed typed records shared exactly by the modern headless
  build and both checked-in historical executables;
- **captured**: experimental and diagnostic runs retained in this repository;
- **reference**: static source, fixture, and report contents;
- **inferred**: interpretations not established by an isolated execution.

Physics/domain review remains pending. A passing compatibility test does not
scientifically endorse the retained behavior.

## Status table

| Subject | Scope executed | Result | Meaning |
| --- | --- | --- | --- |
| Frozen oracle triad: modern headless `prsdd`, checked-in arndt64 executable, checked-in GWDAC executable | 11 DSG fixtures / 138 records and 13 choice-1 amplitude fixtures / 150 records | **PASS: 24/24 fixtures; 288/288 records byte-identical at displayed precision** | Accepted compatibility authority for the frozen snapshot. |
| Immutable CM12 solution/dataset seam with legacy request path retained | Same 11 DSG and 13 amplitude fixtures | **PASS: 24/24 fixtures; 288/288 records match the modern frozen reference** | Accepted Phase 2 seam; this does not replace PRBAS. |
| First experimental 34-form typed PRBAS candidate, commit `e2b4d5c` | Clean-checkout 24-fixture gate | **FAIL: 3/24 pass, 21/24 fail**; DSG 2/11 pass, amplitudes 1/13 pass | Build and commands run, but the candidate is not behaviorally compatible. |
| Frozen 40-applicable-form replay diagnostic, commit `2f8caec` | One pion-plus fixture at `Elab=1000 MeV`, `Acm=90 degrees` | **PASS: 40/40 per-form deltas, final amplitudes, and DSG exact** | Forensic accounting proof, not a PRBAS implementation. It establishes the frozen target value and accumulation order. |
| Experimental 40-applicable-form/direct-`PNSM05` WIP candidate, commit `9cb0009` | Targeted pion-plus fixture only | **FAIL:** DSG `2.69659853` versus frozen replay `2.03560233`; non-`1xx` multipoles 0/18 exact; full gate not run | Intentionally failing diagnostic candidate. It must not be described as a valid SM05 result or accepted replacement. |
| Instrumented frozen hadronic pipeline, commits `f366d73` and `516c375` | Same targeted pion-plus fixture | **PASS for diagnostic integrity:** displayed choice-1 amplitudes remain byte-identical to the retained target; candidate `TER`/`TEI` match 0/18 | Identifies legacy `PNTEST`/SP00 dispatch and saved-state boundaries without changing the oracle. No full corpus was authorized. |
| Current public SAID website | One public DSG request with the same solution, reaction, energy, and angle | **Captured only:** displayed DSG `2.098` | Neither a frozen oracle nor a candidate acceptance test. Production internals and lineage are unknown. |

## Frozen oracle reference

The easiest directly readable frozen reference is:

`phase2/reports/corpus/modern/cm12_pi_plus_dsg_baseline.results.tsv`

Its `Acm=90.000` row contains the oracle token:

```text
Acm	90.000	0.2036E+01	0.0000E+00	58.15	0.2845E+01
```

The identical arndt64 and GWDAC tables are:

- `phase2/reports/corpus/arndt64/cm12_pi_plus_dsg_baseline.results.tsv`
- `phase2/reports/corpus/gwdac/cm12_pi_plus_dsg_baseline.results.tsv`

The unrounded exact-replay evidence is:

`phase2/reports/cm12-form-diagnostic/cm12-form-attribution-summary.txt`

It records:

```text
full_dsg_exact=T
oracle_dsg_display=0.2036E+01
replayed_all_dsg=2.03560233E+00
```

The displayed value is the three-engine oracle. `2.03560233` is the captured
exact frozen replay underlying that displayed token; the historical programs
do not expose all of those digits in their user-facing table.

## Percentage distinctions

Using `2.03560233` as the frozen exact replay:

| Comparison | Absolute difference | Relative difference |
| --- | ---: | ---: |
| Experimental direct-`PNSM05` WIP `2.69659853` vs frozen `2.03560233` | `0.66099620` | `32.471775%` |
| Live website `2.098` vs frozen `2.03560233` | `0.06239767` | `3.065317%` |

The approximately 3% discussion applies only to the live website difference.
The experimental WIP result is about 32.5% high and fails the focused
compatibility check.

## Evidence paths

- Frozen corpus validation:
  `phase2/reports/prsdd-corpus-validation.md`
- Frozen amplitude validation:
  `phase2/reports/prsdd-amplitude-corpus-validation.md`
- Failed 34-form clean-checkout gate:
  `phase2/reports/gate/e2b4d5c5ba68-20260730T043729Z/summary.txt`
- Per-fixture candidate results:
  `phase2/reports/gate/e2b4d5c5ba68-20260730T043729Z/fixture-gate.tsv`
- Exact frozen form replay:
  `phase2/reports/cm12-form-diagnostic/README.md`
- Direct-`PNSM05` WIP handoff:
  `phase2/reports/cm12-form-diagnostic/CANDIDATE-HANDOFF.md`
- Hadronic dispatch diagnostic:
  `phase2/reports/hadronic-pipeline-diagnostic/README.md`
- Live website check:
  `phase2/reports/live-said-website-investigation/README.md`

## Stop

This report changes no implementation, fixture, tolerance, oracle, or
scientific decision. The Phase 2 pause gate remains active.
