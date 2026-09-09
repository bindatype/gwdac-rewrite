# PRBAS selector-13x post-correction validation

## Scope

This captured/reference-candidate diagnostic validates the authorized typed
dual-energy Born correction across the complete retained `live.in` deck. The
exact candidate is `01d58a42e63356b16d671aa7be4faeecb7e0d55f`. Product
content is exact parent commit
`6f1f2b3e7123fcfa8d60d01401a68e374a34ff44`; the candidate head adds only the
one-line disposable-instrumentation correction needed for the trace evaluator
to consume the same production Born field as the product evaluator.

The archived source is exact commit
`f6c81d01a1fe8b007c247acc2213f821a62dc4f2`. Typed and forced-legacy
executions are reference candidates, not independent oracles. This run changes
no fixture, expectation, tolerance, or oracle and is neither Gate 1 nor Gate 2.

## Correction contract

The typed prepared background now retains two explicit Born grids. The
original-request-energy grid remains the input to non-CM12 background assembly.
The production grid is evaluated at the photon energy reconstructed from
single-precision `Wcm`, preserving the frozen `CMMWP` to `ysKCM` arithmetic
contract for selectors 134 and 135. Original-energy OPEC subtraction is
unchanged. Selector 124 remains the no-Born control.

No frozen formula routine or frozen Fortran comment was modified. The formula
porting decision remains outside this candidate.

## Result

Structural and exact validation both passed. Both fresh processes exited zero.
Typed supply, forced CMMWP supply, and archived PRBAS grid traces each contain
4,522 records: 133 selector-124 records, 3,990 selector-134 records, and 399
selector-135 records. Archived reaction-family filtering returns 2,926 records:
133, 2,527, and 266 respectively. There are zero unmatched or duplicate keys.

Every request energy, `Wcm`, reconstructed energy, original-energy OPEC value,
raw complex multipole, and applicable returned complex multipole is exact
between the typed and forced paths. Every selector-134 and selector-135 Born
argument is exact. Selector 124 remains exact without a Born argument.

Both paths retain all 1,533 GO5 scientific rows. `go5-differences.tsv` contains
only its header, and `typed-go5.tsv` and `forced-legacy-go5.tsv` share SHA-256
`23aeb3176c0dc449cc09b4964d455287a43575a49ecae5a9caba7d09539a662d`.
This closes the prior 209 displayed-field differences for this complete deck.

Request energy intentionally differs from the reconstructed energy on 122 of
133 calls: selector 124 is exact on 11 of 133 records, selector 134 on 330 of
3,990, and selector 135 on 33 of 399. Those counts demonstrate the retained
dual-energy contract; they are not failed cross-path comparisons.

## Instrumentation correction

The first post-correction run correctly produced zero displayed GO5
differences and exact Born arguments, but its exact-mode assertion failed
because the duplicate trace evaluator still consumed the original-energy Born
field while printing the production field. Commit `01d58a4` changes that one
diagnostic input. The failed `post-correction/` capture is retained locally and
is not part of this manifest-bound passing package.

## Primary files

- `summary.tsv` records exact-field counts by selector.
- `supply-comparison.tsv` retains all 4,522 aligned target records and equality
  flags.
- `typed-supply.tsv`, `forced-cmmwp-supply.tsv`,
  `forced-grid-supply.tsv`, and `forced-return-supply.tsv` retain the raw
  boundaries.
- `typed-go5.tsv`, `forced-legacy-go5.tsv`, and `go5-differences.tsv` retain the
  complete displayed comparison.
- `combined-diagnostic.patch`, `run-context.txt`, `build-manifest.txt`, and
  `manifest.sha256` bind instrumentation, provenance, build, and file hashes.

This is a correction candidate, not acceptance, integration, publication, or
physics approval.
