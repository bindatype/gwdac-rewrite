# CM12 solution, background, amplitude, and DSG seam validation

Generated: 2026-07-30T04:30:33Z

## Result

The explicit loader accepted exactly 42 CM12 K-matrix files:
14 S/P/D/F partial waves with `cmm`, `cmf`, and `kcm` components.
Every file has 275 records on the common 1080-2450 MeV grid and the expected
record width. A missing dataset root is rejected with typed loader status 2.

The immutable solution loader read the four-character `CM12` record directly
from the surviving `sdat/prsol.dat` source after verifying SHA-256
`dbcaae30bbf44aca6e5482fc2b10b81cb6e1033cf41061bc089d5f6a85576522`. It recovered 54 explicit parameter
records, 60 active physical forms, 34
CM12 form selectors, fixed isospin/helicity coefficients, and the six
background coupling values. A mismatched hash is rejected with status 5 and a
missing solution identifier with status 6.

The explicit background seam returns full Born multipoles, OPEC multipoles,
and four initial HOPEC amplitudes from immutable constants. An A-B-A sequence
returned exact first/third results, demonstrating order-independent seam
behavior for the retained calls.

The headless compatibility binary routes valid CM12 calculation state through
the immutable solution/dataset objects, explicit background seam, pure
`PRDA` accumulation, and pure DSG operation. It completed:

- 11 DSG cases and 138 typed records.
- 13 choice-1 amplitude cases and 150 typed
  records, each with four complex amplitudes.
- Exact byte equality with the modern frozen reference at displayed precision
  for all 11 DSG and 13 amplitude cases.
- Exact single-precision scalar equality with legacy `ysKCM` for
  42 direct evaluations spanning all 14 loaded waves at 1100,
  1500, and 1900 MeV Wcm with a synthetic zero Born contribution.
- Exact single-precision scalar equality for 42 actual CM12
  solution evaluations with 42 nonzero Born contributions.
- Exact unrounded equality with split legacy `PRDA` for 6
  channel/angle/wave cases.
- Exact DSG formula, threshold, and invalid-domain behavior in
  3 direct pure-kernel cases.

The compatibility adapter preserves the known `/PRSC/` `II` mutation and
delegates only non-finite malformed-grid behavior to renamed legacy
`PRDA_LEGACY`/`PROBS_LEGACY`. The public APIs reject those invalid domains.
The background seam still invokes the frozen legacy formula routines behind
its explicit typed boundary; those routines no longer own configuration or
solution state.

- Dataset manifest SHA-256: `b08b55f81fcee039d9ac7f4d681c04fb6255aad9cc6e82cb21f941672488db99`
- Parity table SHA-256: `0276d0631d60b366d7c2142018b4aa4413f51dabca1839670adf78ea6c15f55c`
- Scalar kernel SHA-256: `fd94240ac95b0be23caa59b9d3723e78ae41093d8bbe2b0c6f24913634e8422b`
- Solution/pure-kernel SHA-256: `77e6d58ba5176bf589ae1212fea5b9f7912745264161ee8640ae462286a537a7`
- Background seam SHA-256: `11869dc3b8c2335723985cf989fc7f2da5171dbcec6543335912d38f17637a7f`
- PRDA/DSG adapter SHA-256: `225205ad07c0bca8e5188492f594daf5654ee31f217db807f87828a4ecf166c3`
- Nonzero-Born layer table SHA-256: `3cd3afc3d688a1f545008aa92fd769495664aa1d9fe8fbcacabc2107ecf5496a`
- Pure PRDA/DSG table SHA-256: `8ecaae89042bdcb3d2966df485f8f465fc62fd780bc8b009f499b83c12190d0e`

## Structural boundary

`CM12Dataset` and `CM12Solution` have private components and are populated
only by validating loaders. The native solution loader hashes source bytes
before parsing. The scalar multipole evaluator, pure amplitude accumulator,
and pure DSG operation perform no file I/O, use no COMMON block or mutable
cache, and receive all scientific inputs explicitly.

The compatibility process still owns legacy command parsing, grid
construction, kinematics orchestration, and transcript behavior so the
existing `prsdd` call site remains an oracle. New code must call the typed
loaders and operations directly.

## Pause gate

This requested extraction milestone is complete. Work is paused until the
user sends the exact command `RESUME`.
