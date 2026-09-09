# PRBAS selector-134 supply diagnostic

## Scope

This is a captured/reference-candidate diagnostic at exact runner candidate
`85e23351b65d8814f79b7d72961d666b9faed887`. It executes the complete retained
`live.in` deck in separate fresh processes through the typed PRBAS candidate and
`CM12_FORCE_LEGACY_PRBAS=1`. It does not change product source, fixtures,
expectations, tolerances, or oracles, and it is not Gate 1 or Gate 2.

The archived source is exact commit
`f6c81d01a1fe8b007c247acc2213f821a62dc4f2`. `run-context.txt` binds the
fixture, executable, runner, diagnostic patches, source tree, timezone, and
container OS by identity or SHA-256. Both paths are reference candidates; this
capture does not identify either path as an independent oracle.

## Result

Structural validation passed:

- Both fresh processes exited zero.
- The typed, forced-CMMWP, and archived-grid traces each contain all 4,123
  target records: 133 selector-124 records and 3,990 selector-134 records.
- Archived PRBAS reaction-family filtering returns 2,660 records: all 133
  selector-124 records and 2,527 selector-134 records. All return presences and
  absences match the retained routing rule, with zero duplicate or unmatched
  keys.
- Both paths retain all 1,533 GO5 scientific rows. Their typed and forced GO5
  tables are byte-identical to the prior return-boundary capture and retain the
  same 209 displayed-field differences.

For both selectors, the two paths have exact request energy, `Wcm`, reconstructed
energy, and original-energy OPEC values on every record. Selector 124, which
does not use a Born term, is exact for every raw and returned complex multipole.

For selector 134:

- Only 330 of 3,990 records, representing 11 complete calls, reconstruct the
  original request energy exactly.
- The Born arguments are exact on 1,256 of 3,990 records.
- The raw real and imaginary components are exact on 1,276 and 1,288 records,
  respectively; 1,269 raw complex multipoles are exact in both components.
- The returned real and imaginary components are exact on 809 and 800 of the
  2,527 routed records, respectively; 790 returned complex multipoles are exact
  in both components.
- At call granularity, all 30 selector-134 Born arguments are exact on 16 of
  133 calls, and all 30 raw complex multipoles are exact on exactly those same
  16 calls. There are zero call-class mismatches.

The requested discriminator is visible in representative calls. Calls 1, 3,
and 5 reconstruct a different photon energy; all 30 selector-134 Born arguments
and all 30 raw complex multipoles differ. Calls 2, 6, and 133 reconstruct the
original energy exactly; all 30 Born arguments and raw complex multipoles are
exact. Some other calls reconstruct a different energy but round to unchanged
Born values; those calls also retain exact raw multipoles.

At the first bound record, call 1 at 145.1 MeV, family 1, branch 1, orbital
`L=3`, selector 134, the original request energy is
`1.4510000610351562E+002` and the single-precision `Wcm` round trip produces
`1.4509996032714844E+002`. The typed Born argument is
`-3.3436603844165802E-002`; the forced-CMMWP argument is
`-3.3430110663175583E-002`. The resulting raw complex multipoles are
`(-3.6133203655481339E-002,-2.2004306288181397E-007)` and
`(-3.6126498132944107E-002,-2.2000224930707191E-007)`. After the same retained
`SPW=1`, `SOPW=-1`, and original-energy OPEC adjustment, the supplied values are
`(-2.0869076251983643E-003,-2.2004306288181397E-007)` and
`(-2.0802021026611328E-003,-2.2000224930707191E-007)`.

## Interpretation

The first selector-134 divergence is localized to the Born input of the shared
`cm12_evaluate_multipole` calculation. The typed path prepares Born multipoles
from the original request energy. The CMMWP compatibility seam first computes
single-precision `Wcm`, reconstructs a photon energy from it, and prepares Born
multipoles from that reconstructed value. Selector 134 consumes the Born input;
selector 124 is evaluated by the same machinery but does not consume it and is
the exact control.

This attribution combines captured values with a source-level inference: the
two paths call the same evaluator with the same selector, solution parameters,
dataset, family, branch, orbital `L`, and exact `Wcm`; the Born argument is the
input that differs. Floating-point propagation means row-level Born and output
equality counts need not be identical, but the complete call-level
classification is exact.

This finding localizes the engineering compatibility difference to the
single-precision energy round trip in the CMMWP Born-supply path. It does not
establish that selector 134 is scientifically defective, identify either path
as the historical oracle, or authorize changing the product or compatibility
seam. Selector 135 remains a separate, unmeasured supply class in this capture.

## Primary files

- `summary.tsv`: exact-field counts separated by selectors 124 and 134.
- `supply-comparison.tsv`: every aligned target record and equality flag.
- `typed-supply.tsv`, `forced-cmmwp-supply.tsv`, `forced-grid-supply.tsv`, and
  `forced-return-supply.tsv`: raw trace records at each supply boundary.
- `typed-go5.tsv`, `forced-legacy-go5.tsv`, and `go5-differences.tsv`: all
  displayed GO5 rows and every displayed-field difference.
- `combined-diagnostic.patch`: the disposable instrumentation applied for this
  run.
- `run-context.txt`, `build-manifest.txt`, and `manifest.sha256`: provenance
  and content bindings for the capture.
