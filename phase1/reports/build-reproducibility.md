# PRSD build reproducibility correction

## Finding

The originally recorded `prsdd` SHA-256
`d5385b2362b0a968d209a4c7c3e64de9a858aac943cecbedef5270b5131c9b55`
was not reproducible across clean temporary build roots. GFortran embedded the
absolute source filename in runtime I/O diagnostics, so the randomized
`build-<commit>.<suffix>` directory changed object and executable bytes.

## Correction

The build now compiles copied Fortran sources from inside their source
directories and passes stable basenames. `-ffile-prefix-map` remains enabled
for compiler metadata but was insufficient by itself for GFortran's runtime
source-location strings.

Two independent complete builds from different temporary roots produced:

- rendering `prsdd`:
  `770a6147266b1b121c6a0a161a694723d5c7d10e3e46af7a19a557ad5415141c`
- `prsdd-headless`:
  `958889882d91fce225c04bc18021725fec757bde6ea047df1bf93a4136c7aa4f`

`build-reproducibility.sha256` is the machine-readable verification set. The
old path-dependent hashes remain historical diagnostics and are superseded.

## Phase 2 reuse

The build driver now has an opt-in `CM12_SEAM_ROOT` mode for the Phase 2
solution/dataset, background, amplitude, and DSG reference seams. The default
remains the Phase 1 reference source set and hashes above. Seam builds use a
separate state and report root and therefore do not overwrite this evidence.
