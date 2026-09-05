# CM12 PRBAS Lifecycle-Correction Checkpoint A

Date: 2026-09-04

Held product candidate: `81b0d7c68df557f4d290d2c98f2c46f5ed489994`

Diagnostic/contract support commit:
`9a8a90f35accdf32b2d63f8814c78cf78729369f`

Evidence labels:

- **captured**: outputs produced by the diagnostic build and bounded decks in
  this package;
- **reference candidate**: exact comparisons against forced legacy PRBAS and
  the previously captured website observation; and
- **inferred**: the ownership model derived from the captured state changes.

This checkpoint adds diagnostic and regression-contract support only. It does
not implement a lifecycle correction, change formulas, fixtures, expected
values, tolerances, or oracles, or claim physics approval.

## Result

The lifecycle contract is deliberately **FAIL** at the held candidate:

| Contract field | Typed candidate | Forced legacy / target | Result |
| --- | ---: | ---: | --- |
| Complete GO5 rows | 0 / 1533 | 1533 / 1533 | FAIL |
| GO5 angles | 1533 / 1533 | 1533 / 1533 | PASS |
| GO5 predicted values | 0 / 1533 | 1533 / 1533 | FAIL |
| GO5 measured values | 1533 / 1533 | 1533 / 1533 | PASS |
| GO5 errors | 1533 / 1533 | 1533 / 1533 | PASS |
| GO5 Dchi values | 55 / 1533 | 1533 / 1533 | FAIL |
| GO3 pion-plus DSG | `0.2036E+01` | `0.2098E+01` | FAIL |
| Captured website DSG | `0.2036E+01` | `0.2098E+01` | FAIL |

The full 26-row live-entry lifecycle comparison is 23/26 exact. Rows 1-3
differ; row 1 is the first divergence because the typed path suppresses the
dispatch while the GO5-primed forced-legacy path dispatches. The remaining 23
rows are exact across coordinates, dispatch/title state, energy/dither state,
and hadronic complex value.

## Captured Lifecycle Model

One forced-legacy process loaded CM12 and evaluated the same 1000 MeV,
90-degree pion-plus DSG request twice, with a second `go2`/CM12 load between
evaluations:

1. The first sequence enters row 1 with `EPX=0`, suppresses its dispatch, and
   displays `0.2036E+01`.
2. The second sequence enters row 1 with retained
   `EPX=8.4995721435546875E+002`, dispatches branch 7 with title `M05` and
   previous title `SP00`, and displays `0.2098E+01`.

The captured behavior demonstrates that `go2` reloads the solution but does
not reset the frozen `PRDLT` saved cache. The typed PRBAS wrapper instead owns
`cm12_background_grid_state` as a local variable and starts a fresh lifecycle
on every PRBAS call. That ownership mismatch is the supported correction
hypothesis for the next separately authorized checkpoint. No correction was
attempted here.

At the final typed live entry, the captured ambient values are `IR=2`,
`IR0=0`, `NNBT=0`, `IT=1`, `NNL=6`, `IPRK=0`, zero nonzero `NFG` and `PG`
entries, `BCOFF=0`, `KILL=0`, and title words `CM12`, `M05`, `M05`. The full
ambient inventory distinguishes modeled, provenance-checked inputs from
remaining hidden eligibility and lifecycle boundaries.

## Reproduction

The ordinary build is unchanged unless the opt-in diagnostic patch is named.
The diagnostic executable was built from archived source
`f6c81d01a1fe4446d5ae291e15432cd58a884c30`; its SHA-256 is
`f3802c9e657bbbee0015acfe0a7fdd2eb7141ca45030f3ba0cd8910d0fc52a5c`.

After building with `CM12_PRBAS_DIAGNOSTIC_PATCH` set to
`/phase2/kernel/cm12_prbas_lifecycle_trace.patch`, run:

```sh
PRBAS_LIFECYCLE_BINARY=/workspace/phase2/prbas-lifecycle-contract/artifacts/f6c81d01a1fe/prsdd-headless \
  /phase2/scripts/run-cm12-prbas-lifecycle-contract
```

Exit status 1 is the expected red baseline at this held candidate. The script
captures complete stdout, stderr, and exit status for typed live, forced-legacy
live, and forced-legacy reload runs; extracts all displayed scientific rows;
and writes SHA-256 manifests. It must become green through an authorized
ownership correction, not by changing the contract.

## Scope Boundary

No Gate 1 or Gate 2 run occurred. No accepted source, frozen formula routine,
fixture, expectation, tolerance, oracle, production system, `dev`, or `main`
was changed. Existing compiler warnings were captured in the build logs and
were not fixed. Pause before Checkpoint B or any other work.
