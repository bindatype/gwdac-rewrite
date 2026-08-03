# Phase 1: reproducible Fortran baseline

This directory contains the build-only compatibility overlay for `ARCH-001`.
It builds `prsdd` entirely from the Fortran and C sources in
`bindatype/arndt64`, and extends the same source-only method to `pnpolw`.

The build does not use `g77`, `libg2c`, checked-in object files, or checked-in
static libraries. It:

- compiles the preserved Berkeley `fsplit.c` as a modern 64-bit tool;
- splits and rebuilds `saidopen.a` and `libxz.a`;
- compiles the nine canonical `prsdd` source files;
- rebuilds the 145-member `gplot` dependency closure required by `prsdd`;
- builds a second `prsdd-headless` target against a 13-entry compatibility
  boundary instead of `gplot`, X11, GD, or the PostScript converter;
- applies two byte-equivalent compiler compatibility changes to a copied
  `gplot` source tree; and
- replaces the copied `saidopen.for` personal data path with
  `SAID_DATA_ROOT`, defaulting to `../sdat`;
- preserves g77's final blank Hollerith-field behavior in a copied `pru.f`;
  and
- links a modern x86-64 `prsdd` executable.

Run from `outputs/container-environment`:

```sh
docker compose up -d
docker compose exec dev /phase1/scripts/build-prsdd
docker compose exec dev /phase1/scripts/run-go3pr
docker compose exec oracle /phase1/scripts/run-historical-go3pr
docker compose exec dev /phase1/scripts/compare-go3pr
docker compose exec dev /phase1/scripts/run-go3pr-no-render-legacy
docker compose exec dev /phase1/scripts/run-go3pr-headless
docker compose exec dev /phase1/scripts/compare-go3pr-headless
docker compose exec dev /phase1/scripts/map-said-sources
docker compose exec dev /phase1/scripts/build-pnpolw
docker compose exec dev /phase1/scripts/run-pnpolw
docker compose exec oracle /phase1/scripts/run-historical-pnpolw
docker compose exec dev /phase1/scripts/compare-pnpolw
docker compose exec oracle /phase1/scripts/run-historical-pnsd
docker compose exec dev /phase1/scripts/build-pnsd
docker compose exec dev /phase1/scripts/run-pnsd
```

The executables are written to the Docker named volume under
`/workspace/phase1/reproducible/artifacts/<commit>/prsdd` and
`prsdd-headless`. Build logs and the manifest are written to `reports/` in this
directory. The run commands execute in isolated, cleaned copies of `pr/`,
repair the archived personal KCM symlink, validate the 19-point DSG result, and
record output artifacts and checksums in `reports/`.

`reports/warning-register.md` classifies every warning category emitted by the
clean build. The isolated historical oracle supplies compiler-matched versions
of the four obsolete shared-library families required by the checked-in
executables. Both historical binaries complete the same deck with exit 0 and
empty stderr.

`reports/go3pr-oracle-comparison.md` records the historical comparison. The
current GFortran build, both checked-in executables, and the committed GWDAC
`TPR` transcript produce byte-identical 19-row DSG tables. `SAID.TMP`,
`SAID.PCT`, `SAID.LOG`, and `fort.7` are also byte-identical across the three
clean executable runs.

`reports/go3pr-headless-comparison.md` records the non-rendering comparison.
The historical deck ends with `C` and `Y`, explicitly converting plot records
to PostScript. The no-render deck ends at `GO99`; under that contract, the
rendering and headless builds have identical stdout and non-renderer artifacts,
while the headless run produces neither `SAID.PS` nor `fort.3`. Its ELF needs
only `libgfortran`, `libm`, `libgcc_s`, and `libc`.

`reports/canonical-source-map.md` records the file-, routine-, and
behavioral-level selection of `said/` over `said_bkp/`, `said_old/`, and the
archived variants. The adjacent TSV files retain the complete SHA-256 and
routine-body evidence.

