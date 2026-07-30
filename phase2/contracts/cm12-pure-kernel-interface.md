# CM12 pure-kernel interface

Status: solution/dataset, scalar multipole, background, amplitude, and DSG
reference seams implemented; request orchestration pending, 2026-07-29  
Behavioral authorities:
`pion-photoproduction-amplitude-v1` and `pion-photoproduction-dsg-v1`

## Goal

Replace the retained scalar CM12 pion-photoproduction calculation without
carrying forward `/PRSC/`, COMMON blocks, packed A4 text, fixed 70/99-element
work arrays, file-unit conventions, or invocation-order-dependent `SAVE`
state.

This interface does not choose the implementation language.

## Implemented reference seam

The modern Fortran reference now implements:

- `CM12Dataset` with private components;
- explicit loading and shape/grid validation for 42 KCM files;
- `CM12Solution` with private components, native SHA-256 verification, direct
  `CM12` record parsing, decoded metadata, fixed coefficient tables, and
  immutable background constants;
- a scalar `cm12_evaluate_multipole` operation with `intent(in)` dataset
  ownership and no file I/O, COMMON block, or initialization cache;
- explicit form number, 25-parameter slice, multipole identifiers, Wcm, and
  injected Born multipole inputs;
- an explicit background seam returning full Born multipoles, OPEC
  multipoles, and four initial HOPEC amplitudes;
- pure `cm12_accumulate_multipole` four-amplitude accumulation; and
- pure `cm12_evaluate_dsg` calculation with typed domain errors.

The background seam invokes the frozen legacy formula routines internally
while supplying their configuration explicitly. It is an isolation boundary,
not yet a native rewrite of those formulas. The pure scalar, amplitude, and
DSG operations do not call legacy code.

The seam deliberately uses `REAL*4`/single-precision arithmetic to compare
operation-for-operation with the oracle. This is a compatibility reference,
not a reversal of the target interface's provisional
`float64`/`complex128` policy.

## Typed boundary

```text
enum PionChannel {
    PI0_P,       # gamma p -> pi0 p
    PI_PLUS_N,   # gamma p -> pi+ n
    PI_MINUS_P,  # gamma n -> pi- p
    PI0_N        # gamma n -> pi0 n
}

struct KinematicRequest {
    channel: PionChannel
    photon_lab_energy_mev: float64
    angle_cm_deg: float64
}

struct Kinematics {
    w_cm_mev: float64
    photon_cm_momentum_mev: float64
    meson_cm_momentum_mev: float64
    final_meson_energy_mev: float64
    threshold_lab_energy_mev: float64
}

struct CM12Solution {
    id: string
    provenance_sha256: string
    form_selector: int[6][2][6]
    parameters: float64[25][6][2][6]
    isospin_coefficients: float64[6][2]
    helicity_coefficients: float64[4][4][6]
    max_partial_wave: int
    background: ReviewedBackgroundConstants
}

struct CM12Dataset {
    provenance_manifest: DatasetManifest
    kcm_grids: immutable typed arrays
    hadronic_solution: immutable typed arrays
}

struct Multipole {
    family: int
    j_branch: int
    orbital_l: int
    value_mfm: complex128
}

struct AmplitudeResult {
    kinematics: Kinematics
    walker_vpi_su_mfm: complex128[4]
}

struct DsgResult {
    kinematics: Kinematics
    dsg: float64
    unit: "microbarn/sr"  # pending stakeholder confirmation
}
```

The array shapes mirror the loaded CM12 solution only at the loader boundary.
The public evaluator is scalar and has no legacy grid-size limit.

## Pure operations

```text
load_cm12_solution(path, expected_hash) -> CM12Solution
load_cm12_dataset(manifest) -> CM12Dataset

calculate_kinematics(request) -> Kinematics

evaluate_multipole(
    solution,
    dataset,
    kinematics,
    family,
    j_branch,
    orbital_l
) -> Multipole

evaluate_choice1_amplitudes(
    solution,
    dataset,
    request
) -> AmplitudeResult

evaluate_dsg(
    kinematics,
    walker_vpi_su_mfm
) -> DsgResult
```

`evaluate_*` functions must perform no file I/O, mutate no solution or
dataset state, depend on no prior call, and return either a finite typed result
or a typed validation/domain error.

Batch and grid APIs are adapters over scalar evaluation:

```text
evaluate_amplitude_batch(solution, dataset, requests[]) -> AmplitudeResult[]
evaluate_dsg_batch(solution, dataset, requests[]) -> DsgResult[]
```

They must not reintroduce the legacy 70-point energy grid, 99-point observable
grid, or shared flattened index.

