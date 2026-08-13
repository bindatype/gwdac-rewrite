# PDSD runtime-refresh smoke

Date: 2026-08-13

## Result

`pdsd` is an exact startup/quit smoke pass. The unchanged `f6c81d0` sources
build and link with Ubuntu 24.04, gfortran 13.3.0, and the current system
libraries. Given the same synthetic input (a blank non-graphics terminal
selection followed by `qt`), the resulting executable and the checked-in
historical executable both exit normally with status 0 and produce the same
659-byte stdout, SHA-256
`47efa50c88765b40a0542d566677fbac42098527b1a294f78d27fe655e3611dc`.

No retained request deck or paired historical transcript survives for this
engine. This probe establishes startup and clean termination only; it does not
exercise or validate a retained pion-deuteron workflow. It is
runtime-compatibility evidence, not physics approval.

## Evidence

- **Captured:** `historical/` is a synthetic startup/quit run of the checked-in
  executable in the isolated historical-runtime container.
- **Reference:** `build/` and `modern/` record the unchanged-source build and
  its same-input run in the Ubuntu 24.04 development container.
- The historical and modern runs each opened 12 paths. Dataset-path
  differences are limited to the configured `/home/arndt64/sdat` versus
  `/workspace/arndt64/sdat` roots.
- The archived GWDAC capture is unpaired and does not gate this result.
- The modern build emitted 109 warning instances. No warning-driven source
  change was made.
- The modern executable has no dependency on `libg2c`, `libgfortran.so.3`, or
  `libpng12`; its dependency list remains recorded in `modern/manifest.txt`.

Run the three scripts in order, using the named Compose services:

```sh
docker compose exec -T dev /phase1/scripts/build-runtime-engine-smoke pdsd
docker compose exec -T oracle /phase1/scripts/run-historical-runtime-engine-smoke pdsd
docker compose exec -T dev /phase1/scripts/run-runtime-engine-smoke pdsd
```

Verify the committed evidence from `phase1/`:

```sh
sha256sum -c reports/runtime-refresh/pdsd/evidence-manifest.sha256
```
