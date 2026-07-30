# pnpolw build reproducibility

Two independent clean build roots produced byte-identical executables:

```text
a69b66b3c488b7a70def8170e7ba7a836383aedf13bee74113390b928d6cce58  pnpolw
```

The target is built at `arndt64@f6c81d01a1fe8b007c247acc2213f821a62dc4f2`
with GNU Fortran 13.3.0 on Ubuntu 24.04 x86-64. It rebuilds 63 `pnu` members,
31 `MOD01` members, 15 `saidopen` members, 101 `libxz` members, and the
145-member `gplot` closure from source.

The resulting ELF depends on `libgfortran.so.5`, `libm.so.6`, `libX11.so.6`,
`libgd.so.3`, `libgcc_s.so.1`, and `libc.so.6`. It does not depend on `g77`,
`libg2c`, `libgfortran.so.3`, `libpng12`, or `libgd.so.1`.

The build applies copied-source overlays only:

- six rejected g77 Hollerith call operands become equivalent four-byte
  character operands;
- seven `/home/arndt/sdat` startup files become staged `data/` paths;
- the previously established `saidopen` and `gplot` compiler/path overlays.

Build identity and all overlay hashes are recorded in
`pnpolw-build-manifest.txt`.
