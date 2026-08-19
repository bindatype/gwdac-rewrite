# Legacy Runtime Refresh: `pnsd`

Status: **candidate exact runtime pass**

Source snapshot: `arndt64@f6c81d01a1fe8b007c247acc2213f821a62dc4f2`

## Build result

Evidence label: **reference**

The unchanged `pnsd.f`, `pn1.f`, `pn2.f`, and `pnu.f` sources build and link on
Ubuntu 24.04 x86-64 with GNU Fortran 13.3.0. Two clean builds produced the same
executable SHA-256:

```text
49248aeceb800a189c064faf1eb2115ad78e31e5c8ff36a5c1d356247f4a0442
```

Only the `pnsd.f` main program unit is compiled with `-std=gnu`; every other
unit retains the accepted `-std=legacy` flags. The main unit establishes
libgfortran's process-wide formatted-input behavior through
`_gfortran_set_options`. This narrow setting restores g77 comma handling for A
editing without changing the frozen Fortran source.

The modern executable has no dependency on `g77`, `libg2c`,
`libgfortran.so.3`, or `libpng12`. The clean build emits 633 classified warning
instances: 566 in the core, 8 in local libraries, and 59 in `gplot`. The 400
additional core diagnostics are compatibility-debt reports exposed by
`-std=gnu`; no warning-driven source fix was made.

## Oracle result

Evidence label: **oracle** for the checked-in executable and **reference** for
the unchanged-source modern build.

Both executables run the committed SP06 pion-nucleon no-render deck, exit 0,
write empty stderr, produce seven DSG rows, reach `Thanks for using SAID`, and
produce no `SAID.PS`. The normalized results remain byte-identical with
SHA-256:

```text
05048dfba0f072aaac8cd36cfb28f32ea20cf627cfa61d12ba11cea143f16328
```

The complete surviving runtime contract is exact across historical and modern:
`stdout.txt`, `stderr.txt`, `results.tsv`, `SAID.TMP`, `SAID.PCT`, `SAID.LOG`,
and `fort.7`. `comparison.tsv` records each SHA-256 pair. Missing artifacts,
nonzero stderr, abnormal completion, changed DSG rows, any artifact mismatch,
or creation of `SAID.PS` fails the modern runner.

## Relationship to the superseded package

This candidate replaces the blocked package recorded at `917f743`, where the
modern executable produced the seven correct rows and then exited 2 at
`pnu.f:4569` while the historical executable continued normally. That package
remains valid evidence for the old compiler configuration and remains
retrievable in repository history; it is superseded, not repudiated.

The first divergence was process-global formatted-input behavior at
`READ(CSTR,159)` in `PNRDX`. The main-unit compiler setting fully accounts for
the difference. This is runtime-compatibility evidence, not physics approval.

## Reproduction

From `container-environment`, with the pinned `dev` and `oracle` services:

```sh
docker compose exec -T oracle /phase1/scripts/run-historical-pnsd
docker compose exec -T dev /phase1/scripts/build-pnsd
docker compose exec -T dev /phase1/scripts/build-pnsd
docker compose exec -T dev /phase1/scripts/run-pnsd
```

The clean-checkout reviewer runs the same oracle, two-build reproducibility,
633-warning, and seven-artifact contracts before the five-engine smoke sweep:

```sh
reviewer/reproduce-evidence --scope runtime-refresh
```

Verify the committed package from `phase1/`:

```sh
sha256sum -c reports/runtime-refresh/pnsd/evidence-manifest.sha256
```
