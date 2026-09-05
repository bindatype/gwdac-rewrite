# CM12 PRBAS Lifecycle Contract Hardening

Date: 2026-09-05

Checkpoint A evidence candidate:
`2d893816d19a7310a16fb4235341d0365ca20fa6`

Exact hardening support commit:
`f367a337afed3e0ae869108e99f5ed937a75ae24`

Evidence labels:

- **captured**: new uninstrumented runs and lifecycle comparisons in this
  directory;
- **reference candidate**: exact comparisons against the manifest-bound
  Checkpoint A captures; and
- **inferred**: lifecycle conclusions derived from those comparisons.

This hardening checkpoint changes no PRBAS ownership, formula, scientific
expectation, tolerance, or oracle. It corrects provenance text, makes the
retained external package self-verifying, and closes acceptance-contract blind
spots before an ownership correction is attempted.

## Cold and Primed Contracts

The hardened comparator normalizes legacy `BLANK` and typed empty-title tokens
symmetrically. It also asserts canonical zero/blank typed state on a suppressed
row without inventing reference values where legacy emits `NA`.

| Comparison | Exact rows | First difference | Classification |
| --- | ---: | --- | --- |
| Typed live entry vs cold legacy reload sequence 1 | 25/26 | row 1, `pre_reset_energy` | captured |
| Typed live entry vs primed legacy reload sequence 2 | 0/26 | row 1, `dispatch` | captured |

Cold row 1 suppresses dispatch on both paths. It is not field-exact: typed
`pre_reset_energy` is `8.4995721435546875E+002`, while cold legacy `EPX` is
`0.0000000000000000E+000`. Rows 2-26 reproduce the captured cold dispatched
path after blank-token normalization. A later correction must preserve the
cold behavior and reproduce the primed behavior; primed-only aggregate parity
is not sufficient.

## Uninstrumented Build and Run

The ordinary CM12 seam was rebuilt with `CM12_PRBAS_DIAGNOSTIC_PATCH` unset.
The resulting headless executable has SHA-256
`b67584161c13cfd08cc1c2e64702d5f12ebb662ae1232db761e9d7eade9817f3`,
matching the prior ordinary reproducible artifact. It contains no
`CM12TYPED BEGIN` lifecycle marker.

Fresh typed and forced-legacy `live.in` processes produced scientific tables
exactly equal to the corresponding instrumented Checkpoint A tables:

- typed GO5: exact;
- forced-legacy GO5: exact;
- typed GO3: exact; and
- forced-legacy GO3: exact.

The ordinary executable therefore preserves the same red baseline rather than
masking it: typed versus forced legacy is 0/1,533 complete GO5 rows, and the
GO3 observations are `0.2036E+01` versus `0.2098E+01`.

## Durable Retention

The external 34-file package remains at
`retained-diagnostics/prbas-two-pass-lifecycle-81b0d7c`. Its original
absolute-path manifest is unchanged. New sibling `manifest-relative.sha256`
has SHA-256
`4996fa758d32d46f124645bd453691e8f394475cc05620869137fb0349cbba03`
and verifies all 34 retained payload files in place.

## Integrity and Reproduction

The build manifest SHA-256 is
`b50a6c86a925a819d03896f9110c30f85ad3d12e613fda43bb5f03085aa9600a`.
The capture manifest SHA-256 is
`02b8695d264bcdcf73009c9ced0b4a5659bb2caa4ed4607213bc2bc713eb567d`.

Build the ordinary executable with:

```sh
env -u CM12_PRBAS_DIAGNOSTIC_PATCH \
  PHASE1_STATE_ROOT=/workspace/phase2/prbas-lifecycle-hardening \
  PHASE1_REPORT_ROOT=/phase2/reports/cm12-prbas-lifecycle-contract/hardening/build \
  CM12_SEAM_ROOT=/phase2/kernel \
  /phase1/scripts/build-prsdd
```

Capture into a new empty report root with:

```sh
PRBAS_HARDENING_REPORT_ROOT=/path/to/empty/capture \
PRBAS_UNPATCHED_BINARY=/workspace/phase2/prbas-lifecycle-hardening/artifacts/f6c81d01a1fe/prsdd-headless \
PRBAS_PRODUCT_COMMIT=f367a337afed3e0ae869108e99f5ed937a75ae24 \
  /phase2/scripts/run-cm12-prbas-lifecycle-hardening
```

The runner verifies the prior capture and lifecycle fixture manifests before
execution, requires an uninstrumented binary, captures complete stdout,
stderr, and exit status, and fails if any uninstrumented scientific table
differs from its instrumented reference-candidate table.

No Gate 1 or Gate 2 run, ownership/formula correction, integration, push,
branch movement, production access, fixture expectation change, tolerance
change, or oracle change occurred.
