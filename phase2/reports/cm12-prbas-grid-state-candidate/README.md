# CM12 PRBAS typed grid-state candidate

Evidence label: **reference candidate** with captured diagnostic comparisons.
This package does not accept or publish the PRBAS replacement and does not
establish physics correctness.

## Scope

The candidate corrects only the typed orchestration lifetime identified by the
`200 -> 300 MeV` pion-plus DSG diagnostic. It introduces explicit typed state
for one PRBAS energy grid, carries that state between energy preparations, and
checks that the state remains bound to the same solution hash and reaction.

Frozen formula routines, fixtures, expectations, oracles, and accepted source
were not changed. `cm12_evaluate_request` remains pure. No COMMON block, SAVE
state, filesystem state, or CGI input was added.

Frozen PRBAS prepares non-CM12 multipoles once per energy and reuses them across
angles. The candidate follows that lifecycle: Born/OPEC/non-CM12 multipoles are
prepared once per energy, while only angle-dependent initial amplitudes are
recalculated for later angles.

## Complete before/after comparison

Both paths contain 52 rows: 26 at 200 MeV and 26 at 300 MeV.

- Before correction: 49/52 rows exact. All three differences are the 300 MeV
  startup sequence: one suppressed dispatch, one dispatch-title transition,
  and one previous-title transition. The remaining 23 rows at 300 MeV are
  exact.
- After correction: 52/52 rows exact across row coordinates, dispatch state,
  title state, input/effective energy, dither, and complex hadronic value.
- The actual two-point command deck produces two displayed records exact to
  forced legacy: 200 MeV `0.8671E+01` and 300 MeV `0.2246E+02`.
- The retained one-energy dense-angle fixture produces all 61 displayed records
  byte-identical to forced legacy, protecting energy-scoped multipole reuse.

The full raw stdout files are not expected to match: the forced-legacy run
contains diagnostic trace lines, and the two executions crossed a displayed
run-date boundary. The extracted scientific records are exact.

## Focused build

The pinned Ubuntu 24.04/x86_64 build completed and passed the existing request,
dispatch, and 40-form contribution probes. A first isolated-report attempt
stopped before its dispatch comparison because the fresh report root lacked
the retained legacy trace inputs. Supplying those unchanged inputs and rerunning
the already-built candidate passed; no source or expectation was changed in
response to that harness setup error.

Candidate source SHA-256 values:

- `cm12_background_seam.f90`: `2f6dc9e38bd581bb909e4064d6c51cb1903fb8e3b1d36a3ef9414834157eaaf7`
- `cm12_non_cm12_seam.f90`: `b865085c6164452eee77d907c732c287f3c0e39507f41d04ad6d505f94da5e51`
- `cm12_request_kernel.f90`: `ee53672a3ce75af1871c458cdba2a5058a3bdb1436be26e2f7599f29a154e6f3`
- `cm12_prbas_seam.f90`: `f1c7fefe23dff9bf91b1e72a9ea53f9899fee3bd2ac21c6ddf9131ec66071a61`
- Diagnostic probe: `bfeaf76d92b00e75d72c157a64500e7420c5989664901a3d8d9d8465536dd7f3`
- Headless executable: `b67584161c13cfd08cc1c2e64702d5f12ebb662ae1232db761e9d7eade9817f3`

## Gate

This is a bounded candidate pass, not acceptance. No full corpus run, commit,
integration, push, production access, formula port, frontend work, `pdesd`, or
Phase 3 work was performed. Pause before the separately gated full corpus.
