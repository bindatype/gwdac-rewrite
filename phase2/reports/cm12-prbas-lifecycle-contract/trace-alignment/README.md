# CM12 PRBAS Trace-Alignment Amendment

Date: 2026-09-06

Signed Checkpoint A hardening candidate:
`76c61ee612b3d36d399a155292702878a7b985f2`

Exact amendment support commit:
`b06771c47e05bdaa65a7195cf0ff24f787d93696`

Evidence labels:

- **captured**: the new typed-cold and forced-legacy reload runs in this
  directory;
- **reference candidate**: exact comparisons against the manifest-bound
  Checkpoint A captures and between corresponding typed and legacy fields; and
- **inferred**: the trace-alignment conclusion derived from those comparisons.

This amendment changes diagnostic-build-only instrumentation and adds versioned
parsers, a comparator, and a runner. It changes no ordinary production build,
PRBAS ownership, formula, fixture, expected scientific value, tolerance, or
oracle.

## Result

The earlier `25/26` cold ceiling was a trace-schema defect. Legacy `EPX` had
been captured after the `BCOFFM` reset, while typed `pre_reset_energy` was
captured before the equivalent transition. The aligned trace now emits both
values explicitly on both paths.

| Comparison | Exact rows | First difference | Classification |
| --- | ---: | --- | --- |
| Typed cold vs forced-legacy cold | 26/26 | none | PASS |
| Typed cold vs forced-legacy primed | 0/26 | row 1, `post_reset_energy` | expected red baseline |

On cold row 1, both paths now record the same transition:

- pre-reset energy: `8.4995721435546875E+002` MeV;
- post-reset energy: `0.0000000000000000E+000` MeV; and
- dispatch: suppressed.

The primed comparison remains deliberately red. Forced legacy retains the
post-reset energy and dispatches row 1; the current typed path resets it to zero
and suppresses dispatch. The explicit post-reset field therefore precedes
`dispatch` as the first classified difference. Every one of the 26 rows is
retained in both comparison tables.

## Scientific Display Check

The instrumentation did not change the bounded displayed GO3 results relative
to the prior manifest-bound captures:

| Path | Displayed pion-plus DSG |
| --- | ---: |
| Typed cold | `0.2036E+01` |
| Forced-legacy cold | `0.2036E+01` |
| Forced-legacy primed | `0.2098E+01` |

This amendment makes the cold acceptance contract capable of reaching 26/26.
It does not make the held PRBAS ownership candidate acceptable; the primed
contract still exposes that unresolved lifecycle difference.

## Build and Integrity

The diagnostic executable was built from archived source
`f6c81d01a1fe8b007c247acc2213f821a62dc4f2` on Ubuntu 24.04 with modern
`gfortran`. Its SHA-256 is
`2962c82f0eed5fc16dbc22975b9a8d7f7a614285ac98dd40c121558d1310a484`.

The build manifest SHA-256 is
`0e4648ab42de3b0da3317342f22145cf1a21f2e0fe1f546c2ffa29473c3a09cb`.
The 17-entry capture manifest SHA-256 is
`89ccd2a309102c1b4141e9e19e54139f7d09853d40788d5c4ec1bc3a545347de`.

The runner verified the prior Checkpoint A capture, full package, hardening
capture, and hardening package manifests before execution. Their retained
manifest hashes remain respectively `cf39c9f1...`, `29e13f20...`,
`02b8695d...`, and `72107850...`; no earlier artifact was rewritten.

## Reproduction

Build the aligned diagnostic executable with:

```sh
PHASE1_STATE_ROOT=/workspace/phase2/prbas-trace-alignment-7a218bf \
PHASE1_REPORT_ROOT=/phase2/reports/cm12-prbas-lifecycle-contract/trace-alignment/build \
CM12_SEAM_ROOT=/phase2/kernel \
CM12_PRBAS_DIAGNOSTIC_PATCH=/phase2/kernel/cm12_prbas_lifecycle_trace.patch \
  /phase1/scripts/build-prsdd
```

Capture into a new empty report root with:

```sh
PRBAS_TRACE_ALIGNMENT_STATE_ROOT=/workspace/phase2/prbas-trace-alignment-7a218bf \
PRBAS_TRACE_ALIGNMENT_REPORT_ROOT=/path/to/empty/capture \
PRBAS_TRACE_ALIGNMENT_BINARY=/workspace/phase2/prbas-trace-alignment-7a218bf/artifacts/f6c81d01a1fe/prsdd-headless \
PRBAS_TRACE_ALIGNMENT_SUPPORT_COMMIT=b06771c47e05bdaa65a7195cf0ff24f787d93696 \
  /phase2/scripts/run-cm12-prbas-trace-alignment-amendment
```

The runner captures complete stdout, stderr, exit status, typed trace rows, both
legacy sequences, both complete comparisons, displayed GO3 rows, counts, and
hashes. It requires cold 26/26 parity and the retained primed 0/26 red baseline.

No Gate 1 or Gate 2 run, ownership or formula correction, integration, push,
production access, branch movement, fixture or expectation change, tolerance
change, or oracle change occurred.
