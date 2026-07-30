# CM12 hadronic-input divergence diagnostic

Date: 2026-07-30

Evidence labels:

- **captured** for the forced-legacy and candidate probe values;
- **reference** for the frozen-source mechanism that produces the first
  divergence;
- **inferred** only where explicitly stated.

Physics/domain review remains pending. This diagnostic establishes
implementation correspondence only.

## Scope

- CM12 pion-plus
- photon laboratory energy: 1000 MeV
- center-of-mass angle: 90 degrees
- outputs parent commit: `689658e`
- WIP candidate commit: `9cb0009`
- frozen arndt64 source commit:
  `f6c81d01a1fe8b007c247acc2213f821a62dc4f2`
- solution SHA-256:
  `dbcaae30bbf44aca6e5482fc2b10b81cb6e1033cf41061bc089d5f6a85576522`

No formula or request-orchestration change was attempted.

## Result

The first divergence occurs on the first applicable non-1xx form:

```text
family=1
branch=1
legacy_l=5
rotation_form=2
base_form=5
state_index=3
form_selector=25
legacy_epx=0.0000000000000000E+000
candidate_epx=8.4995721435546875E+002
legacy_epxx=0.0000000000000000E+000
candidate_epxx=8.4995721435546875E+002
```

The identity fields preceding `EPX` are exact. Across all 18 applicable rows:

- rotation form: 18/18 exact
- base form: 18/18 exact
- state index: 18/18 exact
- form selector: 18/18 exact
- `EPX`: 17/18 exact
- `EPXX`: 17/18 exact
- `QCM`: 18/18 exact
- `ZKCM`: 18/18 exact
- `TER`: 0/18 exact
- `TEI`: 0/18 exact

The later `TER` and `TEI` differences were captured but not investigated
because the authorized stop condition was the first differing input.

## Mechanism

The frozen `PRDLT` initializes saved `BCOFFM` to `-1`. Before its hadronic
call, it executes the equivalent of:

```fortran
IF(BCOFF.NE.BCOFFM) EPX=0.0
BCOFFM=BCOFF
```

For this request, the first applicable form therefore reaches `PNPWI` with
`EPX=EPXX=0`. Subsequent forms use `849.95721435546875`.

The WIP candidate instead calls `PNSM05` once with
`kinematics%final_meson_energy_mev` and uses that value for every form. This
explains the first captured divergence. It does not yet prove that the
one-time reset explains the final DSG mismatch or the later hadronic
differences.

## Artifacts

- `legacy-target.stdout.gz`: raw instrumented forced-legacy target transcript.
- `legacy-hadronic-inputs.tsv`: normalized 18-row legacy input table.
- `candidate-hadronic-inputs.tsv`: candidate-side diagnostic probe output.
- `hadronic-input-comparison.tsv`: field-by-field exact comparison.
- `summary.txt`: counts and first divergence.
- `manifest.txt`: source, binary, and evidence hashes.
- `../../kernel/cm12_hadronic_input_probe.f90`: diagnostic-only candidate
  probe.

## Stop

The requested first divergence has been identified. No fix, orchestration
change, Phase 3 work, or formula-porting decision follows from this report
without a new explicit authorization.