## `/PRSC/` ownership mapping

| Target owner | Legacy fields | Treatment |
| --- | --- | --- |
| Request | `IR`, `IT`, `E`, `A` | Replace integer selectors and grids with one validated scalar request |
| Solution | `NF`, `PEM`, `CIS`, `CH`, `NNL`, decoded `TITLE` | Immutable, provenance-bearing object |
| Kinematics result | `ZKCM`, `QCM`, `EPI`, `ETHR` | Return explicit named values |
| Scoped policy | `IR0`, `NMTTL` | Eliminate the reaction-family offset; derive pion thresholds from the typed channel |
| Evaluator locals | `MM`, `JJ`, `LL`, `BAS` | Local multipole indices and angular basis |
| Multipole result | `DER`, `DEI` | One complex value; do not expose mutable scalars |
| Amplitude result | `HRX`, `HIX` | Four complex values in the contracted order |
| Observable result | `OBSPRD` | Return the named scalar in `DsgResult` |
| Batch adapter | `NE`, `NA`, `IE`, `IA`, `II`, `NINC`, `HR`, `HI`, `OBS` | Local iteration and result arrays |
| Diagnostic batch data | `EMR`, `EMI` | Do not retain by default; collect returned multipoles only when requested |
| Uncertainty component | `NNBT`, `NPRM`, `P0`, `DDP`, `YZ`, `ERMTX`, `NBT`, `DOBS`, `DPZ` | Deferred, separate interface and fixtures |
| Remove | `MTRN`, `NN`, `DTTL`, `MTTL`, `ITTL`, `TTLI`, `DUM`, `OBSX`, `ERR`, `TEX`, `XEX`, `HDAT`, `THTX`, `NINCMX`, `NITTL` | Transcript, plotting, experiment, scratch, or legacy capacity state |

These rows account for all 60 `/PRSC/` members.

## Adjacent-state ownership

- `/GOMEGA/` values used by `HOPEC`/`PROPEC` are loaded as immutable
  background constants. The compatibility bridge maps them into the legacy
  formula ABI for one call; the public boundary has no COMMON state. Their
  defaults and units require physics review.
- `/solnform/` is eliminated from the scalar evaluator; its form number is an
  explicit argument loaded from `CM12Solution`.
- `/psol/`, `/tgrid/`, and `/cmmgrid/` have been replaced at this seam by
  `CM12Dataset`.
- `ysKCM` initialization and file reads now occur only in
  `load_cm12_dataset`; the seam binary does not link `ysKCM` or `GETTM`.
- Cached prior angle/energy values are removed unless a pure, immutable
  precomputation proves necessary.

## Validation policy

The typed API must reject, rather than reproduce:

- Unknown reaction or observable selectors.
- NaN or infinite request values.
- Angles outside 0-180 degrees instead of silently clamping cosine values.
- Non-positive or below-threshold domains instead of returning legacy
  zero/NaN records.
- Missing, unexpected, or hash-mismatched solution/dataset files.
- Unsupported amplitude choices; this kernel implements choice 1 only.

Floating-point precision is not inferred from the COMMON ABI. Start with
`float64`/`complex128`, compare unrounded values where available, and preserve
the existing displayed-precision oracle as the minimum acceptance rule.

## Implementation status

1. **Complete:** manifest and loader validation for the 42-file KCM dataset.
2. **Complete:** scalar `cmmwp`/`ysKCM` evaluation behind
   `cm12_evaluate_multipole`.
3. **Complete:** 42 exact direct scalar comparisons spanning every loaded
   partial wave and three Wcm values.
4. **Complete through compatibility adapter:** all amplitude and DSG corpus
   records match the frozen reference.
5. **Complete:** immutable SHA-256-checked CM12 solution loader and decoded
   metadata.
6. **Complete as an explicit seam:** immutable background inputs and explicit
   Born/OPEC/HOPEC outputs, including nonzero-Born and A-B-A tests.
7. **Complete:** pure `PRDA` choice-1 amplitude accumulation with six exact
   unrounded split-legacy comparisons.
8. **Complete:** pure DSG calculation with formula, threshold-rejection, and
   invalid-domain tests.
9. **Pending:** one pure request-to-result operation replacing legacy
   `PRBAS` grid/control orchestration.
10. **Pending:** decide whether to port the background formulas in the
    reference language before or during the target-language spike.

Physics approval is required for conventions, constants, dataset meaning,
threshold policy, and units. Structural extraction and oracle parity can
proceed before that approval; formula changes cannot.

This milestone is complete. Execution is paused until the user sends the exact
command `RESUME`.
