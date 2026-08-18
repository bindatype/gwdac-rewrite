# Legacy runtime-refresh engine sweep

Date: 2026-08-13

## Scope and outcome

The five remaining archived engines were built from the unchanged
`f6c81d01a1fe8b007c247acc2213f821a62dc4f2` source snapshot on Ubuntu 24.04
with gfortran 13.3.0. Every engine linked without `libg2c`,
`libgfortran.so.3`, or `libpng12`. No legacy source was edited and no
warning-driven fix was made.

| Engine | Surviving input | Result | Evidence limit |
| --- | --- | --- | --- |
| `eprsd` | Archived deck | Exact pass | Same-input historical and modern stdout |
| `nnsd` | Archived deck | Exact pass | Same-input historical and modern stdout |
| `knsd` | Archived deck | Completes; output differs | Both runs exit 0; stdout differs only in the intended `SAID_DATA_ROOT` display lines |
| `pdsd` | Synthetic startup/quit | Exact pass | Startup and clean quit only |
| `pdesd` | Synthetic startup/quit | Exact pass | Startup and clean quit only |

`knsd` was previously the one unresolved blocker from this sweep, with both
executables exiting 2 while requesting `/home/arndt64/KN/KNSOL.USR`. That
blocker was environmental rather than a source defect: the archived `KN/INPUT`
deck supplies the absolute path as interactive input after `SAID_DATA_ROOT` has
already been applied, so the portable-data-root patch could not intercept it.
Both containers now provide `/home/arndt64/KN` as a compatibility alias,
resolving to the 10,088-byte `KNSOL.USR` rather than any of the five zero-byte
copies in the archive.

Both executables now exit 0 and render `PRMS=(62,27)`. The earlier modern
rendering of `PRMS=(62 27)` was a compiler-semantics defect: `-std=legacy`
makes gfortran treat a comma as a field terminator in formatted input, which
g77 did not do for A editing. The `knsd` main program unit is compiled
`-std=gnu` to restore g77 field handling. `stdout_exact` remains `no` because
the raw data-root display strings differ; a strict contract permits only those
lines to differ and requires every other byte to match.

No source, fixture, tolerance, formula, or archived deck was changed. This
remains runtime-compatibility evidence; physics approval is still pending.

The exact `pdsd` and `pdesd` results are intentionally weaker than the two
deck-driven passes because no retained request deck or paired transcript
survives. None of these results constitutes physics approval.

## Version-control checkpoints

- Stable `main` was fast-forwarded to the approved commit
  `c7f1918da2f4f86d44a99748ed9f0776f0c9f735`.
- Active evidence remains on `dev`; each engine was committed and pushed as
  listed in `summary.tsv`.
- The pre-existing six modified and 59 untracked report entries were not
  staged or committed by this sweep.

Each engine directory contains build logs, captured historical and modern
runs, file-access traces, comparisons, manifests, and its own evidence hash
manifest. `summary.tsv` is the machine-readable aggregate.
