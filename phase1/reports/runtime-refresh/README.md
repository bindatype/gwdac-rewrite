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
| `knsd` | Archived deck | Blocked | Both runs exit 2 at a hard-coded absolute path; stdout also differs |
| `pdsd` | Synthetic startup/quit | Exact pass | Startup and clean quit only |
| `pdesd` | Synthetic startup/quit | Exact pass | Startup and clean quit only |

The `knsd` dataset file survives at `/workspace/arndt64/KN/KNSOL.USR`, but
both executables request `/home/arndt64/KN/KNSOL.USR`. No path-layout or source
fix was attempted. Its first stdout differences also include legacy
`PRMS=(62,27)` versus modern `PRMS=(62 27)` rendering. This remains the one
unresolved engine blocker from this sweep.

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
