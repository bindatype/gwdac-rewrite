# PRBAS formula-local scalar-copy diagnostic

## Status

This is a structurally valid partial-success diagnostic result. It validates the
formula-local scalar-copy correction against the targeted PRDLT contract, but it
does not accept the typed PRBAS candidate and is not a corpus, Gate 1, or Gate 2
result.

The run used exact candidate
`c476de670101c2dbb0c3cdca332b861ddeeb5d31`. The formula-local scalar-copy
correction is that commit; earlier candidate commits retain the threshold
rescaling correction and diagnostic harness. `run-context.txt` binds the exact
candidate, archived source, executable, diagnostic patches, runner, fixture,
and all ten seam sources.

## Evidence labels

- `captured`: typed and forced-legacy runtime outputs produced by this run.
- `reference`: the forced-legacy path through the same freshly built executable.
- `inferred`: no mechanism is assigned to the remaining GO5 differences here.
- Physics/domain review remains pending. No result here is scientific approval.

## Captured result

The unchanged threshold-rescaling probe passed all 25 fixture rows and all 50
real/imaginary comparisons before this capture. Both fresh-process diagnostic
executions exited zero, and structural validation passed.

The targeted first-call contract is exact: 260/260 PRDLT values and all 26/26
forms match forced legacy, with no first field difference. Across the 132 calls
present in both complete traces, all 34,320 PRDLT values are exact. The typed
path has the already expected additional call, producing 3,458 typed rows versus
3,432 forced-legacy rows; this capture does not reinterpret that established
structural difference.

The full GO5 comparison remains non-identical. Both paths contain 1,533 rows and
9,198 displayed fields. Of those fields, 8,989 are exact and 209 differ across
200 rows: 159 predicted observations and 50 `dchi` values. Row identifiers,
angles, measured observations, and errors are exact. The first difference is
row 1's predicted observation: typed `0.14356E-03`, forced legacy
`0.14353E-03`.

Compared with the preceding post-rescaling capture, the correction closes all
34 remaining first-call PRDLT differences and reduces GO5 differences from 594
displayed values across 361 rows to 209 values across 200 rows. It therefore
confirms and removes repeated in-place rescaling of cached PNTTEST values, but it
does not establish complete PRBAS equivalence.

## Stop condition

No additional correction, corpus run, gate, integration, or push follows from
this result without separate authorization. The next bounded investigation must
start from the remaining GO5 difference after the now-exact PRDLT boundary; it
must not revisit the closed scalar-rescaling mechanism without contrary
evidence.
