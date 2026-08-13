# KNSD runtime-refresh smoke

Date: 2026-08-13

## Result

`knsd` builds and links from the unchanged `f6c81d0` sources on Ubuntu 24.04
with gfortran 13.3.0, but the archived `KN/INPUT` smoke does not complete.
Both the checked-in historical executable and the modern build exit with
status 2 before SAID's normal farewell because they try to open the hard-coded
path `/home/arndt64/KN/KNSOL.USR`.

`KNSOL.USR` survives at `/workspace/arndt64/KN/KNSOL.USR` and at other paths
inside the archived snapshot. The observed failure is therefore a path-layout
compatibility blocker, not evidence that the required data was lost. No path,
source, or container-layout fix was attempted in this smoke-test sweep.

This is runtime-compatibility evidence, not physics approval.

## Evidence

- **Captured:** `historical/` records the checked-in executable's exit-2
  behavior in the isolated historical-runtime container.
- **Reference:** `build/` and `modern/` record the unchanged-source build and
  the modern executable's exit-2 behavior with the same archived input.
- The historical and modern stdout files are both 2,291 bytes but are not
  byte-identical. The first differences are the legacy
  `PRMS=(62,27)` versus modern `PRMS=(62 27)` rendering and the configured
  `/home/arndt64/sdat` versus `/workspace/arndt64/sdat` roots.
- The modern runtime adds a backtrace to stderr; the historical runtime does
  not. Both report the same missing absolute `KNSOL.USR` path.
- The archived GWDAC capture is not paired with `KN/INPUT` and does not gate
  this result.
- The modern build emitted 233 warning instances. No warning-driven source
  change was made.
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
