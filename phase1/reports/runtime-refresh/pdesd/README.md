# PDESD runtime-refresh smoke

Date: 2026-08-13

## Result

`pdesd` is an exact startup/quit smoke pass. The unchanged `f6c81d0` sources
build and link with Ubuntu 24.04, gfortran 13.3.0, and the current system
libraries. Given the same synthetic input (a blank non-graphics terminal
selection followed by `qt`), the resulting executable and the checked-in
historical executable both exit normally with status 0 and produce the same
609-byte stdout, SHA-256
`a65cfac752ca31d2e11a139dc6ef523a206524a2cf1d773db304594c46536f0e`.

No retained request deck or paired historical transcript survives for this
engine. This probe establishes startup and clean termination only; it does not
exercise or validate a retained pion-deuteron elastic workflow. It is
runtime-compatibility evidence, not physics approval.

## Evidence

- **Captured:** `historical/` is a synthetic startup/quit run of the checked-in
  executable in the isolated historical-runtime container.
- **Reference:** `build/` and `modern/` record the unchanged-source build and
  its same-input run in the Ubuntu 24.04 development container.
- The historical and modern runs each opened 12 paths. Their lists differ only
  in the configured dataset root (`/home/arndt64/sdat` versus
  `/workspace/arndt64/sdat`).
- The archived GWDAC capture is unpaired and does not gate this result.
- The modern build emitted 114 warning instances. No warning-driven source
  change was made.
- The modern executable has no dependency on `libg2c`, `libgfortran.so.3`, or
  `libpng12`; its dependency list remains recorded in `modern/manifest.txt`.

Run the three scripts in order, using the named Compose services:

```sh
docker compose exec -T dev /phase1/scripts/build-runtime-engine-smoke pdesd
docker compose exec -T oracle /phase1/scripts/run-historical-runtime-engine-smoke pdesd
docker compose exec -T dev /phase1/scripts/run-runtime-engine-smoke pdesd
```

Verify the committed evidence from `phase1/`:

```sh
sha256sum -c reports/runtime-refresh/pdesd/evidence-manifest.sha256
```