The `pnpolw` build reconstructs `pnu`, `MOD01`, `saidopen`, `libxz`, and the
required `gplot` closure from source. Its two retained input files and seven
startup datasets are staged explicitly. Two independent builds produce
SHA-256
`a69b66b3c488b7a70def8170e7ba7a836383aedf13bee74113390b928d6cce58`.

`reports/pnpol-oracle-comparison.md` records the second-engine gate. The modern
source build and checked-in arndt64 executable exit 0 with empty stderr and
produce byte-identical date-normalized `PNPOL.PCT` streams plus byte-identical
`PNPOL.TMP`. The GWDAC executable is demonstrably a separate lineage, and both
old checked-in `PNPOL.PCT` files are unpaired captures rather than exact
goldens for the surviving input pair.

These are equivalence results for the captured CM12 workflow at displayed
precision and the retained D13 `pnpolw` plot-command workflow, not a general
claim of scientific or hidden floating-point equivalence.

The Legacy Runtime Refresh inventory ranks the remaining six archived engines
by surviving source, local dependencies, datasets, executable, input deck, and
captured transcript. Its first attempt, `pnsd`, builds reproducibly with modern
gfortran and produces a byte-identical seven-row SP06 DSG table. It then stops
at an internal formatted read in `pnu.f:4569`, where the checked-in executable
continues normally. `reports/runtime-refresh/pnsd/README.md` records that first
divergence and the resulting blocked gate; no source fix or second engine was
started.

Phase 1 is complete for the retained scope. `build-prsdd` keeps the original
reference build as its default and also accepts the Phase 2
`CM12_SEAM_ROOT` overlay. That conditional mode replaces only the legacy
CM12 solution, `cmmwp`/`ysKCM`, `PRDA`, and DSG calculation path; it does not
alter the default frozen Phase 1 binaries or their evidence.

`reports/live-production-inventory/README.md` records a read-only static
inventory of the deployed SAID host. Production is a hybrid tree: public
adapters under `/home/www/gwdac`, CM12 under `/home/arndt64`, most other
engines under `/home/arndt`, and selected sessions under `/home/ron`. The nine
CM12 build sources, deployed `prsdd`, all 18 KCM files, and the complete first
CM12 solution record are byte-identical to the archived snapshot. The public
`go3pr2` adapter and the containing `prsol.dat` are newer deployment state.
This is captured/reference evidence only; no live CGI or engine was executed.

`reports/go3pr2-adapter-diagnostic/README.md` closes the current website-value
mechanism at displayed precision. The live wrapper's `GO5` priming changes the
subsequent 1000 MeV, 90-degree pion-plus DSG token from `0.2036E+01` to
`0.2098E+01` on the modern headless build and both checked-in executables,
exactly matching the captured website. The captured `wtrim3` only selects the
third `WEB` section and does not change the value. This is a request-sequencing
result, not authorization to change compatibility behavior.

`reports/defect-register.md` names this deployed behavior as
`SAID-DEFECT-001`. The public website-fidelity target `public-go3pr2-v1`
preserves the `GO5`-primed displayed token `0.2098E+01`; fresh-process `GO3`
and `0.2036E+01` remain a separate engine-level contract. The registration is
a compatibility decision, not scientific approval or an implementation,
fixture, tolerance, or Phase 2 contract change.

`reports/live-production-capture/README.md` records the path-allowlisted,
one-way production capture. All 542 files and 34,218,873 bytes match the
independently generated production SHA-256 manifest. Captured binaries and
datasets remain outside Git under `work/production-20260803`; the allowlist,
hashes, and source comparison are committed. `RESUME` never authorizes a
production write, deployment, configuration change, or live execution.

`reports/live-production-capture/content-diff/README.md` classifies all eight
differing and two production-only source/build files at file and routine
levels. The drift includes real operational and physics-relevant changes, but
none is in the nine-file public CM12 `prsdd` build. Outside CM12, static source
drift remains separate from source-to-binary pairing and behavioral approval.
