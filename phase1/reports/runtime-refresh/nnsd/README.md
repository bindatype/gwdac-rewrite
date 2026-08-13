# NNSD runtime-refresh smoke

Date: 2026-08-13

## Result

`nnsd` is an exact smoke pass for the archived `nn/NNF.INP` deck. The
unchanged `f6c81d0` sources build and link with Ubuntu 24.04, gfortran 13.3.0,
and the current system libraries. The resulting executable and the checked-in
historical executable both exit normally with status 0 and produce the same
8,439-byte stdout, SHA-256
`5b94d421759de07f6731b72af706dddb833f7a1281e4af8ad3798fe6eb18455d`.

This is runtime-compatibility evidence, not physics approval.

## Evidence

- **Captured:** `historical/` is a same-input run of the checked-in executable
  in the isolated historical-runtime container.
- **Reference:** `build/` and `modern/` record the unchanged-source build and
  its same-input run in the Ubuntu 24.04 development container.
- The historical and modern runs each opened 14 paths. Their lists differ only
  in the configured dataset root (`/home/arndt64/sdat` versus
  `/workspace/arndt64/sdat`).
- The archived `nn/NNF.OUT` file is not byte-identical to either run and is
  retained only as a plausible, not proven, deck/transcript pairing.
- The modern build emitted 136 warning instances. No warning-driven source
  change was made.
- The modern executable has no dependency on `libg2c`, `libgfortran.so.3`, or
  `libpng12`; its dependency list remains recorded in `modern/manifest.txt`.

Run the three scripts in order, using the named Compose services:

```sh
docker compose exec -T dev /phase1/scripts/build-runtime-engine-smoke nnsd
docker compose exec -T oracle /phase1/scripts/run-historical-runtime-engine-smoke nnsd
docker compose exec -T dev /phase1/scripts/run-runtime-engine-smoke nnsd
```

Verify the committed evidence from `phase1/`:

```sh
sha256sum -c reports/runtime-refresh/nnsd/evidence-manifest.sha256
```
