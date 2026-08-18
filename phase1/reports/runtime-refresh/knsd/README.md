# KNSD runtime-refresh smoke

Date: 2026-08-13. Updated 2026-08-18 for the ancillary compatibility candidate.

## Result

`knsd` builds and links from the unchanged `f6c81d0` sources on Ubuntu 24.04
with gfortran 13.3.0, and the archived `KN/INPUT` smoke now completes. Both the
checked-in historical executable and the modern build exit 0 with normal
completion.

The prior blocker was environmental, not a source defect. `KN/INPUT` line 6
supplies `/home/arndt64/KN/KNSOL.USR` as interactive input to SAIDOPEN's unit-11
repoint prompt, after SAIDOPEN has already applied `SAID_DATA_ROOT` to its
`FIL()` table, so `saidopen-portable-data-root.patch` cannot intercept it. Both
containers now provide `/home/arndt64/KN` as a compatibility alias, following
the existing pattern for `pr`, `said`, and `sdat`. The archived deck is
unmodified.

The alias must resolve to the 10,088-byte `KNSOL.USR`, SHA-256
`0ecf96f4e00fa0e648943417fba0d8a06e3be4438a6834952b0dfc72f259bdef`. Five of the
eight `KNSOL.USR` copies in the archive are zero bytes; a fix that let the
relative name resolve instead would load an empty solution file, exit 0, and
produce silently incorrect results.

This is runtime-compatibility evidence, not physics approval.

## Evidence

- **Captured:** `historical/` and `modern/` record complete, normally
  terminating runs of the checked-in executable and the modern build against
  the same archived input.
- **Reference:** `build/` records the unchanged-source build.
- The historical and modern stdout files are both 7,115 bytes and differ in a
  single hunk of five lines: the configured `/home/arndt64/sdat` versus
  `/workspace/arndt64/sdat` display roots and their fixed-width column padding.
  Every other byte matches.
- Both executables render `PRMS=(62,27)`. The earlier modern rendering of
  `PRMS=(62 27)` was a compiler-semantics defect, not a data difference: the
  comma is present in `KNSOL.USR`, and `-std=legacy` makes gfortran treat a
  comma as a field terminator in formatted input, which g77 did not do for A
  editing. The `knsd` main program unit is now compiled `-std=gnu`, which
  restores g77 field handling process-wide via `_gfortran_set_options`. See
  `phase1/scripts/verify-gfortran-comma-a-editing`.
- `stdout_exact` remains `no`, correctly: the raw data-root strings differ. The
  sanctioned relation is enforced separately and permits only those five
  display lines to differ.
- `SAID.PS` is created by both runs at 0 bytes and is asserted as a completion
  witness, then excluded and cleaned. Rendering is outside scope.
- The archived GWDAC capture is not paired with `KN/INPUT` and does not gate
  this result.
- The modern build emits 633 warning instances across the core, libraries, and
  gplot logs. The increase from the previous 233 is diagnostic only: `-std=gnu`
  reports legacy extensions that `-std=legacy` accepts silently. No
  warning-driven source change was made.
- The modern executable has no dependency on `libg2c`, `libgfortran.so.3`, or
  `libpng12`; its dependency list remains recorded in `modern/manifest.txt`.

Run the three scripts in order, using the named Compose services:

```sh
docker compose exec -T dev /phase1/scripts/build-runtime-engine-smoke knsd
docker compose exec -T oracle /phase1/scripts/run-historical-runtime-engine-smoke knsd
docker compose exec -T dev /phase1/scripts/run-runtime-engine-smoke knsd
```

Verify the committed evidence from `phase1/`:

```sh
sha256sum -c reports/runtime-refresh/knsd/evidence-manifest.sha256
```
