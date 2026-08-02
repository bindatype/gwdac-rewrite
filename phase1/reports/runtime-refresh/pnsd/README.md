# Legacy Runtime Refresh: `pnsd`

Status: **blocked after the first behavioral divergence**

Source snapshot: `arndt64@f6c81d01a1fe8b007c247acc2213f821a62dc4f2`

## Build result

Evidence label: **reference**

`pnsd.f`, `pn1.f`, `pn2.f`, and `pnu.f` build and link on Ubuntu 24.04 x86-64
with GNU Fortran 13.3.0. Two clean builds produced the same executable SHA-256:

```text
c5a4baf28c9e1c1119ba0376d3d9ea9bbed7e4c4ac476ab7a0f71a972a32b20d
```

The executable depends on `libgfortran.so.5`, `libm`, X11, GD, `libgcc_s`, and
libc. It has no dependency on `g77`, `libg2c`, `libgfortran.so.3`, or
`libpng12`. The clean build emits 233 classified warnings; none was changed.

## Oracle result

Evidence label: **oracle** for the checked-in executable and **reference** for
the modern build.

Both executables ran the committed SP06 pion-nucleon no-render deck. Their
seven displayed DSG rows are byte-identical, including the observable,
uncertainty, lab angle, and lab differential cross section. Both normalized
result files have SHA-256:

```text
05048dfba0f072aaac8cd36cfb28f32ea20cf627cfa61d12ba11cea143f16328
```

The first behavioral divergence follows that table. The historical executable
reads and prints the selected experimental data, reaches `GO99`, exits 0, and
writes no stderr. The modern executable stops in `PNRDX` at `pnu.f:4569` with
an end-of-file error on `READ(CSTR,159) INP,MMO,MMY`; it exits 2 and does not
reach the normal SAID completion message.

This is a runtime compatibility failure, so the engine does not pass the
Legacy Runtime Refresh gate even though the displayed calculated DSG values
match. Per the warning and early-stop rules, no source fix was attempted and
the next engine was not started. This result is not physics approval.

## Reproduction

From `outputs/container-environment`, with the pinned `dev` and `oracle`
containers available:

```sh
docker compose exec oracle /phase1/scripts/run-historical-pnsd
docker compose exec dev /phase1/scripts/build-pnsd
docker compose exec dev /phase1/scripts/run-pnsd
```

The final command intentionally returns nonzero while the recorded divergence
remains. Concrete hashes, dependencies, counts, stdout, stderr, and generated
artifacts are under this directory.
