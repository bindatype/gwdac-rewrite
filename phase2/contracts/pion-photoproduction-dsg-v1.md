# Pion photoproduction `DSG` contract, version 1

Status: behavioral contract frozen; physics review pending  
Canonical source: `bindatype/arndt64@f6c81d01a1fe8b007c247acc2213f821a62dc4f2`  
Deployment evidence: `bindatype/gwdac@aacdf97`

## Scope

This contract covers one retained SAID workflow: a user requests a CM12 pion
photoproduction differential cross-section prediction over an angle or energy
grid. It intentionally excludes plotting, experimental-data presentation,
other SAID reaction families, and approval of the underlying physics.

The identified user is a SAID analyst or scientific consumer who needs
versioned pion photoproduction predictions. A named stakeholder is not required
to preserve and test the behavior, but stakeholder approval is required before
the replacement is described as physically validated.

## Typed request

The structural request is defined by `request.schema.json`.

| Field | Contract |
| --- | --- |
| `solution` | `CM12` only |
| `reaction` | `pi0p`, `pi+n`, `pi-p`, or `pi0n` |
| `independent_variable` | `acm_deg`, `cos_acm`, `photon_lab_energy_mev`, or `total_cm_energy_mev` |
| `grid` | finite minimum, positive step, finite maximum, no more than 70 generated values |
| `fixed` | energy for an angle grid; center-of-mass angle for an energy grid |
| `observable` | `DSG` only in version 1 |
| rendering | excluded |

Legacy reaction numbers map to `1=pi0p`, `2=pi+n`, `3=pi-p`, and `4=pi0n`.
Legacy independent-variable tokens map to `A`, `C`, `E`, and `W`.

The replacement must validate before allocation or calculation. It must reject
non-finite numbers, non-positive steps, reversed grids, grids over 70 points,
cosines outside `[-1, 1]`, angles outside `[0, 180]` degrees, and energies
outside the retained CM12 domain. It must not silently clamp or re-prompt.

The program prints channel thresholds of 144.76, 151.65, 148.43, and
144.74 MeV in reaction order. The historical web form describes CM12 as valid
from 155 to 2700 MeV photon laboratory energy. These limits are evidence for
validation; stakeholders still need to approve their scientific interpretation.

## Typed result

The structural result is defined by `result.schema.json`. Each record contains:

- independent-variable name and value;
- center-of-mass differential cross section;
- the legacy propagated uncertainty;
- lab angle and lab differential cross section when the independent variable
  is center-of-mass angle.

`NaN` and infinity are not valid typed results. A request that would produce
them must return a validation or calculation error.

The legacy table prints independent values to three decimal places, the
observable and uncertainty with four-digit exponential precision, and lab angle
to two decimal places. Version 1 regression tests require exact equality of
these parsed fields. Hidden floating-point equality is not claimed.

## Units

The source explicitly labels:

- `Acm` and `Alab` as degrees;
- `Elab` and `Wcm` as MeV;
- helicity amplitudes `HRX` and `HIX` as milli-fermis.

`PROBS` calculates `DSG` as the final-state to incident momentum ratio times
the sum of four squared helicity amplitudes divided by 200. Dimensional
conversion and standard photoproduction convention indicate that the displayed
cross section is microbarns per steradian, but the surviving interface does not
label the unit. Treat `microbarn_per_sr` as **inferred, pending domain review**.

The CM12 corpus prints zero legacy uncertainty. This records behavior; it does
not establish that the scientific uncertainty is zero.

## Computational path

| Stage | Canonical source | Responsibility |
| --- | --- | --- |
| process driver | `said/prsd.f:1` | owns the interactive state machine and `/PRSC/` shared state |
| file assignment | `said/saidopen.for:1` | opens solution, data, KCM-support, and generated files |
| solution selection | `said/prsd.f:1795`, `PRSOL` | loads CM12 parameters and form selectors |
| kinematic setup | `said/prsd.f:1349`, `PRBAS` | computes thresholds, momenta, multipoles, and four helicity amplitudes |
| CM12 dispatch | `said/prsd.f:2348`, `PRDLT` | routes form values 101-199 into the CM12 bridge |
| CM12 bridge | `said/cmmwp.f:1`, `cmmwp` | converts photon lab energy to `Wcm` and calls `ys` for real and imaginary multipoles |
| K-matrix evaluation | `said/ysKCM.f90` | reads partial-wave KCM tables and evaluates the CM solution |
| observable | `said/prsd.f:1492`, `PROBS` | calculates `DSG` from four complex helicity amplitudes |
| result/uncertainty | `said/prsd.f:5006`, `PRODO` | populates observable and propagated-error arrays |
| lab transform | `said/prsd.f:1046`, `GTM1M2`, plus driver lines 585-619 | converts angle and differential cross section to lab coordinates |

The principal shared-state boundary is COMMON block `/PRSC/`. It combines
request state, solution parameters, kinematics, amplitudes, observables,
uncertainties, titles, and work arrays. The rewrite must split this into
immutable request, dataset, solution, kinematics, amplitude, and result types.

## Dataset contract

The frozen trace opened 64 stable inputs: 42 KCM partial-wave tables, 18 files
under `sdat/`, and four working-directory inputs. Their byte sizes and SHA-256
values are in `prsdd-opened-data-manifest.tsv`.

The immutable-loader extraction has refined the KCM part of that boundary:

- all 42 KCM files have validated record widths and the same 275-point
  1080-2450 MeV Wcm grid;
- the active scalar calculation reads the 14 `cmm` matrices;
- the 14 `cmf` and 14 `kcm` tables survive only in disabled diagnostic code
  but remain checksummed package members.

For the other 22 files, an open trace still proves only that the process
opened a file, not that every byte affected this calculation. Therefore:

- all 64 files remain in the reproducible oracle package;
- the rewrite may reduce the runtime dataset only after read-level provenance
  or parser tests prove which records the CM12 path consumes;
- generated `SAID.*` and `fort.*` files are not scientific inputs;
- dataset identity must be returned with every replacement result.

## Oracle and corpus

The corpus contains 11 requests and 138 typed result records:

- six normal requests covering all four reaction channels, fixed `Elab`, fixed
  `Wcm`, and an energy sweep;
- two boundary requests;
- two malformed enum/selection requests followed by valid legacy recovery;
- one scientifically invalid below-threshold request.

The modern headless build, checked-in arndt64 executable, and checked-in GWDAC
executable produce byte-identical typed tables for all cases at displayed
precision. The comparison registry is
`phase2/reports/prsdd-corpus-comparison.tsv`.

The immutable-loader compatibility build also produces byte-identical tables
for all 138 records. Its underlying scalar evaluator has exact unrounded
single-precision parity with legacy `ysKCM` in 42 direct cases.

The corpus records three behaviors that the replacement should reject rather
than reproduce:

- a cosine grid outside `[-1, 1]` is silently clamped;
- an oversized grid is written into fixed arrays before rejection, corrupting
  state and producing `NaN` after the replacement step;
- a below-threshold request produces zero center-of-mass `DSG`, `NaN` lab
  fields, and floating-point exceptions on the modern runtime.

## Review boundary

The oracle answers “does the replacement match retained SAID behavior?” It does
not answer “is the physics correct?” Stakeholders must separately approve:

- the CM12 validity range and per-channel threshold policy;
- the `DSG` formula, normalization, frame convention, and inferred unit;
- the lab-frame Jacobian and angle transform;
- the meaning of the uncertainty field;
- numerical tolerances beyond the displayed legacy precision.
