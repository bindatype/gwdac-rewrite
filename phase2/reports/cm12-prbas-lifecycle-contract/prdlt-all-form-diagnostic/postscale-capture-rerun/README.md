# PRBAS post-threshold-rescaling diagnostic

## Status

This is a structurally valid negative diagnostic result. It does not accept the
typed PRBAS candidate and is not a Gate 1 or Gate 2 result.

The run used exact candidate
`8be53fd572b1148e31c64e5d050b7805ed3a56ca`. The product correction is commit
`74ce7c1a2ebc27af55b356f0b4e8004a76ff9ca3`; the later commits harden and repair
the diagnostic harness. `run-context.txt` binds the exact candidate, archived
source, executable, diagnostic patches, runner, fixture, and all ten seam
sources.

## Evidence labels

- `captured`: typed and forced-legacy runtime outputs produced by this run.
- `reference`: the forced-legacy path through the same freshly built executable.
- `inferred`: the repeated-slot explanation below. It is not yet a tested fix.
- Physics/domain review remains pending. No result here is scientific approval.

## Captured result

Both fresh-process executions exited zero. Structural validation passed with
133 typed calls, 3,458 typed trace rows, 3,432 forced-legacy field rows, 260
compared call-1 fields, and 260/260 exact metadata fields.

The correction improved exact scientific fields from 178/260 to 226/260 and
exact forms from 1/26 to 10/26. Thirty-four field values remain different across
16 forms: 16 `TER`, one `TEI`, one `DER`, and 16 `DEI` values. The complete field
comparison is in `call-1-field-comparison.tsv`; `per-form-summary.tsv` retains all
26 form classifications.

The full GO5 corpus contains 1,533 rows on each path. Of 7,665 displayed values,
7,071 are exact and 594 differ across 361 rows. All 1,533 angles, measured
observations, and errors are exact. Differences occur in 323 predicted
observations and 271 `dchi` values. The first difference is row 1's predicted
observation: typed `0.12472E-03`, forced legacy `0.14353E-03`. The complete paths
are `typed-go5.tsv` and `forced-legacy-go5.tsv`.

## Inferred mechanism and next bounded test

Rows 2-6 and 11-14, the first use of their respective hadronic
`(state_index, legacy_l)` slots, are exact. The first residual is row 7, which
reuses row 2's slot; subsequent reused slots show the same pattern. The typed
seam currently applies the threshold scaling in place to the selected element
of the array returned by frozen `PNTEST`. If `PNTEST` takes its cache-return path
without repopulating that caller array, the next form scales the already scaled
value again. This fully explains the ordering pattern but remains `inferred`.

The next correction candidate, if separately authorized, should preserve the
unscaled `PNTEST` output and apply the exact legacy-order scaling to a
formula-local scalar or array copy. It must rerun the 25-row/50-value focused
fixture and this complete 260-field/1,533-row diagnostic. No tolerance, fixture,
oracle, or expected-value change is indicated.
