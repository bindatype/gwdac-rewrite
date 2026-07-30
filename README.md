# GWDAC rewrite artifacts

Documentation reviewed: 2026-07-29  
Execution state: **PAUSED until the user sends `RESUME`**

## Current control documents

- `GWDAC Rewrite Plan.md`: scope, phases, decisions, current status, and next
  recommended work.
- `phase2/README.md`: reproducible Phase 2 commands and current evidence.
- `phase2/contracts/cm12-pure-kernel-interface.md`: target interface and
  implemented solution, scalar, amplitude, and DSG seams.
- `phase2/reports/cm12-seam-validation.md`: loader, direct layer, and
  end-to-end parity evidence.
- `phase2/reports/prsc-shared-state-map.md`: legacy shared-state ownership.

## Current milestone

The reference seam now includes immutable, provenance-checked CM12 solution
and K-matrix loaders, explicit Born/OPEC/HOPEC background outputs, pure
four-amplitude accumulation, and pure DSG calculation. Direct validation
includes 42 actual-solution multipoles with nonzero Born terms, six exact
unrounded `PRDA` comparisons, and three DSG contract cases. The compatibility
executable still matches all 138 DSG and 150 choice-1 amplitude records.

The next boundary is a single pure request-to-result orchestration layer that
replaces remaining `PRBAS` command/grid control and either ports or
independently contracts the formulas currently behind the background seam.
That work is paused until `RESUME`.

## Documentation audit

All Markdown files under `outputs/` were reviewed after the seam validation.
Living status documents and affected contracts/reports were updated. Phase 0/1
oracle reports, package provenance, archive instructions, warning evidence,
and superseded-diagnostics notices remain unchanged because they are
date-stamped or immutable historical evidence and are still factually
consistent.
