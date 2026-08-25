# GWDAC rewrite artifacts

Documentation reviewed: 2026-08-25

This private repository is the authoritative build, contract, diagnostic, and
evidence checkout for the GWDAC/SAID modernization effort. Historical source
inputs remain preserved separately in `bindatype/gwdac` and
`bindatype/arndt64` and as committed repository bundles.

## Branch roles

- `main` is the stable reconstructed baseline and the GitHub default branch.
- `dev` is the active evidence and documentation branch. Until the next
  reviewed promotion, readers must use `dev` for the current project state.
- Promotions are reviewed fast-forwards from `dev` to `main`; published history
  is not rebased, squashed, force-pushed, or rewritten.

The private remote is
[`bindatype/gwdac-rewrite`](https://github.com/bindatype/gwdac-rewrite).

## Current finish line

The current program target is an intermediate operational win: a reproducible
modern Ubuntu container that runs the retained SAID workflows without `g77`,
`libg2c`, or the obsolete production operating system while reproducing the
documented website behavior. Phase 3 language selection and the later rewrite,
service, and deployment phases are deferred pending an explicit program
decision; they are not required for this intermediate win.

Phase 0 preservation and the retained-scope Phase 1 `prsdd`/`pnpolw` baselines
are complete. Phase 2 has accepted immutable CM12 solution and dataset loaders,
an explicit background boundary, pure scalar multipole, four-amplitude, and DSG
calculations, and a compatibility adapter that preserves all 138 DSG and 150
choice-1 amplitude records at displayed precision. `PRBAS` request orchestration
has not been replaced. The latest candidate remains intentionally failing and
is diagnostic evidence only.

The runtime-refresh track has now attempted all six additional engines on
Ubuntu 24.04 with GNU Fortran 13.3.0. `eprsd` and `nnsd` exactly match retained
historical decks; `pdsd` and `pdesd` exactly match startup/quit smoke tests.
`pnsd` exactly reproduces the retained SP06 no-render deck, including seven DSG
rows and its seven-artifact runtime contract. `knsd` now completes its archived
deck under both the checked-in and modern executables; its raw stdout differs
only in the sanctioned five-line configured data-root display relation. These
runtime results establish compatibility evidence, not physics approval.

## Compatibility boundaries

The copied-source `prrdx-gfortran-blank-a4.patch` remains the accepted build
mitigation. It is not a general GO5 fidelity fix: the database-list diagnostic
shows a historical/unpatched selection of 238 records versus 204 when patched.
However, in the retained GO5-primed website deck, the patched build completes
normally while the unpatched build prints the exact witness row and summary,
then aborts with exit status 2. Removing or changing the patch requires a
separate fixture-backed decision.

The public website's CM12 pion-plus result is request-history dependent. The
deployed `GO5` priming sequence changes the later displayed DSG token from
`0.2036E+01` to `0.2098E+01` on all three accepted executables. This behavior is
preserved as a website-fidelity target and registered as `SAID-DEFECT-001`;
physics review remains pending.

## Start here

- `GWDAC Rewrite Plan.md`: living roadmap, decisions, evidence boundaries, and
  current status.
- `phase1/README.md`: modern Fortran baseline, runtime refresh, production
  lineage, and compatibility diagnostics.
- `phase2/README.md`: reproducible CM12 contract and diagnostic commands.
- `reviewer/README.md`: read-only evidence verification, disposable
  reproduction, and process exit semantics.
- `phase1/reports/defect-register.md`: known deployed compatibility defects.
- `security/reports/credential-scan-20260812/README.md`: bundle-aware committed-
  history credential-scan scope and sanitized result.

The reviewer harness is now available through `make reviewer-verify` and
`make reviewer-reproduce`. The first command only verifies committed evidence;
the second clones the exact commit into a disposable workspace before running
the 24-fixture CM12 gate, exact `pnsd` oracle contract, and separate five-engine
runtime-refresh sweep. Measured with `git status --porcelain=v1 -uall`, the
authoritative dirty inventory is six modified plus 561 untracked files: 567
entries with status-list SHA-256 `9301c33f06487ac65c131d2e090dc23b33e86a9a0e1066ed18ab7dc5bcb35632`.
Those files remain outside these commits.

Gate 1 is bound to the full expected commit and fails closed on identity drift.
It validates the machine-readable runtime package registry, package
checkpoints, deterministic aggregate generation, pinned collation, and
registered README manifest coverage. These controls establish mechanical
provenance; they do not validate narrative prose or provide physics approval,
which remain human-review responsibilities.
