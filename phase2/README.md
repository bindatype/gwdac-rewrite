# Phase 2: pion photoproduction contract extraction

Phase 2 is currently restricted to the retained CM12 pion photoproduction
workflow. `pnpolw` and other reaction families remain preserved Phase 1
evidence but are not active rewrite targets.

## Run the contract corpus

From `outputs/container-environment`:

```sh
docker compose exec -T dev bash /phase2/scripts/run-prsdd-corpus
docker compose exec -T -e PRSD_ENGINE=arndt64 oracle \
  bash /phase2/scripts/run-prsdd-corpus
docker compose exec -T -e PRSD_ENGINE=gwdac oracle \
  bash /phase2/scripts/run-prsdd-corpus
docker compose exec -T dev bash /phase2/scripts/compare-prsdd-corpus
docker compose exec -T dev bash /phase2/scripts/inventory-prsdd-data
docker compose exec -T dev bash /phase2/scripts/run-prsdd-amplitude-corpus
docker compose exec -T -e PRSD_ENGINE=arndt64 oracle \
  bash /phase2/scripts/run-prsdd-amplitude-corpus
docker compose exec -T -e PRSD_ENGINE=gwdac oracle \
  bash /phase2/scripts/run-prsdd-amplitude-corpus
docker compose exec -T dev \
  bash /phase2/scripts/compare-prsdd-amplitude-corpus
docker compose exec -T dev \
  bash /phase2/scripts/check-prsdd-amplitude-dsg-consistency
docker compose exec -T dev perl /phase2/scripts/map-prsc
docker compose exec -T dev bash /phase2/scripts/inventory-cm12-dataset
docker compose exec -T dev bash /phase2/scripts/build-cm12-seam
docker compose exec -T -e PRSD_ENGINE=seam dev \
  bash /phase2/scripts/run-prsdd-corpus
docker compose exec -T -e PRSD_ENGINE=seam dev \
  bash /phase2/scripts/run-prsdd-amplitude-corpus
docker compose exec -T dev bash /phase2/scripts/compare-cm12-seam
```

The oracle container remains network-disabled and read-only apart from its
dedicated work volume and report mount.

## Current result

- 11 normal, boundary, malformed-recovery, and scientifically invalid decks.
- 138 parsed result records.
- Exact typed-table equality across the modern headless build and both
  historical executables at displayed precision.
- Three legacy validation/finite-number defects explicitly characterized.
- JSON request and result schemas plus a written scientific-review boundary.
- 13 choice-1 Walker/VPI-SU amplitude decks and 150 typed records.
- Exact amplitude-table equality across all three engines at displayed
  precision.
- A rounding-bounded invariant confirms that the choice-1 amplitudes feed the
  frozen `DSG` calculation.
- A reproducible `/PRSC/` map verifies one 60-field, 89,480-byte layout across
  all 43 active declarations and records field-level lexical access evidence.
- The CM12 K-matrix loader now validates and loads 42 files as 14 immutable
  S/P/D/F partial-wave triplets on a common 275-point Wcm grid.
- The scalar `cmmwp` seam has explicit dataset, form-number, parameter,
  multipole, Wcm, and Born-term inputs and performs no file I/O or shared-state
  mutation.
- Forty-two direct evaluations match legacy `ysKCM` exactly at
  single-precision component level.
- The native solution loader verifies the SHA-256 of `sdat/prsol.dat` before
  parsing the `CM12` record into 54 explicit records, 60 active forms, fixed
  isospin/helicity coefficients, and immutable background constants.
- The explicit background seam returns full Born and OPEC multipoles plus
  four HOPEC amplitudes and is exact across an A-B-A order-independence test.
- Forty-two actual-solution scalar evaluations with nonzero Born terms match
  legacy `ysKCM` exactly.
- Pure `PRDA` accumulation matches six split-legacy cases exactly at unrounded
  single precision. Pure DSG passes formula, threshold-rejection, and
  invalid-domain tests.
- The seam compatibility binary matches all 138 DSG and 150 choice-1
  amplitude records byte-for-byte at displayed precision.

## Pause gate

This extraction milestone is complete. Do not start pure `PRBAS`
orchestration, native background-formula replacement, or target-language work
until the user sends the exact command `RESUME`.
