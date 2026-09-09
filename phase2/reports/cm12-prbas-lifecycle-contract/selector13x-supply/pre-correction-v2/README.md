# PRBAS selector-13x pre-correction diagnostic

## Scope

This captured/reference-candidate diagnostic measures selectors 124, 134, and
135 across the complete retained `live.in` deck before the authorized
dual-energy correction. The exact runner candidate is
`eaa20b5637f4e69a0c0d3be6340fd4a0edc00f34`; product content remains exact
`c476de670101c2dbb0c3cdca332b861ddeeb5d31`.

The archived source is exact commit
`f6c81d01a1fe8b007c247acc2213f821a62dc4f2`. The typed and forced-legacy
executions are reference candidates, not independent oracles. This run changes
no product source, fixture, expectation, tolerance, or oracle and is not Gate 1
or Gate 2.

## Structural result

Structural validation passed. Both fresh processes exited zero. Typed supply,
forced CMMWP supply, and archived PRBAS grid traces each contain 4,522 records:
133 selector-124 records, 3,990 selector-134 records, and 399 selector-135
records. Archived reaction-family filtering returns 2,926 records: 133, 2,527,
and 266 respectively. Every return presence and absence matches the retained
routing rule, with zero unmatched or duplicate keys.

Both paths retain all 1,533 GO5 scientific rows and the previously measured 209
displayed-field differences. The typed and forced GO5 tables are respectively
byte-identical to the preceding selector-134 capture, proving that adding
selector-135 instrumentation did not perturb displayed output.

## Selector result

Request energy, `Wcm`, reconstructed energy, and original-energy OPEC are exact
between paths on every record for all three selectors. Selector 124 does not
consume a Born term and remains exact for every raw and returned complex
multipole.

| Metric | Selector 134 | Selector 135 |
| --- | ---: | ---: |
| request versus reconstructed energy exact | 330 / 3,990 | 33 / 399 |
| Born argument exact | 1,256 / 3,990 | 91 / 399 |
| raw real exact | 1,276 / 3,990 | 95 / 399 |
| raw imaginary exact | 1,288 / 3,990 | 94 / 399 |
| raw complex exact in both components | 1,269 / 3,990 | 89 / 399 |
| returned real exact | 809 / 2,527 | 73 / 266 |
| returned imaginary exact | 800 / 2,527 | 64 / 266 |

Selector 135 now directly confirms the inferred `/10 == 13` mechanism. Calls
1, 3, and 5 reconstruct a different photon energy and differ in all three
selector-135 Born arguments and raw complex multipoles. Calls 2, 6, and 133
reconstruct the original energy and are exact in all three. Across all 133
calls, 21 have all three Born arguments exact and 22 have all three raw complex
multipoles exact. The sole class mismatch is call 42: two of three Born inputs
are exact, while all three raw outputs round to identical `real32` values.

The first selector-135 difference is call 1, family 1, branch 2, orbital `L=1`.
Original energy `1.4510000610351562E+002` round-trips through `Wcm` to
`1.4509996032714844E+002`; typed and forced Born arguments are
`-3.0123981475830078E+001` and `-3.0124019622802734E+001`. The corresponding
raw complex multipoles differ in both components, as retained in
`supply-comparison.tsv`.

## Interpretation

The selector-135 measurement closes the gap identified in review. Selectors 134
and 135 both consume a Born term prepared from photon energy reconstructed from
single-precision `Wcm` in frozen `ysKCM`; selector 124 is the exact no-Born
control. Differences in row-level equality counts reflect `real32` propagation
and do not contradict the common input mechanism.

This package measures the pre-correction state only. It does not declare either
path scientifically correct, authorize expectation changes, or prove that the
pending typed correction closes the complete GO5 residual. Physics review
remains pending.

## Primary files

- `summary.tsv`: exact-field counts separated by selectors 124, 134, and 135.
- `supply-comparison.tsv`: all 4,522 aligned target records and equality flags.
- `typed-supply.tsv`, `forced-cmmwp-supply.tsv`, `forced-grid-supply.tsv`, and
  `forced-return-supply.tsv`: raw boundary traces.
- `typed-go5.tsv`, `forced-legacy-go5.tsv`, and `go5-differences.tsv`: complete
  displayed output and all differences.
- `combined-diagnostic.patch`, `run-context.txt`, `build-manifest.txt`, and
  `manifest.sha256`: instrumentation and provenance bindings.
