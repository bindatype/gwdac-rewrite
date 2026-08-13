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
docker compose exec -T dev bash /phase2/scripts/run-cm12-form-diagnostic
```

## Run the clean-checkout gate

From the `outputs` repository root:

```sh
phase2/scripts/run-cm12-gate
```

The gate creates an isolated Docker Compose project and source volume, restores
the pinned repository bundles, rebuilds the modern reference and candidate
seam, and runs every DSG and amplitude fixture through the modern reference,
checked-in arndt64 executable, checked-in GWDAC executable, and candidate. It
writes one pass/fail row per fixture under `phase2/reports/gate/` and exits
nonzero after reporting all mismatches. Set
`GWDAC_GATE_KEEP_ENVIRONMENT=1` to retain the containers and volumes for
diagnosis.

The oracle container remains network-disabled and read-only apart from its
dedicated work volume and report mount.

For review, use the repository-level harness instead of writing generated
reports into the authoritative checkout:

```sh
make reviewer-verify
make reviewer-reproduce-cm12
```

The verifier reads only committed evidence. The reproducer clones the exact
commit into a disposable workspace, runs all 24 fixtures and 288 displayed
records, and gates only the modern build plus the two checked-in historical
executables. The failed PRBAS request candidate is still executed and its
mismatches are reported as diagnostic evidence.

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
- The experimental 60-form request candidate remains intentionally failing at
  commit `9cb0009`; it is not an accepted replacement for `PRBAS`.
- Diagnostic commit `516c375` shows that, for the focused CM12 pion-plus
  target, frozen `PNPWI` skips dispatch once and then selects `PNTEST`, while
  the candidate directly calls `PNSM05`. `PNMOD` and `ADDRESK` are no-ops for
  all 18 retained non-`1xx` rows.
- The 468-row dispatch survey records 10 no-dispatch rows and 458 `PNTEST`
  selections, with no `PNSM05` selections. Saved title state and legacy energy
  dither remain explicit hidden-state boundaries; no orchestration change was
  accepted.

The current program finish line is a modern Ubuntu compatibility container.
Phase 3 language selection and later rewrite phases are deferred pending an
explicit program decision. The reviewer harness now provides read-only evidence
verification, disposable reproduction, deterministic labels/build paths, and
unambiguous exit semantics. It does not accept the PRBAS candidate.

## Pause gate

The focused hadronic-pipeline diagnostic is complete. A general `RESUME` does
not modify the candidate, title dispatch, saved-state sequencing,
orchestration, formulas, fixtures, tolerances, or start Phase 3. Each such
change requires its own explicit scope.

## Control-language changes

Changes to text that defines authorization, gates, pause conditions, or the
meaning of `RESUME` must be announced before editing and classified by practical
effect as `no_authority_change`, `tightening`, or `loosening`.

- `no_authority_change` and `tightening` edits may land only inside an
  authorized documentation checkpoint after their files and classification are
  announced.
- `loosening` always requires direct, separate user authorization.
- Review must verify the classification against practical effect rather than
  wording alone.
- The commit must carry a `Control-language:` trailer naming the classification
  and affected file.

This policy records how control-language edits are audited; it grants no new
authority and does not alter the active pause gate.
