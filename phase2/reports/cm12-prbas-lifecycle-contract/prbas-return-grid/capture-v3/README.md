# PRBAS return-boundary diagnostic

## Scope

This is a captured/reference candidate diagnostic at exact candidate
`00effd0d7914da907e83fb386c8181ee54d4e157`. It executes the retained
`live.in` production-adapter deck in separate fresh processes through the typed
candidate and `CM12_FORCE_LEGACY_PRBAS=1`. It does not change a product source,
fixture, expectation, tolerance, or oracle, and it is not Gate 1 or Gate 2.

The archived source is exact commit
`f6c81d01a1fe8b007c247acc2213f821a62dc4f2`. The accepted product correction
under test is `c476de670101c2dbb0c3cdca332b861ddeeb5d31`. `run-context.txt`
binds the fixture, executable, patches, runner, source tree, timezone, and
container OS by identity or SHA-256.

## Architectural correction

The forced path uses archived `PRBAS`, but the accepted pure-source patch has
renamed archived `PRDA` and `PROBS` and routes the calls through the same modern
amplitude-accumulation and DSG seams used by the typed path. Therefore this
experiment does **not** compare two independent `PROBS` implementations. It
tests whether the two PRBAS paths supply the same ordered multipoles and initial
amplitudes to the shared calculation.

Archived `PRBAS` invokes the modern `PROBS` wrapper once while calculating each
row and the retained caller invokes it again while formatting the block. The
forced trace consequently contains 3,068 result rows. All 1,534 second
occurrences are byte-identical to their first occurrence; the audit is retained
in `forced-legacy-final-duplicates.tsv`. `forced-legacy-final.tsv` retains one
canonical result per key for the aligned comparison.

## Result

Structural validation passed:

- Both fresh processes exited zero.
- All 9,576 grid rows align by call, energy, family, branch, orbital `L`, and
  form selector.
- All 61,360 ordered accumulation rows align by call, energy, angle, reaction,
  trace position, family, branch, orbital `L`, and form selector.
- All 1,534 canonical final rows and all 1,533 GO5 rows align structurally.
- Every one of the 12,272 initial-amplitude scalar fields at the first
  contribution of each angle is exact.

The first behavioral divergence is at call 1, energy 145.1 MeV, angle 10
degrees, contribution 1, family 1, branch 1, orbital `L=3`, selector 134. The
typed path supplies
`(-2.0869076251983643E-003,-2.2004306288181397E-007)`; forced legacy supplies
`(-2.0802021026611328E-003,-2.2000224930707191E-007)`. The initial amplitudes
immediately before that contribution are exact, and the amplitudes immediately
after it differ.

Across one angle per call/energy, representing each supplied multipole once,
1,940 of 5,320 ordered multipoles differ in at least one component; 3,380 are
exact in both components. Across the complete angle-expanded trace, 22,647 of
61,360 accumulation rows have at least one differing multipole component.
`accumulation-differences.tsv` retains every differing field rather than only
the first.

The retained 1000 MeV, 90-degree pion-plus website case is exact at this
boundary: all 40 supplied multipoles, all four complex final amplitudes, and DSG
match. Both paths report DSG `2.0978150367736816E+000`, displayed by GO5 as
`0.2098E+01`.

The complete final comparison has 7,533 of 16,874 scalar fields exact. The GO5
comparison has 5,923 of 6,132 scientific value fields exact, retaining the
previously measured 209 displayed-field differences across all 1,533 rows.

## Interpretation

The evidence falsifies summation order as the leading explanation for the first
divergence: the two paths enter the same accumulator with exact initial
amplitudes but different first multipoles. The next diagnostic, if separately
authorized, should compare the transformation from stored `EMR`/`EMI` and
background terms to the post-`SPW`/`SOPW` multipole supplied to `PRDA`, beginning
with the selector-134 call above. No correction is attempted here.

`typed-grid.tsv` and `forced-legacy-grid.tsv` retain all 72 storage slots per
call/energy as context. Their numeric columns are not a behavioral equality
gate: archived grid rows are captured before the later `SPW`/`SOPW`
transformation, whereas typed grid rows contain the request-ready multipole.
The semantically aligned return-boundary values are the `multipole_real` and
`multipole_imag` columns in the two accumulation files.

These are engineering compatibility findings, not scientific endorsement.

## Primary files

- `boundary-summary.tsv`: complete boundary counts and first differences.
- `typed-accumulation.tsv` and `forced-legacy-accumulation.tsv`: all ordered
  post-PRBAS inputs and before/after amplitudes.
- `accumulation-differences.tsv`: every differing accumulation field.
- `typed-final.tsv` and `forced-legacy-final.tsv`: canonical final amplitudes
  and DSG values.
- `per-energy-difference-summary.tsv`: all 133 energy blocks with row and
  difference counts.
- `typed-go5.tsv`, `forced-legacy-go5.tsv`, and `go5-differences.tsv`: all 1,533
  displayed scientific rows and every difference.
- `manifest.sha256`: content hashes for the captured evidence.
