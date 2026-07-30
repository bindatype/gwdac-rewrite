# Pion photoproduction choice-1 amplitude contract, version 1

Status: behavioral contract frozen; convention and physics review pending  
Canonical source: `bindatype/arndt64@f6c81d01a1fe8b007c247acc2213f821a62dc4f2`  
Deployment evidence: `bindatype/gwdac@aacdf97`

## Scope

This contract covers the non-plotting `AMPL` choice-1 output from `prsdd` for
CM12 pion photoproduction. The legacy program describes this representation as
“VPI&SU helicity amplitudes (from Walker)” and prints four complex values
labeled `A1` through `A4`.

Choices 2 and 3, negative choices that request `10**-3/mu` units, multipole
tables, plots, and other reaction families are excluded.

## Typed request

The structural request is defined by `amplitude-request.schema.json`.

| Field | Contract |
| --- | --- |
| `solution` | `CM12` only |
| `reaction` | `pi0p`, `pi+n`, `pi-p`, or `pi0n` |
| `independent_variable` | center-of-mass angle/cosine, photon lab energy, or total center-of-mass energy |
| `grid` | finite ordered range, positive step, at most 70 generated values |
| `fixed` | energy for angle grids; center-of-mass angle for energy grids |
| `representation` | `legacy_choice_1_walker_vpi_su` |
| rendering | excluded |

The same threshold, energy-range, finite-number, angle, cosine, and grid
validation policy as `pion-photoproduction-dsg-v1` applies. The typed API must
reject invalid enum values rather than reproduce terminal re-prompts.

The legacy program silently clamps amplitude choices below 1 to choice 1 and
above 3 to choice 3. The versioned API exposes no integer choice: callers must
request the named choice-1 representation.

## Typed result

The structural result is defined by `amplitude-result.schema.json`. Every
record contains the independent value and four complex amplitudes. The fields
remain `a1` through `a4` because those are the surviving output labels. Renaming
them to a modern helicity convention requires domain approval.

The source and output explicitly identify the amplitude unit as `mFm`
(milli-fermi). Energy is MeV and angles are degrees. The exact meaning,
normalization, signs, and ordering of the Walker/VPI-SU convention remain
pending domain review.

The legacy table prints independent values to one decimal place and every real
and imaginary component to two decimal places. Regression tests require exact
equality of these parsed fields. Hidden floating-point equality is not claimed.

## Computational path

The calculation path through solution and amplitude construction is shared with
the existing `DSG` contract:

1. `SAIDOPEN(4)` opens the pion-photoproduction inputs.
2. `PRSOL` loads CM12 parameters and form selectors.
3. `PRBAS` evaluates kinematics and constructs four complex amplitudes in
   shared arrays `HR` and `HI`.
4. `PRDLT` dispatches CM12 forms 101-199 through `cmmwp`.
5. `cmmwp` and `ysKCM.f90` evaluate the Chew-Mandelstam partial-wave input.
6. The `AMPL` choice-1 branch copies `HR` and `HI` directly to `HRX` and
   `HIX` with conversion factor 1.0 and prints `A1` through `A4`.

Canonical source anchors:

- representation label: `said/prsd.f:18`;
- `AMPL` branch: `said/prsd.f:470`;
- default and clamped choice: `said/prsd.f:477-488`;
- direct choice-1 copy: `said/prsd.f:514`;
- text precision: `said/prsd.f:546`;
- source link to `DSG`: `said/prsd.f:1501-1551`.

The fixed-form source remains frozen. These locations are provenance, not a
recommendation to preserve the COMMON-block architecture.

## Dataset contract

This path uses the same canonical CM12 solution and KCM package as the `DSG`
contract. The reproducible oracle retains the 64 checksummed files in
`prsdd-opened-data-manifest.tsv`. The amplitude decks do not request
experimental-data presentation, but initialization still uses the legacy
`SAIDOPEN(4)` file-assignment boundary.

The immutable-loader extraction now proves the exact structure of the 42 KCM
files: 14 S/P/D/F waves, each with `cmm`, `cmf`, and `kcm` records on a
275-point 1080-2450 MeV Wcm grid. The active scalar evaluator consumes the 14
`cmm` matrices. The `cmf` and `kcm` tables are loaded and checksummed for
package fidelity but occur only in disabled diagnostic code in the surviving
`ysKCM` source.

The remaining 18 `sdat` and four working-directory files still have
open-level rather than read-level provenance. The rewrite must return code,
solution, and dataset versions with every result.

## Oracle and corpus

The corpus contains 13 requests and 150 typed records:

- seven normal requests covering all four pion channels, fixed `Elab`, fixed
  `Wcm`, and independent `Elab` and `Wcm` sweeps;
- three boundary requests covering cosine clamping, the maximum 70-point grid,
  and a single point;
- two malformed selections followed by valid legacy recovery;
- one amplitude-choice coercion request.

The modern headless build, checked-in arndt64 executable, and checked-in GWDAC
executable produce byte-identical tables for all records at displayed
precision. The modern `Wcm` sweep additionally reports IEEE underflow and
denormal flags while returning finite values identical to both historical
executables.

The immutable-loader compatibility build adds a fourth implementation path.
Its 150 records are byte-identical to the modern reference, and its scalar
evaluator matches legacy `ysKCM` exactly in 42 unrounded single-precision
evaluations.

The choice-zero and recovery fixtures are exactly equal to the valid baseline.
They document compatibility behavior; the typed API should reject those inputs.

## Cross-contract invariant

For the nine shared `pi+n`, 1000 MeV angle points, reconstructing `DSG` from
the rounded choice-1 components using the canonical `PROBS` relation agrees
with the `DSG` oracle within the bound implied by text rounding:

`DSG = (q_cm / k_cm) * sum(|A_i|^2) / 200`

This confirms that choice 1 exposes the amplitude values consumed by the frozen
`DSG` path at available display precision. It does not independently validate
the formula or normalization.

## Review boundary

Stakeholders must approve:

- whether “VPI&SU helicity amplitudes (from Walker)” is the correct public
  terminology;
- the meanings and ordering of `A1` through `A4`;
- phase, sign, reaction-channel, and frame conventions;
- the `mFm` normalization and any preferred modern unit;
- the relation to `DSG` and tolerances beyond two-decimal text output;
- whether the finite `Wcm` underflow diagnostic is harmless numerical debt.
