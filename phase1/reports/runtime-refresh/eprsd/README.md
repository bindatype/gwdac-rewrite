# EPRSD runtime-refresh smoke

Date: 2026-08-13

## Result

`eprsd` is an exact smoke pass for the archived `pr/epr/EPRF.INP` deck.
The unchanged `f6c81d0` sources build and link with Ubuntu 24.04,
gfortran 13.3.0, and the current system libraries. The resulting executable
and the checked-in historical executable both exit normally with status 0 and
produce the same 103,437-byte stdout, SHA-256
`afede70b7e54b58a95d4d59d00dbf2e446ecb3b9bd160761a49fe8e1b2d4e352`.

This is runtime-compatibility evidence, not physics approval.

## Evidence

- **Captured:** `historical/` is a same-input run of the checked-in executable
  in the isolated historical-runtime container.
- **Reference:** `build/` and `modern/` record the unchanged-source build and
  its same-input run in the Ubuntu 24.04 development container.
- The historical and modern runs each opened 35 paths. Their lists differ only
  in the configured dataset root (`/home/arndt64/sdat` versus
  `/workspace/arndt64/sdat`).
- The archived `pr/epr/EPRF.OUT` file is not byte-identical to either run and
  is retained only as a plausible, not proven, deck/transcript pairing.
- The modern build emitted 463 warning instances. No warning-driven source
  change was made.
- The modern executable has no dependency on `libg2c`, `libgfortran.so.3`, or
  `libpng12`; its dependency list remains recorded in `modern/manifest.txt`.

Run the three scripts in order from the `dev` container:

```sh
/phase1/scripts/build-runtime-engine-smoke eprsd
/phase1/scripts/run-historical-runtime-engine-smoke eprsd
/phase1/scripts/run-runtime-engine-smoke eprsd
```

Verify the committed evidence from `phase1/`:

```sh
sha256sum -c reports/runtime-refresh/eprsd/evidence-manifest.sha256
```
